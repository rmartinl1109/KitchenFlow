import Foundation
import SwiftData

/// Servicio para precargar recetas de demostración con temporizadores secuenciales y anidados.
@MainActor
final class SampleDataService {
    static func createSampleRecipe() -> Recipe {
        let step1 = RecipeStep(
            stepOrder: 1,
            title: "Calentar caldo de verduras",
            instructions: "Poner el caldo en una cazuela a fuego medio-bajo para mantenerlo siempre caliente al incorporarlo.",
            durationSeconds: 180,
            requiresManualConfirmation: false
        )
        
        let step2Alert = StepIntervalAlert(
            intervalSeconds: 60,
            message: "Remover el sofrito para evitar que la cebolla se dore demasiado"
        )
        let step2 = RecipeStep(
            stepOrder: 2,
            title: "Pochar cebolla y setas",
            instructions: "En una sartén amplia con aceite de oliva y mantequilla, pochar la chalota picada y las setas laminadas.",
            durationSeconds: 240,
            requiresManualConfirmation: true,
            intervalAlerts: [step2Alert]
        )
        
        let step3 = RecipeStep(
            stepOrder: 3,
            title: "Nacarar el arroz y verter vino blanco",
            instructions: "Añadir el arroz arborio, remover 1 minuto y verter el vino blanco hasta que evapore el alcohol.",
            durationSeconds: 120,
            requiresManualConfirmation: true
        )
        
        let step4Alert = StepIntervalAlert(
            intervalSeconds: 90,
            message: "Remover suavemente y añadir otro cazo de caldo caliente"
        )
        let step4 = RecipeStep(
            stepOrder: 4,
            title: "Cocción lenta y mantecado",
            instructions: "Añadir caldo poco a poco sin dejar de remover. Al final añadir queso parmesano y mantecar con mantequilla.",
            durationSeconds: 600,
            requiresManualConfirmation: false,
            intervalAlerts: [step4Alert]
        )
        
        let recipe = Recipe(
            title: "Risotto de Setas al Parmesano",
            recipeDescription: "Guion de tiempos preciso para conseguir la textura cremosa perfecta del auténtico risotto italiano.",
            iconEmoji: "🍲",
            isDefaultSample: true,
            steps: [step1, step2, step3, step4]
        )
        
        return recipe
    }
}
