import Foundation
import SwiftData

/// Alerta o recordatorio periódico anidado dentro de un paso de cocinado.
/// Ejemplo: "Remover sofrito cada 5 minutos".
@Model
final class StepIntervalAlert {
    var id: UUID
    var intervalSeconds: Int
    var message: String
    var soundEnabled: Bool
    
    init(
        id: UUID = UUID(),
        intervalSeconds: Int,
        message: String,
        soundEnabled: Bool = true
    ) {
        self.id = id
        self.intervalSeconds = intervalSeconds
        self.message = message
        self.soundEnabled = soundEnabled
    }
}

/// Paso individual de una receta culinaria con duración y alertas anidadas opcionales.
@Model
final class RecipeStep {
    var id: UUID
    var stepOrder: Int
    var title: String
    var instructions: String
    var durationSeconds: Int
    var requiresManualConfirmation: Bool
    
    @Relationship(deleteRule: .cascade)
    var intervalAlerts: [StepIntervalAlert] = []
    
    init(
        id: UUID = UUID(),
        stepOrder: Int,
        title: String,
        instructions: String = "",
        durationSeconds: Int,
        requiresManualConfirmation: Bool = false,
        intervalAlerts: [StepIntervalAlert] = []
    ) {
        self.id = id
        self.stepOrder = stepOrder
        self.title = title
        self.instructions = instructions
        self.durationSeconds = durationSeconds
        self.requiresManualConfirmation = requiresManualConfirmation
        self.intervalAlerts = intervalAlerts
    }
}

/// Modelo principal de una receta culinaria en KitchenFlow.
@Model
final class Recipe {
    var id: UUID
    var title: String
    var recipeDescription: String
    var iconEmoji: String
    var createdAt: Date
    var isDefaultSample: Bool
    
    @Relationship(deleteRule: .cascade)
    var steps: [RecipeStep] = []
    
    var totalDurationSeconds: Int {
        steps.reduce(0) { $0 + $1.durationSeconds }
    }
    
    var formattedTotalDuration: String {
        let minutes = totalDurationSeconds / 60
        let seconds = totalDurationSeconds % 60
        if minutes > 0 && seconds > 0 {
            return "\(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        recipeDescription: String = "",
        iconEmoji: String = "🥘",
        createdAt: Date = Date(),
        isDefaultSample: Bool = false,
        steps: [RecipeStep] = []
    ) {
        self.id = id
        self.title = title
        self.recipeDescription = recipeDescription
        self.iconEmoji = iconEmoji
        self.createdAt = createdAt
        self.isDefaultSample = isDefaultSample
        self.steps = steps
    }
}
