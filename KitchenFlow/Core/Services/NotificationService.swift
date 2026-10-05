import Foundation
import UserNotifications

/// Gestor de notificaciones locales ricas e interactivas para KitchenFlow.
@MainActor
final class NotificationService {
    static let shared = NotificationService()
    
    static let categoryStepCompleted = "KITCHENFLOW_STEP_COMPLETED"
    static let actionNextStep = "KITCHENFLOW_ACTION_NEXT_STEP"
    
    private init() {
        setupNotificationCategories()
    }
    
    /// Solicita permisos de notificación al usuario
    func requestAuthorization() {
        if ProcessInfo.processInfo.arguments.contains("-screenshot-mode") ||
           ProcessInfo.processInfo.arguments.contains("-screen-active-cooking") {
            return
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
        }
    }
    
    /// Configura acciones interactivas para las notificaciones
    private func setupNotificationCategories() {
        let nextStepActionTitle = NSLocalizedString("notifications.action.next_step", comment: "Siguiente paso")
        let nextStepAction = UNNotificationAction(
            identifier: Self.actionNextStep,
            title: nextStepActionTitle,
            options: [.foreground]
        )
        
        let stepCompletedCategory = UNNotificationCategory(
            identifier: Self.categoryStepCompleted,
            actions: [nextStepAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([stepCompletedCategory])
    }
    
    /// Envía aviso de que un paso/fase ha terminado
    func notifyStepCompleted(stepTitle: String, nextAction: String) {
        let content = UNMutableNotificationContent()
        
        let titleFormat = NSLocalizedString("notifications.step_completed.title", comment: "Paso completado")
        content.title = String(format: titleFormat, stepTitle)
        
        let bodyFormat = NSLocalizedString("notifications.step_completed.body", comment: "Siguiente acción")
        content.body = String(format: bodyFormat, nextAction)
        
        content.sound = .default
        content.categoryIdentifier = Self.categoryStepCompleted
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Inmediato
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Envía aviso de recordatorio periódico anidado (ej. "Remover sofrito")
    func notifyIntervalAlert(recipeTitle: String, alertMessage: String) {
        let content = UNMutableNotificationContent()
        
        content.title = NSLocalizedString("notifications.interval_alert.title", comment: "Aviso de cocina")
        
        let bodyFormat = NSLocalizedString("notifications.interval_alert.body", comment: "Cuerpo de aviso")
        content.body = String(format: bodyFormat, recipeTitle, alertMessage)
        
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Cancela notificaciones pendientes
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
