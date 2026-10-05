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
/// Gestiona temporizadores secuenciales, avisos anidados, Live Activities, Apple Watch y notificaciones.
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
    
    // MARK: - Ciclo de Vida e Integración Watch
    init() {
        setupWatchConnectivityBindings()
    }
    
    private func setupWatchConnectivityBindings() {
        WatchConnectivityService.shared.onCommandReceived = { [weak self] command in
            guard let self = self else { return }
            switch command {
            case .pause:
                self.pause()
            case .resume:
                self.resume()
            case .nextStep:
                self.skipToNextStep()
            case .dismissInterval:
                self.dismissIntervalAlert()
            case .requestSync:
                self.syncExternalDisplays()
            }
        }
        
        WatchConnectivityService.shared.onSyncRequested = { [weak self] in
            guard let self = self else { return nil }
            return self.buildSnapshot()
        }
    }
    
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
    
    // MARK: - Snapshot de Estado (Ecosistema Watch & Widgets)
    
    public func buildSnapshot() -> CookingSessionSnapshot {
        guard let recipe = activeRecipe, let step = currentStep else {
            return .idle
        }
        
        return CookingSessionSnapshot(
            recipeTitle: recipe.title,
            recipeEmoji: recipe.iconEmoji,
            stepTitle: step.title,
            stepInstruction: step.instructions,
            stepIndex: currentStepIndex,
            totalSteps: recipe.steps.count,
            remainingSeconds: remainingStepSeconds,
            stepDurationSeconds: step.durationSeconds,
            isPaused: sessionState == .paused,
            isCompleted: sessionState == .completed,
            isWaitingConfirmation: sessionState == .waitingForManualAction,
            intervalNotice: currentIntervalNotice,
            nextStepTitle: nextStep?.title,
            isProUser: StoreKitManager.shared.isProUser
        )
    }
    
    // MARK: - Acciones Públicas del Motor
    
    func startCooking(recipe: Recipe) {
        guard !recipe.steps.isEmpty else { return }
        self.activeRecipe = recipe
        self.currentStepIndex = 0
        self.totalElapsedSeconds = 0
        self.currentIntervalNotice = nil
        
        if !ProcessInfo.processInfo.arguments.contains("-screen-active-cooking") {
            NotificationService.shared.requestAuthorization()
        }
        
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
        syncExternalDisplays()
    }
    
    func pause() {
        guard sessionState == .running else { return }
        internalTimer?.invalidate()
        internalTimer = nil
        sessionState = .paused
        syncExternalDisplays()
    }
    
    func resume() {
        guard sessionState == .paused else { return }
        startTimer()
        syncExternalDisplays()
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
        syncExternalDisplays()
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
        WatchConnectivityService.shared.sendSnapshot(.idle)
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
        
        syncExternalDisplays()
    }
    
    private func startTimer() {
        internalTimer?.invalidate()
        sessionState = .running
        
        internalTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
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
        
        // Sincronizar Live Activity y Apple Watch
        syncExternalDisplays()
        
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
                    syncExternalDisplays()
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
        syncExternalDisplays()
    }
    
    /// Sincroniza el estado en todas las pantallas secundarias (Live Activity, Dynamic Island y Apple Watch)
    private func syncExternalDisplays() {
        guard let step = currentStep else { return }
        
        // 1. Live Activity & Dynamic Island
        LiveActivityManager.shared.updateActivity(
            step: step,
            stepIndex: currentStepIndex,
            remainingSeconds: remainingStepSeconds,
            progress: stepProgressFraction,
            isPaused: sessionState == .paused,
            intervalNotice: currentIntervalNotice,
            nextStep: nextStep
        )
        
        // 2. Apple Watch Companion
        WatchConnectivityService.shared.sendSnapshot(buildSnapshot())
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
