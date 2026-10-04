import SwiftUI
import SwiftData

/// Pantalla principal con la lista de recetas, acceso al detalle, estado del plan gratuito y acceso al cocinado.
struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    
    @AppStorage("hasSeededInitialSample") private var hasSeededInitialSample: Bool = false
    private var storeKit = StoreKitManager.shared
    @State private var timerEngine = CookingTimerEngine()
    @State private var showingActiveCooking = false
    @State private var activeSheet: RecipeListSheet?
    
    /// Hojas modales posibles en la lista de recetas
    enum RecipeListSheet: Identifiable {
        case newRecipe
        case editRecipe(Recipe)
        case paywall
        case settings
        
        var id: String {
            switch self {
            case .newRecipe:
                return "newRecipe"
            case .editRecipe(let recipe):
                return "editRecipe_\(recipe.persistentModelID)"
            case .paywall:
                return "paywall"
            case .settings:
                return "settings"
            }
        }
    }
    
    /// Regla del plan Free: límite estricto de 1 receta en total (salvo que tenga KitchenFlow Pro)
    private var canCreateMoreRecipes: Bool {
        storeKit.isProUser || recipes.count < 1
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    emptyStateView
                } else {
                    recipeListContent
                }
            }
            .navigationTitle("recipes.list.title")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !storeKit.isProUser {
                        Button {
                            activeSheet = .paywall
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                Text("PRO")
                            }
                            .font(.footnote.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(KitchenColors.primaryGradient())
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        activeSheet = .settings
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.body.weight(.medium))
                    }
                    .tint(.secondary)
                    
                    Button(action: handleAddRecipeTapped) {
                        Label("recipes.list.new_button", systemImage: "plus")
                    }
                    .tint(KitchenColors.saffron)
                }
            }
            // Presentación unificada de hojas modales sin colisiones de estado en SwiftUI
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .newRecipe:
                    RecipeEditorView(recipe: nil)
                case .editRecipe(let recipe):
                    RecipeEditorView(recipe: recipe)
                case .paywall:
                    PaywallView()
                case .settings:
                    SettingsView()
                }
            }
            // Pantalla completa de cocinado activo
            .fullScreenCover(isPresented: $showingActiveCooking) {
                ActiveCookingView(engine: timerEngine)
            }
            .onAppear {
                seedInitialSampleIfNeeded()
            }
        }
    }
    
    // MARK: - Lista de Recetas
    
    private var recipeListContent: some View {
        List {
            // Banner de la versión gratuita o estado Pro
            Section {
                if storeKit.isProUser {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title3)
                            .foregroundStyle(KitchenColors.basilGreen)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("paywall.pro_active_badge")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text("paywall.pro_active_message")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } else {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.title3)
                            .foregroundStyle(KitchenColors.saffron)
                        
                        Text("recipes.list.free_limit_banner", comment: "Aviso plan free")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Button {
                            activeSheet = .paywall
                        } label: {
                            Text("paywall.upgrade_cta")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(KitchenColors.saffron)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Tarjetas de Recetas con navegación al detalle
            Section {
                ForEach(recipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, onStartCooking: startCooking)) {
                        recipeCard(for: recipe)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteRecipe(recipe)
                        } label: {
                            Label("common.actions.delete", systemImage: "trash")
                        }
                        
                        Button {
                            activeSheet = .editRecipe(recipe)
                        } label: {
                            Label("common.actions.edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Tarjeta de Receta
    
    @ViewBuilder
    private func recipeCard(for recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Text(recipe.iconEmoji)
                    .font(.system(size: 38))
                    .frame(width: 54, height: 54)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if !recipe.recipeDescription.isEmpty {
                        Text(recipe.recipeDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            
            HStack(spacing: 16) {
                Label(recipe.formattedTotalDuration, systemImage: "clock")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                Label("\(recipe.steps.count) fases", systemImage: "list.number")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: {
                    startCooking(recipe: recipe)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                        Text("recipes.card.start_cooking", comment: "Empezar a cocinar")
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(KitchenColors.primaryGradient())
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.borderless) // Evita interferir con el tap del NavigationLink
            }
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Estado Vacío
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "timer")
                .font(.system(size: 64))
                .foregroundStyle(KitchenColors.saffron)
            
            VStack(spacing: 8) {
                Text("recipes.list.empty_title", comment: "Sin recetas")
                    .font(.title2.weight(.bold))
                
                Text("recipes.list.empty_description", comment: "Descripción sin recetas")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: handleAddRecipeTapped) {
                Text("recipes.list.new_button", comment: "Nueva Receta")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(KitchenColors.saffron)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }
    
    // MARK: - Acciones y Lógica
    
    private func handleAddRecipeTapped() {
        if canCreateMoreRecipes {
            activeSheet = .newRecipe
        } else {
            activeSheet = .paywall
        }
    }
    
    private func startCooking(recipe: Recipe) {
        timerEngine.startCooking(recipe: recipe)
        showingActiveCooking = true
    }
    
    private func deleteRecipe(_ recipe: Recipe) {
        modelContext.delete(recipe)
        try? modelContext.save()
    }
    
    private func seedInitialSampleIfNeeded() {
        if !hasSeededInitialSample && recipes.isEmpty {
            let sample = SampleDataService.createSampleRecipe()
            modelContext.insert(sample)
            try? modelContext.save()
            hasSeededInitialSample = true
        }
    }
}
