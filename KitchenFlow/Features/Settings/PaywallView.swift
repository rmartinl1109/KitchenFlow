import SwiftUI
import StoreKit

/// Pantalla modal de compra única de por vida para KitchenFlow Pro.
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var storeKit = StoreKitManager.shared
    
    @State private var restoreAlertMessage: String?
    @State private var showingRestoreAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    featuresList
                    pricingCard
                    purchaseButton
                    legalAndRestoreFooter
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .alert(
                restoreAlertMessage ?? "",
                isPresented: $showingRestoreAlert
            ) {
                Button("common.actions.done", role: .cancel) { }
            }
            .task {
                if storeKit.products.isEmpty {
                    await storeKit.loadProducts()
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(KitchenColors.primaryGradient())
                    .frame(width: 80, height: 80)
                    .shadow(color: KitchenColors.flameOrange.opacity(0.35), radius: 16, y: 8)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(.white)
            }
            .padding(.top, 16)
            
            Text("paywall.title")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text("paywall.subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Features
    
    private var featuresList: some View {
        VStack(spacing: 16) {
            featureRow(
                icon: "infinity.circle.fill",
                iconColor: KitchenColors.saffron,
                titleKey: "paywall.feature.unlimited_recipes",
                descKey: "paywall.feature.unlimited_recipes_desc"
            )
            
            featureRow(
                icon: "applewatch.radiowaves.left.and.right",
                iconColor: KitchenColors.flameOrange,
                titleKey: "paywall.feature.watch",
                descKey: "paywall.feature.watch_desc"
            )
            
            featureRow(
                icon: "mic.badge.waveform.fill",
                iconColor: KitchenColors.basilGreen,
                titleKey: "paywall.feature.voice",
                descKey: "paywall.feature.voice_desc"
            )
            
            featureRow(
                icon: "icloud.circle.fill",
                iconColor: .blue,
                titleKey: "paywall.feature.cloudkit",
                descKey: "paywall.feature.cloudkit_desc"
            )
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    @ViewBuilder
    private func featureRow(
        icon: String,
        iconColor: Color,
        titleKey: LocalizedStringKey,
        descKey: LocalizedStringKey
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(titleKey)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text(descKey)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Tarjeta de Pago Único ($4.99)
    
    private var pricingCard: some View {
        let priceString = storeKit.lifetimeProduct?.displayPrice ?? "4,99 €"
        
        return VStack(spacing: 10) {
            HStack {
                Text("paywall.product.lifetime_badge")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(KitchenColors.saffron)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                
                Spacer()
                
                Text(priceString)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(KitchenColors.flameOrange)
            }
            
            Divider()
            
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(KitchenColors.basilGreen)
                
                Text("paywall.product.no_subscriptions")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(KitchenColors.saffron.opacity(0.4), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    // MARK: - Purchase Button
    
    private var purchaseButton: some View {
        let priceString = storeKit.lifetimeProduct?.displayPrice ?? "4,99 €"
        
        return Button {
            handlePurchase()
        } label: {
            HStack(spacing: 8) {
                if storeKit.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "sparkles")
                    Text("\(String(localized: "paywall.unlock_button", comment: "Desbloquear")) (\(priceString))")
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(KitchenColors.primaryGradient())
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: KitchenColors.flameOrange.opacity(0.35), radius: 12, y: 6)
        }
        .disabled(storeKit.isLoading)
        .padding(.top, 4)
    }
    
    // MARK: - Legal & Restore Footer
    
    private var legalAndRestoreFooter: some View {
        VStack(spacing: 14) {
            Button {
                handleRestore()
            } label: {
                Text("paywall.restore_purchases")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 16) {
                Link(destination: URL(string: "https://kitchenflow.app/terms.html")!) {
                    Text("paywall.terms")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .underline()
                }
                
                Text("•")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                
                Link(destination: URL(string: "https://kitchenflow.app/privacy.html")!) {
                    Text("paywall.privacy")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .underline()
                }
            }
        }
        .padding(.top, 6)
    }
    
    // MARK: - Actions
    
    private func handlePurchase() {
        guard let product = storeKit.lifetimeProduct else {
            Task {
                await storeKit.loadProducts()
                if let reloaded = storeKit.lifetimeProduct {
                    let success = await storeKit.purchase(reloaded)
                    if success {
                        dismiss()
                    }
                }
            }
            return
        }
        
        Task {
            let success = await storeKit.purchase(product)
            if success {
                dismiss()
            }
        }
    }
    
    private func handleRestore() {
        Task {
            await storeKit.restorePurchases()
            if storeKit.isProUser {
                restoreAlertMessage = String(localized: "paywall.restore_success", comment: "Éxito")
            } else {
                restoreAlertMessage = String(localized: "paywall.restore_empty", comment: "Sin compras")
            }
            showingRestoreAlert = true
        }
    }
}
