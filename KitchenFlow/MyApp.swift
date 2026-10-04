import SwiftUI
import SwiftData

@main
struct MyApp: App {
    @AppStorage("appAppearance") private var appAppearance: String = "system"
    
    private var selectedColorScheme: ColorScheme? {
        switch appAppearance {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(selectedColorScheme)
        }
        .modelContainer(for: [
            Recipe.self,
            RecipeStep.self,
            StepIntervalAlert.self
        ])
    }
}
