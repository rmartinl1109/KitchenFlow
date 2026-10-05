import SwiftUI

/// Punto de entrada del ciclo de vida para KitchenFlowWatch (watchOS 10+).
@main
struct KitchenFlowWatchApp: App {
    init() {
        if ProcessInfo.processInfo.arguments.contains("-screen-watch-active") {
            let activeSnapshot = CookingSessionSnapshot(
                recipeTitle: "Mushroom Risotto",
                recipeEmoji: "🥘",
                stepTitle: "Sauté Shallots & Mushrooms",
                stepInstruction: "In a wide pan with olive oil and butter, gently sauté shallots and sliced mushrooms...",
                stepIndex: 1,
                totalSteps: 4,
                remainingSeconds: 214,
                stepDurationSeconds: 240,
                isPaused: false,
                isCompleted: false,
                isWaitingConfirmation: false,
                intervalNotice: "Gently stir aromatics",
                nextStepTitle: "Toast Rice",
                isProUser: true
            )
            WatchConnectivityService.shared.sendSnapshot(activeSnapshot)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            WatchCookingView()
        }
    }
}
