import Foundation
import ActivityKit

/// Gestor del ciclo de vida de Live Activities para KitchenFlow.
@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<CookingActivityAttributes>?
    
    private init() {}
    
    /// Comprueba si el dispositivo soporta y tiene activadas las Live Activities
    var isLiveActivitySupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    /// Inicia una nueva Live Activity para la sesión de cocina
    func startActivity(
        recipe: Recipe,
        currentStep: RecipeStep,
        stepIndex: Int,
        nextStep: RecipeStep?
    ) {
        guard isLiveActivitySupported else { return }
        
        // Si hay una actividad previa, finalizarla primero
        endActivity(immediate: true)
        
        let attributes = CookingActivityAttributes(
            recipeTitle: recipe.title,
            recipeEmoji: recipe.iconEmoji,
            totalStepsCount: recipe.steps.count
        )
        
        let initialContentState = CookingActivityAttributes.ContentState(
            currentStepIndex: stepIndex,
            stepTitle: currentStep.title,
            remainingSeconds: currentStep.durationSeconds,
            stepDurationSeconds: currentStep.durationSeconds,
            stepProgressFraction: 0.0,
            isPaused: false,
            intervalNotice: nil,
            nextStepTitle: nextStep?.title,
            requiresManualConfirmation: currentStep.requiresManualConfirmation
        )
        
        do {
            let activityContent = ActivityContent(state: initialContentState, staleDate: nil)
            currentActivity = try Activity.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil
            )
        } catch {
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }
    
    /// Actualiza el estado de la Live Activity en vivo
    func updateActivity(
        step: RecipeStep,
        stepIndex: Int,
        remainingSeconds: Int,
        progress: Double,
        isPaused: Bool,
        intervalNotice: String?,
        nextStep: RecipeStep?
    ) {
        guard let activity = currentActivity else { return }
        
        let updatedState = CookingActivityAttributes.ContentState(
            currentStepIndex: stepIndex,
            stepTitle: step.title,
            remainingSeconds: remainingSeconds,
            stepDurationSeconds: step.durationSeconds,
            stepProgressFraction: progress,
            isPaused: isPaused,
            intervalNotice: intervalNotice,
            nextStepTitle: nextStep?.title,
            requiresManualConfirmation: step.requiresManualConfirmation
        )
        
        let content = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            await activity.update(content)
        }
    }
    
    /// Finaliza la Live Activity activa
    func endActivity(immediate: Bool = false) {
        guard let activity = currentActivity else { return }
        
        let dismissalPolicy: ActivityUIDismissalPolicy = immediate ? .immediate : .default
        
        Task {
            await activity.end(nil, dismissalPolicy: dismissalPolicy)
        }
        
        self.currentActivity = nil
    }
}
