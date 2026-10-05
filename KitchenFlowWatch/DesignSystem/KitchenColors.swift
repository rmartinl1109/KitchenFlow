import SwiftUI

/// Sistema de colores temático gastronómico para KitchenFlowWatch.
enum KitchenColors {
    static let saffron = Color(red: 0.95, green: 0.58, blue: 0.12)
    static let flameOrange = Color(red: 0.96, green: 0.38, blue: 0.18)
    static let basilGreen = Color(red: 0.22, green: 0.68, blue: 0.42)
    static let charcoal = Color(red: 0.12, green: 0.14, blue: 0.17)
    
    static func primaryGradient() -> LinearGradient {
        LinearGradient(
            colors: [saffron, flameOrange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
