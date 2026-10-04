import SwiftUI
import StoreKit

/// Pantalla de configuración general de KitchenFlow.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    
    @AppStorage("appAppearance") private var appAppearance: String = "system"
    @AppStorage("keepScreenAwake") private var keepScreenAwake: Bool = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("soundAlertsEnabled") private var soundAlertsEnabled: Bool = true
    
    private var storeKit = StoreKitManager.shared
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationStack {
            List {
                membershipSection
                appearanceSection
                cookingPreferencesSection
                supportSection
                aboutAndLegalSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("settings.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.actions.done") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(KitchenColors.saffron)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
    
    // MARK: - Sección de Membresía
    
    private var membershipSection: some View {
        Section("settings.section.membership") {
            if storeKit.isProUser {
                HStack(spacing: 14) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title)
                        .foregroundStyle(KitchenColors.basilGreen)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("paywall.pro_active_badge")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text("paywall.pro_active_message")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(KitchenColors.primaryGradient())
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "crown.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("KitchenFlow Pro")
                                .font(.headline)
                            
                            Text("paywall.subtitle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Button {
                        showingPaywall = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("paywall.upgrade_cta")
                                .font(.subheadline.weight(.bold))
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .background(KitchenColors.primaryGradient())
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Sección de Apariencia
    
    private var appearanceSection: some View {
        Section("settings.section.appearance") {
            Picker("settings.section.appearance", selection: $appAppearance) {
                Label("settings.appearance.system", systemImage: "iphone").tag("system")
                Label("settings.appearance.light", systemImage: "sun.max.fill").tag("light")
                Label("settings.appearance.dark", systemImage: "moon.fill").tag("dark")
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Preferencias de Cocina
    
    private var cookingPreferencesSection: some View {
        Section("settings.section.cooking_preferences") {
            Toggle(isOn: $keepScreenAwake) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("settings.preference.keep_awake")
                        .font(.body)
                    Text("settings.preference.keep_awake_desc")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .tint(KitchenColors.flameOrange)
            
            Toggle("settings.preference.haptics", isOn: $hapticsEnabled)
                .tint(KitchenColors.flameOrange)
            
            Toggle("settings.preference.sound_alerts", isOn: $soundAlertsEnabled)
                .tint(KitchenColors.flameOrange)
        }
    }
    
    // MARK: - Soporte y Comunidad
    
    private var supportSection: some View {
        Section("settings.section.support_community") {
            // Valorar en App Store
            Button {
                if UIApplication.shared.canOpenURL(KitchenFlowAppStoreConfig.writeReviewURL) {
                    UIApplication.shared.open(KitchenFlowAppStoreConfig.writeReviewURL)
                } else {
                    requestReview()
                }
            } label: {
                Label {
                    Text("settings.action.rate_app")
                        .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
            }
            
            // Enviar Feedback
            Button {
                sendFeedbackEmail()
            } label: {
                Label {
                    Text("settings.action.send_feedback")
                        .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(KitchenColors.flameOrange)
                }
            }
            
            // Compartir App
            ShareLink(
                item: KitchenFlowAppStoreConfig.appStoreURL,
                message: Text("settings.share_message")
            ) {
                Label {
                    Text("settings.action.share_app")
                        .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: "square.and.arrow.up.fill")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
    
    // MARK: - Acerca de y Legal
    
    private var aboutAndLegalSection: some View {
        Section("settings.section.legal_about") {
            Link(destination: URL(string: "https://kitchenflow.app")!) {
                HStack {
                    Label {
                        Text("settings.action.website")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "globe")
                            .foregroundStyle(.teal)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Link(destination: URL(string: "https://kitchenflow.app/privacy.html")!) {
                HStack {
                    Label {
                        Text("settings.action.privacy_policy")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "hand.raised.fill")
                            .foregroundStyle(.indigo)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Link(destination: URL(string: "https://kitchenflow.app/terms.html")!) {
                HStack {
                    Label {
                        Text("settings.action.terms_of_use")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            HStack {
                Text("settings.version")
                    .foregroundStyle(.primary)
                Spacer()
                Text("1.0 (Build 1)")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Acciones
    
    private func sendFeedbackEmail() {
        let systemVersion = UIDevice.current.systemVersion
        let model = UIDevice.current.model
        let subject = "KitchenFlow Feedback (iOS \(systemVersion), \(model))"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:feedback@kitchenflow.app?subject=\(subject)") {
            UIApplication.shared.open(url)
        }
    }
}
