import Foundation
import SwiftData

/// Alerta o recordatorio periódico anidado dentro de un paso de cocinado.
/// Ejemplo: "Remover sofrito cada 5 minutos".
@Model
final class StepIntervalAlert {
    var id: UUID = UUID()
    var intervalSeconds: Int = 0
    var message: String = ""
    var soundEnabled: Bool = true
    
    var step: RecipeStep?
    
    init(
        id: UUID = UUID(),
        intervalSeconds: Int = 0,
        message: String = "",
        soundEnabled: Bool = true,
        step: RecipeStep? = nil
    ) {
        self.id = id
        self.intervalSeconds = intervalSeconds
        self.message = message
        self.soundEnabled = soundEnabled
        self.step = step
    }
}

/// Paso individual de una receta culinaria con duración y alertas anidadas opcionales.
@Model
final class RecipeStep {
    var id: UUID = UUID()
    var stepOrder: Int = 0
    var title: String = ""
    var instructions: String = ""
    var durationSeconds: Int = 0
    var requiresManualConfirmation: Bool = false
    
    var recipe: Recipe?
    
    @Relationship(deleteRule: .cascade, inverse: \StepIntervalAlert.step)
    var intervalAlerts: [StepIntervalAlert] = []
    
    init(
        id: UUID = UUID(),
        stepOrder: Int = 0,
        title: String = "",
        instructions: String = "",
        durationSeconds: Int = 0,
        requiresManualConfirmation: Bool = false,
        intervalAlerts: [StepIntervalAlert] = [],
        recipe: Recipe? = nil
    ) {
        self.id = id
        self.stepOrder = stepOrder
        self.title = title
        self.instructions = instructions
        self.durationSeconds = durationSeconds
        self.requiresManualConfirmation = requiresManualConfirmation
        self.intervalAlerts = intervalAlerts
        self.recipe = recipe
    }
}

/// Modelo principal de una receta culinaria en KitchenFlow.
@Model
final class Recipe {
    var id: UUID = UUID()
    var title: String = ""
    var recipeDescription: String = ""
    var iconEmoji: String = "🥘"
    var createdAt: Date = Date()
    var isDefaultSample: Bool = false
    
    @Relationship(deleteRule: .cascade, inverse: \RecipeStep.recipe)
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
        title: String = "",
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
