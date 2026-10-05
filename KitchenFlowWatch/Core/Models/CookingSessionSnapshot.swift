import Foundation

/// Instantánea inmutable y serializable del estado de cocinado para el ecosistema Apple Watch.
public struct CookingSessionSnapshot: Codable, Sendable, Equatable {
    public let recipeTitle: String
    public let recipeEmoji: String
    public let stepTitle: String
    public let stepInstruction: String
    public let stepIndex: Int
    public let totalSteps: Int
    public let remainingSeconds: Int
    public let stepDurationSeconds: Int
    public let isPaused: Bool
    public let isCompleted: Bool
    public let isWaitingConfirmation: Bool
    public let intervalNotice: String?
    public let nextStepTitle: String?
    public let timestamp: Date
    
    public init(
        recipeTitle: String,
        recipeEmoji: String,
        stepTitle: String,
        stepInstruction: String,
        stepIndex: Int,
        totalSteps: Int,
        remainingSeconds: Int,
        stepDurationSeconds: Int,
        isPaused: Bool,
        isCompleted: Bool,
        isWaitingConfirmation: Bool,
        intervalNotice: String? = nil,
        nextStepTitle: String? = nil,
        timestamp: Date = Date()
    ) {
        self.recipeTitle = recipeTitle
        self.recipeEmoji = recipeEmoji
        self.stepTitle = stepTitle
        self.stepInstruction = stepInstruction
        self.stepIndex = stepIndex
        self.totalSteps = totalSteps
        self.remainingSeconds = remainingSeconds
        self.stepDurationSeconds = stepDurationSeconds
        self.isPaused = isPaused
        self.isCompleted = isCompleted
        self.isWaitingConfirmation = isWaitingConfirmation
        self.intervalNotice = intervalNotice
        self.nextStepTitle = nextStepTitle
        self.timestamp = timestamp
    }
    
    /// Progreso del paso actual de 0.0 a 1.0
    public var progressFraction: Double {
        guard stepDurationSeconds > 0 else { return 0.0 }
        let elapsed = Double(stepDurationSeconds - remainingSeconds)
        return min(max(elapsed / Double(stepDurationSeconds), 0.0), 1.0)
    }
    
    /// Tiempo formateado en MM:SS
    public var formattedRemainingTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Estado inactivo o vacío por defecto
    public static var idle: CookingSessionSnapshot {
        CookingSessionSnapshot(
            recipeTitle: "",
            recipeEmoji: "🍳",
            stepTitle: "",
            stepInstruction: "",
            stepIndex: 0,
            totalSteps: 0,
            remainingSeconds: 0,
            stepDurationSeconds: 0,
            isPaused: false,
            isCompleted: false,
            isWaitingConfirmation: false,
            intervalNotice: nil,
            nextStepTitle: nil
        )
    }
    
    public var isActive: Bool {
        !recipeTitle.isEmpty && !isCompleted
    }
}

/// Comandos remotos enviados desde el Apple Watch hacia el iPhone
public enum WatchCookingCommand: String, Codable, Sendable {
    case pause
    case resume
    case nextStep
    case dismissInterval
    case requestSync
}
