import SwiftUI
import SwiftData

/// Pantalla de detalle de una receta con vista previa completa de todas sus fases y temporizadores.
struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let recipe: Recipe
    let onStartCooking: (Recipe) -> Void
    
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Cabecera Hero con icono y datos generales
                headerSection
                
                // Botón destacado para comenzar
                Button(action: {
                    onStartCooking(recipe)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                        Text("recipes.detail.start_button", comment: "Empezar a cocinar")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(KitchenColors.primaryGradient())
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: KitchenColors.flameOrange.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.horizontal)
                
                // Lista de fases y temporizadores
                stepsSection
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingEditSheet = true
                }) {
                    Text("common.actions.edit", comment: "Editar")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            RecipeEditorView(recipe: recipe)
        }
    }
    
    // MARK: - Cabecera
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text(recipe.iconEmoji)
                .font(.system(size: 70))
                .frame(width: 90, height: 90)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            
            Text(recipe.title)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if !recipe.recipeDescription.isEmpty {
                Text(recipe.recipeDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            HStack(spacing: 20) {
                Label(recipe.formattedTotalDuration, systemImage: "clock.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KitchenColors.saffron)
                
                Label("\(recipe.steps.count) fases", systemImage: "list.number")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Sección de Pasos
    
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("recipes.detail.steps_title", comment: "Pasos de la receta")
                .font(.headline)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            ForEach(recipe.steps.sorted(by: { $0.stepOrder < $1.stepOrder })) { step in
                stepCard(for: step)
            }
        }
    }
    
    @ViewBuilder
    private func stepCard(for step: RecipeStep) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    Text("\(step.stepOrder)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(KitchenColors.saffron)
                        .clipShape(Circle())
                    
                    Text(step.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                let minutes = step.durationSeconds / 60
                let seconds = step.durationSeconds % 60
                let durationStr = (minutes > 0 && seconds > 0) ? "\(minutes)m \(seconds)s" : (minutes > 0 ? "\(minutes)m" : "\(seconds)s")
                
                Text(durationStr)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(KitchenColors.flameOrange)
            }
            
            if !step.instructions.isEmpty {
                Text(step.instructions)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            // Avisos anidados
            if !step.intervalAlerts.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(step.intervalAlerts) { alert in
                        HStack(spacing: 6) {
                            Image(systemName: "bell.badge.fill")
                                .font(.caption2)
                                .foregroundStyle(KitchenColors.flameOrange)
                            
                            Text(
                                String(
                                    format: NSLocalizedString("recipes.detail.interval_alert", comment: "Aviso de intervalo"),
                                    alert.intervalSeconds,
                                    alert.message
                                )
                            )
                            .font(.caption.weight(.medium))
                            .foregroundStyle(KitchenColors.flameOrange)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(KitchenColors.flameOrange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            
            // Requerimiento de confirmación manual
            if step.requiresManualConfirmation {
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.caption2)
                        .foregroundStyle(KitchenColors.saffron)
                    
                    Text("recipes.detail.manual_confirmation", comment: "Requiere confirmación")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }
}
