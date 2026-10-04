import Foundation
import SwiftUI
import Combine
import AudioToolbox

/// Estados del ciclo de vida de una sesión de cocina activa.
enum CookingSessionState: Equatable {
    case idle
    case running
    case paused
    case waitingForManualAction
    case completed
}

/// Motor de ejecución en tiempo real de flujos de tiempo culinarios.
/// Gestiona temporizadores secuenciales, avisos anidados, Live Activities y notificaciones.
@MainActor
@Observable
final class CookingTimerEngine {
    // MARK: - Propiedades de Estado
    private(set) var activeRecipe: Recipe?
    private(set) var currentStepIndex: Int = 0
    private(set) var sessionState: CookingSessionState = .idle
    
    private(set) var remainingStepSeconds: Int = 0
    private(set) var elapsedStepSeconds: Int = 0
    private(set) var totalElapsedSeconds: Int = 0
    
    /// Alerta de intervalo anidada activa en este instante (ej. "Remover sofrito")
    var currentIntervalNotice: String?
    
    // MARK: - Control Interno del Timer
    private var internalTimer: Timer?
    
    // MARK: - Propiedades Computadas de Progreso
    var currentStep: RecipeStep? {
        guard let recipe = activeRecipe,
              currentStepIndex >= 0 && currentStepIndex < recipe.steps.count else {
            return nil
        }
        return recipe.steps[currentStepIndex]
    }
    
    var nextStep: RecipeStep? {
        guard let recipe = activeRecipe,
              currentStepIndex + 1 < recipe.steps.count else {
            return nil
        }
        return recipe.steps[currentStepIndex + 1]
    }
    
    var totalStepsCount: Int {
        activeRecipe?.steps.count ?? 0
    }
    
    var stepProgressFraction: Double {
        guard let step = currentStep, step.durationSeconds > 0 else { return 0.0 }
        let fraction = Double(elapsedStepSeconds) / Double(step.durationSeconds)
        return min(max(fraction, 0.0), 1.0)
    }
    
    var formattedRemainingTime: String {
        let minutes = remainingStepSeconds / 60
        let seconds = remainingStepSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedOverallElapsed: String {
        let minutes = totalElapsedSeconds / 60
        let seconds = totalElapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Próximo aviso anidado en el paso actual (tiempo restante para que suene)
    var nextIntervalAlertNotice: (message: String, secondsRemaining: Int)? {
        guard let step = currentStep, !step.intervalAlerts.isEmpty, remainingStepSeconds > 0 else {
            return nil
        }
        
        var closestNotice: (message: String, secondsRemaining: Int)?
        for alert in step.intervalAlerts where alert.intervalSeconds > 0 {
            let nextTriggerElapsed = ((elapsedStepSeconds / alert.intervalSeconds) + 1) * alert.intervalSeconds
            let secondsUntil = nextTriggerElapsed - elapsedStepSeconds
            if secondsUntil > 0 && (elapsedStepSeconds + secondsUntil) <= step.durationSeconds {
                if closestNotice == nil || secondsUntil < closestNotice!.secondsRemaining {
                    closestNotice = (message: alert.message, secondsRemaining: secondsUntil)
                }
            }
        }
        return closestNotice
    }
    
    // MARK: - Acciones Públicas del Motor
    
    func startCooking(recipe: Recipe) {
        guard !recipe.steps.isEmpty else { return }
        self.activeRecipe = recipe
        self.currentStepIndex = 0
        self.totalElapsedSeconds = 0
        self.currentIntervalNotice = nil
        
        NotificationService.shared.requestAuthorization()
        
        loadStep(at: 0)
        
        if let step = currentStep {
            LiveActivityManager.shared.startActivity(
                recipe: recipe,
                currentStep: step,
                stepIndex: 0,
                nextStep: nextStep
            )
        }
        
        startTimer()
    }
    
    func pause() {
        guard sessionState == .running else { return }
        internalTimer?.invalidate()
        internalTimer = nil
        sessionState = .paused
        syncLiveActivity()
    }
    
    func resume() {
        guard sessionState == .paused else { return }
        startTimer()
        syncLiveActivity()
    }
    
    func skipToNextStep() {
        advanceStep()
    }
    
    func confirmManualStepDone() {
        guard sessionState == .waitingForManualAction else { return }
        advanceStep()
    }
    
    func dismissIntervalAlert() {
        currentIntervalNotice = nil
        syncLiveActivity()
    }
    
    func stopSession() {
        internalTimer?.invalidate()
        internalTimer = nil
        activeRecipe = nil
        currentStepIndex = 0
        remainingStepSeconds = 0
        elapsedStepSeconds = 0
        totalElapsedSeconds = 0
        currentIntervalNotice = nil
        sessionState = .idle
        
        LiveActivityManager.shared.endActivity(immediate: true)
        NotificationService.shared.cancelAllNotifications()
    }
    
    // MARK: - Lógica Interna de Ticks y Fases
    
    private func loadStep(at index: Int) {
        guard let recipe = activeRecipe, index < recipe.steps.count else {
            completeRecipe()
            return
        }
        
        let step = recipe.steps[index]
        currentStepIndex = index
        remainingStepSeconds = step.durationSeconds
        elapsedStepSeconds = 0
        currentIntervalNotice = nil
        
        if step.requiresManualConfirmation && step.durationSeconds == 0 {
            sessionState = .waitingForManualAction
        } else {
            sessionState = .running
        }
        
        syncLiveActivity()
    }
    
    private func startTimer() {
        internalTimer?.invalidate()
        sessionState = .running
        
        internalTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.handleTimerTick()
            }
        }
    }
    
    private func handleTimerTick() {
        guard sessionState == .running else { return }
        
        totalElapsedSeconds += 1
        elapsedStepSeconds += 1
        
        if remainingStepSeconds > 0 {
            remainingStepSeconds -= 1
        }
        
        // Comprobar alertas de intervalo anidadas
        checkIntervalAlerts()
        
        // Sincronizar Live Activity
        syncLiveActivity()
        
        // Comprobar si el paso ha terminado
        if remainingStepSeconds <= 0 {
            if let step = currentStep {
                let nextAction = nextStep?.title ?? NSLocalizedString("cooking.session.completed_title", comment: "Finalizado")
                NotificationService.shared.notifyStepCompleted(stepTitle: step.title, nextAction: nextAction)
                
                if step.requiresManualConfirmation {
                    triggerStepEndSound()
                    internalTimer?.invalidate()
                    internalTimer = nil
                    sessionState = .waitingForManualAction
                    syncLiveActivity()
                } else {
                    triggerStepEndSound()
                    advanceStep()
                }
            }
        }
    }
    
    private func checkIntervalAlerts() {
        guard let step = currentStep, let recipe = activeRecipe else { return }
        
        for alert in step.intervalAlerts where alert.intervalSeconds > 0 {
            if elapsedStepSeconds > 0 && (elapsedStepSeconds % alert.intervalSeconds == 0) && remainingStepSeconds > 0 {
                self.currentIntervalNotice = alert.message
                triggerIntervalAlertSound()
                NotificationService.shared.notifyIntervalAlert(recipeTitle: recipe.title, alertMessage: alert.message)
                break
            }
        }
    }
    
    private func advanceStep() {
        guard let recipe = activeRecipe else { return }
        let nextIndex = currentStepIndex + 1
        
        if nextIndex < recipe.steps.count {
            loadStep(at: nextIndex)
            if sessionState == .running && internalTimer == nil {
                startTimer()
            }
        } else {
            completeRecipe()
        }
    }
    
    private func completeRecipe() {
        internalTimer?.invalidate()
        internalTimer = nil
        sessionState = .completed
        triggerRecipeCompletedSound()
        LiveActivityManager.shared.endActivity(immediate: false)
    }
    
    private func syncLiveActivity() {
        guard let step = currentStep else { return }
        
        LiveActivityManager.shared.updateActivity(
            step: step,
            stepIndex: currentStepIndex,
            remainingSeconds: remainingStepSeconds,
            progress: stepProgressFraction,
            isPaused: sessionState == .paused,
            intervalNotice: currentIntervalNotice,
            nextStep: nextStep
        )
    }
    
    // MARK: - Efectos Hápticos y Sonoros
    
    private func triggerStepEndSound() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
        AudioServicesPlaySystemSound(1025) // Sonido campana
    }
    
    private func triggerIntervalAlertSound() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
        AudioServicesPlaySystemSound(1052) // Aviso suave
    }
    
    private func triggerRecipeCompletedSound() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
        AudioServicesPlaySystemSound(1022) // Fanfarria
    }
}
