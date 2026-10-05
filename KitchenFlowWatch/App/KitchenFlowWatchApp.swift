import SwiftUI

/// Punto de entrada del ciclo de vida para KitchenFlowWatch (watchOS 10+).
@main
struct KitchenFlowWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchCookingView()
        }
    }
}
