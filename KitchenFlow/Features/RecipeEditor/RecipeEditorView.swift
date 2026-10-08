import SwiftUI
import SwiftData

/// Formulario para crear o editar un guion de tiempos culinario.
struct RecipeEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var recipes: [Recipe]
    
    let recipeToEdit: Recipe?
    
    @State private var title: String
    @State private var recipeDescription: String
    @State private var selectedEmoji: String
    @State private var draftSteps: [DraftStep]
    
    private let availableEmojis = ["🥘", "🍲", "🍝", "🥩", "🥗", "🍰", "🍕", "🥖", "☕️", "🍳"]
    
    struct DraftIntervalAlert: Identifiable {
        var id = UUID()
        var intervalSeconds: Int
        var message: String
    }
    
    struct DraftStep: Identifiable {
        var id = UUID()
        var title: String
        var instructions: String
        var minutes: Int
        var seconds: Int
        var requiresManualConfirmation: Bool
        var alerts: [DraftIntervalAlert]
        
        var totalDurationSeconds: Int {
            (minutes * 60) + seconds
        }
    }
    
    init(recipe: Recipe? = nil) {
        self.recipeToEdit = recipe
        
        if let existing = recipe {
            _title = State(initialValue: existing.title)
            _recipeDescription = State(initialValue: existing.recipeDescription)
            _selectedEmoji = State(initialValue: existing.iconEmoji)
            
            let loadedSteps = existing.steps.sorted(by: { $0.stepOrder < $1.stepOrder }).map { step in
                DraftStep(
                    id: step.id,
                    title: step.title,
                    instructions: step.instructions,
                    minutes: step.durationSeconds / 60,
                    seconds: step.durationSeconds % 60,
                    requiresManualConfirmation: step.requiresManualConfirmation,
                    alerts: step.intervalAlerts.map {
                        DraftIntervalAlert(id: $0.id, intervalSeconds: $0.intervalSeconds, message: $0.message)
                    }
                )
            }
            _draftSteps = State(initialValue: loadedSteps)
        } else {
            _title = State(initialValue: "")
            _recipeDescription = State(initialValue: "")
            _selectedEmoji = State(initialValue: "🥘")
            _draftSteps = State(initialValue: [
                DraftStep(title: "", instructions: "", minutes: 5, seconds: 0, requiresManualConfirmation: false, alerts: [])
            ])
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Sección General
                Section("recipes.editor.section_general") {
                    HStack {
                        Text("recipes.editor.select_emoji", comment: "Icono")
                        Spacer()
                        Picker("recipes.editor.select_emoji", selection: $selectedEmoji) {
                            ForEach(availableEmojis, id: \.self) { emoji in
                                Text(emoji).tag(emoji)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    TextField("recipes.editor.placeholder_name", text: $title)
                    TextField("recipes.editor.placeholder_description", text: $recipeDescription, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                // Sección Pasos
                Section("recipes.editor.section_steps") {
                    ForEach($draftSteps) { $step in
                        VStack(alignment: .leading, spacing: 10) {
                            TextField("recipes.editor.step_title_placeholder", text: $step.title)
                                .font(.headline)
                            
                            HStack(spacing: 12) {
                                Stepper(String(format: NSLocalizedString("%lld min", comment: "Minutos"), step.minutes), value: $step.minutes, in: 0...180)
                                Stepper(String(format: NSLocalizedString("%lld seg", comment: "Segundos"), step.seconds), value: $step.seconds, in: 0...59)
                            }
                            .font(.subheadline)
                            
                            Toggle("recipes.editor.step_manual_toggle", isOn: $step.requiresManualConfirmation)
                                .font(.footnote)
                            
                            // Avisos anidados
                            if !step.alerts.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("recipes.editor.interval_alert_title", comment: "Avisos anidados")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                    
                                    ForEach(step.alerts) { alert in
                                        HStack {
                                            Image(systemName: "bell.fill")
                                                .font(.caption2)
                                                .foregroundStyle(KitchenColors.flameOrange)
                                            Text(verbatim: "\(alert.message) (\(alert.intervalSeconds)s)")
                                                .font(.caption)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            
                            Button(action: {
                                addAlertToStep(&step)
                            }) {
                                Label("recipes.editor.interval_alert_add", systemImage: "plus.circle")
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .onDelete(perform: deleteStep)
                    
                    Button(action: addNewStep) {
                        Label("recipes.editor.add_step_button", systemImage: "plus.circle.fill")
                            .foregroundStyle(KitchenColors.saffron)
                    }
                }
            }
            .navigationTitle(
                recipeToEdit == nil
                ? Text("recipes.editor.title_new", comment: "Nueva Receta")
                : Text("recipes.editor.title_edit", comment: "Editar Receta")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("common.actions.cancel", comment: "Cancelar")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        saveRecipe()
                        dismiss()
                    }) {
                        Text("common.actions.save", comment: "Guardar")
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || draftSteps.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Operaciones Auxiliares
    
    private func addNewStep() {
        let newStep = DraftStep(
            title: "",
            instructions: "",
            minutes: 5,
            seconds: 0,
            requiresManualConfirmation: false,
            alerts: []
        )
        draftSteps.append(newStep)
    }
    
    private func addAlertToStep(_ step: inout DraftStep) {
        let alert = DraftIntervalAlert(
            intervalSeconds: 60,
            message: "Remover"
        )
        step.alerts.append(alert)
    }
    
    private func deleteStep(at offsets: IndexSet) {
        draftSteps.remove(atOffsets: offsets)
    }
    
    private func saveRecipe() {
        let cleanTitle = title.trimmingCharacters(in: .whitespaces)
        
        if let existing = recipeToEdit {
            existing.title = cleanTitle
            existing.recipeDescription = recipeDescription
            existing.iconEmoji = selectedEmoji
            
            // Recrear pasos
            existing.steps.removeAll()
            for (index, draft) in draftSteps.enumerated() {
                let step = RecipeStep(
                    stepOrder: index + 1,
                    title: draft.title.isEmpty ? "Paso \(index + 1)" : draft.title,
                    instructions: draft.instructions,
                    durationSeconds: draft.totalDurationSeconds,
                    requiresManualConfirmation: draft.requiresManualConfirmation,
                    intervalAlerts: draft.alerts.map {
                        StepIntervalAlert(intervalSeconds: $0.intervalSeconds, message: $0.message)
                    }
                )
                existing.steps.append(step)
            }
        } else {
            // Guard: El plan gratuito solo permite 1 receta en total en la app
            guard StoreKitManager.shared.isProUser || recipes.count < 1 else {
                return
            }
            
            var newSteps: [RecipeStep] = []
            for (index, draft) in draftSteps.enumerated() {
                let step = RecipeStep(
                    stepOrder: index + 1,
                    title: draft.title.isEmpty ? "Paso \(index + 1)" : draft.title,
                    instructions: draft.instructions,
                    durationSeconds: draft.totalDurationSeconds,
                    requiresManualConfirmation: draft.requiresManualConfirmation,
                    intervalAlerts: draft.alerts.map {
                        StepIntervalAlert(intervalSeconds: $0.intervalSeconds, message: $0.message)
                    }
                )
                newSteps.append(step)
            }
            
            let newRecipe = Recipe(
                title: cleanTitle,
                recipeDescription: recipeDescription,
                iconEmoji: selectedEmoji,
                isDefaultSample: false,
                steps: newSteps
            )
            modelContext.insert(newRecipe)
        }
        
        try? modelContext.save()
    }
}
