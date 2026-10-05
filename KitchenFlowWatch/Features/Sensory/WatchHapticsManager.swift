import Foundation
#if os(watchOS)
import WatchKit
#endif

/// Motor sensorial y háptico optimizado para entornos de cocina ruidosos.
@MainActor
public final class WatchHapticsManager {
    public static let shared = WatchHapticsManager()
    
    private init() {}
    
    /// Alerta háptica de aviso de intervalo periódico (ej. "Remover sofrito")
    public func playIntervalAlert() {
        #if os(watchOS)
        let device = WKInterfaceDevice.current()
        device.play(.directionUp)
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s
            device.play(.directionUp)
        }
        #endif
    }
    
    /// Alerta de finalización de paso con repetición distintiva
    public func playStepCompleted() {
        #if os(watchOS)
        let device = WKInterfaceDevice.current()
        device.play(.notification)
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            device.play(.notification)
            try? await Task.sleep(nanoseconds: 300_000_000)
            device.play(.notification)
        }
        #endif
    }
    
    /// Alerta de receta completamente finalizada
    public func playRecipeCompleted() {
        #if os(watchOS)
        let device = WKInterfaceDevice.current()
        device.play(.success)
        #endif
    }
    
    /// Toque sutil para confirmación táctil de botones (Play / Pausa)
    public func playButtonFeedback() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }
}
