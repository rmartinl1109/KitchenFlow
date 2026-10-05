import SwiftUI
import SwiftData

@main
struct MyApp: App {
    @AppStorage("appAppearance") private var appAppearance: String = "system"
    @AppStorage("appLanguage") private var appLanguage: String = "system"
    
    let container: ModelContainer
    
    init() {
        let schema = Schema([
            Recipe.self,
            RecipeStep.self,
            StepIntervalAlert.self
        ])
        
        do {
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            print("KitchenFlow: Sincronización CloudKit no disponible (\(error.localizedDescription)). Inicializando contenedor SwiftData local de respaldo.")
            do {
                let localConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .none
                )
                container = try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                fatalError("KitchenFlow: Fallo crítico al inicializar SwiftData ModelContainer: \(error)")
            }
        }
    }
    
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
    
    private var selectedLocale: Locale {
        if appLanguage == "system" {
            return Locale.autoupdatingCurrent
        } else {
            return Locale(identifier: appLanguage)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(selectedColorScheme)
                .environment(\.locale, selectedLocale)
        }
        .modelContainer(container)
    }
}
