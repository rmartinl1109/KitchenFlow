import SwiftUI

struct ContentView: View {
    @State private var engine = CookingTimerEngine()
    
    var body: some View {
        let args = ProcessInfo.processInfo.arguments
        
        if args.contains("-screen-active-cooking") {
            let sample = SampleDataService.createSampleRecipe()
            ActiveCookingView(engine: engine)
                .onAppear {
                    engine.startCooking(recipe: sample)
                    engine.skipToNextStep()
                    engine.currentIntervalNotice = "Gently stir aromatics to prevent browning"
                }
        } else if args.contains("-screen-editor") {
            let sample = SampleDataService.createSampleRecipe()
            NavigationStack {
                RecipeEditorView(recipe: sample)
            }
        } else if args.contains("-screen-detail") {
            let sample = SampleDataService.createSampleRecipe()
            NavigationStack {
                RecipeDetailView(recipe: sample, onStartCooking: { _ in })
            }
        } else if args.contains("-screen-paywall") {
            PaywallView()
        } else if args.contains("-screen-settings") {
            SettingsView()
        } else {
            RecipeListView()
        }
    }
}
