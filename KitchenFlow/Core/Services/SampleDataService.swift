import Foundation
import SwiftData

/// Servicio para precargar recetas de demostración con temporizadores secuenciales y anidados.
@MainActor
final class SampleDataService {
    static func createSampleRecipe() -> Recipe {
        let step1 = RecipeStep(
            stepOrder: 1,
            title: "Warm Vegetable Broth",
            instructions: "Keep the broth warm in a pot over low heat so it incorporates easily into the risotto.",
            durationSeconds: 180,
            requiresManualConfirmation: false
        )
        
        let step2Alert = StepIntervalAlert(
            intervalSeconds: 60,
            message: "Gently stir aromatics to prevent browning"
        )
        let step2 = RecipeStep(
            stepOrder: 2,
            title: "Sauté Shallots & Mushrooms",
            instructions: "In a wide pan with olive oil and butter, gently sauté the finely chopped shallots and sliced mushrooms.",
            durationSeconds: 240,
            requiresManualConfirmation: true,
            intervalAlerts: [step2Alert]
        )
        
        let step3 = RecipeStep(
            stepOrder: 3,
            title: "Toast Rice & Deglaze with Wine",
            instructions: "Add arborio rice, stir for 1 minute until translucent around the edges, then pour white wine until evaporated.",
            durationSeconds: 120,
            requiresManualConfirmation: true
        )
        
        let step4Alert = StepIntervalAlert(
            intervalSeconds: 90,
            message: "Stir gently and add another ladle of warm broth"
        )
        let step4 = RecipeStep(
            stepOrder: 4,
            title: "Simmer & Mantecatura",
            instructions: "Gradually add warm broth ladle by ladle while stirring. Finish off the heat with grated parmesan and butter.",
            durationSeconds: 600,
            requiresManualConfirmation: false,
            intervalAlerts: [step4Alert]
        )
        
        let recipe = Recipe(
            title: "Parmesan Mushroom Risotto",
            recipeDescription: "Precise timer guide to achieve the authentic creamy texture of classic Italian risotto.",
            iconEmoji: "🍲",
            isDefaultSample: true,
            steps: [step1, step2, step3, step4]
        )
        
        return recipe
    }
}
