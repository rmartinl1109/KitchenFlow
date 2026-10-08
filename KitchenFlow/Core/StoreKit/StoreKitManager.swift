import Foundation
import StoreKit
import SwiftUI

/// Identificadores oficiales de App Store y StoreKit para KitchenFlow.
enum KitchenFlowAppStoreConfig {
    static let appleAppId = "6819074326"
    static let proLifetimeProductID = "com.rmartinl1109.KitchenFlowPro"
    static let proLifetimeAppleId = "6819074505"
    
    static var appStoreURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appleAppId)")!
    }
    
    static var writeReviewURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appleAppId)?action=write-review")!
    }
}

/// Identificador del producto In-App Purchase de KitchenFlow (compra única de por vida).
enum KitchenFlowProductID {
    static let proLifetime = KitchenFlowAppStoreConfig.proLifetimeProductID
    
    static let allProductIDs: [String] = [
        proLifetime
    ]
}

/// Gestor nativo de compras de KitchenFlow mediante StoreKit 2.
@MainActor
@Observable
final class StoreKitManager {
    static let shared = StoreKitManager()
    
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs = Set<String>()
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    /// Producto de compra única de por vida
    var lifetimeProduct: Product? {
        products.first(where: { $0.id == KitchenFlowProductID.proLifetime })
    }
    
    /// Si el usuario dispone de KitchenFlow Pro desbloqueado de por vida
    var isProUser: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    private var transactionListener: Task<Void, Error>?
    
    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    /// Carga los productos de la App Store / StoreKit Configuration
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            print("🛒 [StoreKit] Solicitando productos para: \(KitchenFlowProductID.allProductIDs)...")
            let loadedProducts = try await Product.products(for: KitchenFlowProductID.allProductIDs)
            self.products = loadedProducts.sorted(by: { $0.price < $1.price })
            print("🛒 [StoreKit] Productos recibidos (\(loadedProducts.count)):")
            for prod in loadedProducts {
                print("   ✅ [StoreKit] Producto cargado: \(prod.id) - \(prod.displayName) (\(prod.displayPrice))")
            }
            if loadedProducts.isEmpty {
                print("   ⚠️ [StoreKit] La lista de productos vino VACÍA (0 productos).")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ [StoreKit] Error cargando productos: \(error.localizedDescription)")
        }
    }
    
    /// Realiza la compra de un producto
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedProducts()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// Restaura compras previas del usuario
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    /// Actualiza el estado de derechos del usuario consultando las transacciones actuales
    func updatePurchasedProducts() async {
        var purchased = Set<String>()
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            } catch {
                print("Failed entitlement verification: \(error)")
            }
        }
        
        self.purchasedProductIDs = purchased
    }
    
    /// Escucha transacciones emitidas fuera de la app (renovaciones, reembolsos, compras familiares)
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                } catch {
                    print("Transaction update verification failed: \(error)")
                }
            }
        }
    }
    
    /// Verifica criptográficamente que la transacción no esté manipulada
    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.networkError(URLError(.badServerResponse))
        case .verified(let safe):
            return safe
        }
    }
}
