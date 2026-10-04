import Foundation
import ActivityKit

/// Atributos y estados dinámicos para Live Activities y Dynamic Island en KitchenFlow.
public struct CookingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// Índice del paso actual (0-indexed)
        public var currentStepIndex: Int
        /// Título del paso actual (ej. "Pochar cebolla y setas")
        public var stepTitle: String
        /// Tiempo restante del paso actual en segundos
        public var remainingSeconds: Int
        /// Duración total del paso actual en segundos
        public var stepDurationSeconds: Int
        /// Fracción de progreso del paso actual (0.0 a 1.0)
        public var stepProgressFraction: Double
        /// Indicador de si el temporizador está pausado
        public var isPaused: Bool
        /// Aviso de intervalo repetitivo activo en este momento (ej. "Remover sofrito")
        public var intervalNotice: String?
        /// Título del siguiente paso si existe
        public var nextStepTitle: String?
        /// Si el paso requiere confirmación manual al finalizar
        public var requiresManualConfirmation: Bool
        
        public init(
            currentStepIndex: Int,
            stepTitle: String,
            remainingSeconds: Int,
            stepDurationSeconds: Int,
            stepProgressFraction: Double,
            isPaused: Bool = false,
            intervalNotice: String? = nil,
            nextStepTitle: String? = nil,
            requiresManualConfirmation: Bool = false
        ) {
            self.currentStepIndex = currentStepIndex
            self.stepTitle = stepTitle
            self.remainingSeconds = remainingSeconds
            self.stepDurationSeconds = stepDurationSeconds
            self.stepProgressFraction = stepProgressFraction
            self.isPaused = isPaused
            self.intervalNotice = intervalNotice
            self.nextStepTitle = nextStepTitle
            self.requiresManualConfirmation = requiresManualConfirmation
        }
    }

    /// Datos estáticos invariables durante la sesión de cocina
    public var recipeTitle: String
    public var recipeEmoji: String
    public var totalStepsCount: Int
    
    public init(
        recipeTitle: String,
        recipeEmoji: String,
        totalStepsCount: Int
    ) {
        self.recipeTitle = recipeTitle
        self.recipeEmoji = recipeEmoji
        self.totalStepsCount = totalStepsCount
    }
}
