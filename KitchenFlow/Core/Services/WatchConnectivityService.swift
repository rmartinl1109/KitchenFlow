import Foundation
import WatchConnectivity
import Combine

/// Servicio centralizado de conectividad bidireccional entre iPhone y Apple Watch (WCSession).
@MainActor
public final class WatchConnectivityService: NSObject, ObservableObject {
    public static let shared = WatchConnectivityService()
    
    @Published public private(set) var latestSnapshot: CookingSessionSnapshot = .idle
    @Published public private(set) var isWatchAppInstalled: Bool = false
    @Published public private(set) var isReachable: Bool = false
    
    /// Callback para ejecutar comandos recibidos desde el dispositivo remoto (ej. Apple Watch -> iPhone)
    public var onCommandReceived: ((WatchCookingCommand) -> Void)?
    
    /// Callback para responder a peticiones de sincronización inmediata desde el Watch
    public var onSyncRequested: (() -> CookingSessionSnapshot?)?
    
    private var session: WCSession?
    
    private override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }
    
    // MARK: - Envío de Datos (iPhone -> Watch)
    
    /// Envía una instantánea del estado de cocinado actual hacia el Apple Watch
    public func sendSnapshot(_ snapshot: CookingSessionSnapshot) {
        self.latestSnapshot = snapshot
        guard let session = session, session.activationState == .activated else { return }
        
        #if os(iOS)
        self.isWatchAppInstalled = session.isWatchAppInstalled
        guard session.isWatchAppInstalled else { return }
        #endif
        
        do {
            let data = try JSONEncoder().encode(snapshot)
            let message: [String: Any] = ["snapshot": data]
            
            // 1. Contexto de aplicación persistente de fondo
            try session.updateApplicationContext(message)
            
            // 2. Si el Watch está accesible en directo, enviar de inmediato
            if session.isReachable {
                session.sendMessage(message, replyHandler: nil) { error in
                    #if DEBUG
                    print("[WatchConnectivity] Error enviando mensaje en tiempo real: \(error.localizedDescription)")
                    #endif
                }
            }
        } catch {
            #if DEBUG
            print("[WatchConnectivity] Fallo al codificar CookingSessionSnapshot: \(error)")
            #endif
        }
    }
    
    // MARK: - Envío de Comandos (Watch -> iPhone)
    
    /// Envía un comando desde el Apple Watch para controlar la sesión en el iPhone
    public func sendCommand(_ command: WatchCookingCommand) {
        guard let session = session, session.activationState == .activated else { return }
        
        let message: [String: Any] = ["command": command.rawValue]
        
        if session.isReachable {
            session.sendMessage(message, replyHandler: { reply in
                // Si el iPhone responde con un snapshot actualizado, lo procesamos
                if let data = reply["snapshot"] as? Data,
                   let snapshot = try? JSONDecoder().decode(CookingSessionSnapshot.self, from: data) {
                    Task { @MainActor in
                        self.latestSnapshot = snapshot
                    }
                }
            }) { error in
                #if DEBUG
                print("[WatchConnectivity] Error al enviar comando \(command): \(error.localizedDescription)")
                #endif
            }
        } else {
            // Transferencia en segundo plano garantizada
            session.transferUserInfo(message)
        }
    }
    
    /// Solicita al iPhone el estado actual inmediatamente
    public func requestSyncFromPhone() {
        sendCommand(.requestSync)
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityService: WCSessionDelegate {
    public nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            #if os(iOS)
            self.isWatchAppInstalled = session.isWatchAppInstalled
            #endif
            self.isReachable = session.isReachable
        }
    }
    
    #if os(iOS)
    public nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    
    public nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // Reactivar la sesión si el usuario cambia de Apple Watch
        session.activate()
    }
    
    public nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isWatchAppInstalled = session.isWatchAppInstalled
            self.isReachable = session.isReachable
        }
    }
    #endif
    
    public nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isReachable = session.isReachable
        }
    }
    
    // MARK: Recepción de Contexto (Background)
    public nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            self.processIncomingData(applicationContext)
        }
    }
    
    // MARK: Recepción de Mensaje (Realtime)
    public nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            self.processIncomingData(message)
        }
    }
    
    public nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        // Si se recibe un comando de sync o control, contestar
        if let rawCommand = message["command"] as? String,
           let command = WatchCookingCommand(rawValue: rawCommand) {
            Task { @MainActor in
                if command == .requestSync, let snapshot = self.onSyncRequested?() {
                    if let data = try? JSONEncoder().encode(snapshot) {
                        replyHandler(["snapshot": data])
                        return
                    }
                }
                self.onCommandReceived?(command)
                replyHandler(["status": "ok"])
            }
        } else {
            Task { @MainActor in
                self.processIncomingData(message)
                replyHandler(["status": "received"])
            }
        }
    }
    
    // MARK: Recepción de UserInfo (Garantizada)
    public nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        Task { @MainActor in
            self.processIncomingData(userInfo)
        }
    }
    
    private func processIncomingData(_ payload: [String: Any]) {
        // 1. Procesar snapshot
        if let data = payload["snapshot"] as? Data {
            if let snapshot = try? JSONDecoder().decode(CookingSessionSnapshot.self, from: data) {
                self.latestSnapshot = snapshot
            }
        }
        
        // 2. Procesar comando
        if let rawCommand = payload["command"] as? String,
           let command = WatchCookingCommand(rawValue: rawCommand) {
            self.onCommandReceived?(command)
        }
    }
}
