import SwiftUI

/// Vista principal inmersiva de cocinado guiado en Apple Watch (Función Pro).
struct WatchCookingView: View {
    @ObservedObject private var connectivity = WatchConnectivityService.shared
    
    @State private var previousIntervalNotice: String?
    @State private var previousStepIndex: Int = 0
    @State private var hasPlayedCompletionHaptic: Bool = false
    
    private var snapshot: CookingSessionSnapshot {
        connectivity.latestSnapshot
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if !snapshot.isProUser && snapshot.isActive {
                    proLockedView
                } else if snapshot.isCompleted {
                    completedView
                } else if snapshot.isActive {
                    activeSessionView
                } else {
                    idleView
                }
            }
            .navigationTitle("KitchenFlow")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                connectivity.requestSyncFromPhone()
            }
            .onChange(of: snapshot.intervalNotice) { oldValue, newValue in
                guard snapshot.isProUser else { return }
                if let notice = newValue, notice != previousIntervalNotice {
                    previousIntervalNotice = notice
                    WatchHapticsManager.shared.playIntervalAlert()
                }
            }
            .onChange(of: snapshot.stepIndex) { oldValue, newValue in
                guard snapshot.isProUser else { return }
                if newValue != previousStepIndex {
                    previousStepIndex = newValue
                    WatchHapticsManager.shared.playStepCompleted()
                }
            }
            .onChange(of: snapshot.isCompleted) { oldValue, newValue in
                guard snapshot.isProUser else { return }
                if newValue && !hasPlayedCompletionHaptic {
                    hasPlayedCompletionHaptic = true
                    WatchHapticsManager.shared.playRecipeCompleted()
                } else if !newValue {
                    hasPlayedCompletionHaptic = false
                }
            }
        }
    }
    
    // MARK: - Estado: Función Exclusiva Pro
    
    private var proLockedView: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(KitchenColors.primaryGradient())
                    .frame(width: 44, height: 44)
                
                Image(systemName: "crown.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .padding(.top, 2)
            
            Text("watch.pro.title")
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("watch.pro.subtitle")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
            
            HStack(spacing: 4) {
                Image(systemName: "iphone.radiowaves.left.and.right")
                    .font(.caption2)
                Text("watch.pro.unlock_hint")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(KitchenColors.saffron)
            .padding(.top, 4)
            
            Button {
                WatchHapticsManager.shared.playButtonFeedback()
                connectivity.requestSyncFromPhone()
            } label: {
                Label("watch.action.refresh_sync", systemImage: "arrow.clockwise")
                    .font(.system(size: 10))
            }
            .buttonStyle(.bordered)
            .padding(.top, 4)
        }
        .padding(6)
    }
    
    // MARK: - Estado: Sesión Activa (Pro)
    
    private var activeSessionView: some View {
        VStack(spacing: 8) {
            // Cabecera: Receta y progreso de pasos
            HStack {
                Text(snapshot.recipeEmoji)
                    .font(.caption)
                Text(snapshot.recipeTitle)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Spacer()
                Text(verbatim: "\(snapshot.stepIndex + 1)/\(snapshot.totalSteps)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
            
            // Anillo de progreso central con tiempo
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.12), lineWidth: 7)
                
                Circle()
                    .trim(from: 0, to: CGFloat(snapshot.progressFraction))
                    .stroke(
                        KitchenColors.primaryGradient(),
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: snapshot.remainingSeconds)
                
                VStack(spacing: 2) {
                    Text(snapshot.formattedRemainingTime)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(snapshot.isPaused ? Color.orange : Color.white)
                    
                    Text(snapshot.stepTitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }
            .frame(width: 124, height: 124)
            .padding(.vertical, 2)
            
            // Banner de Alerta de Intervalo (ej. remover sofrito)
            if let alert = snapshot.intervalNotice {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "bell.badge.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text(alert)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                    }
                    
                    Button {
                        WatchHapticsManager.shared.playButtonFeedback()
                        connectivity.sendCommand(.dismissInterval)
                    } label: {
                        Text("watch.action.dismiss_interval")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.yellow.opacity(0.35))
                    .frame(height: 24)
                }
                .padding(6)
                .background(Color.yellow.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Próximo paso si existe
            if let next = snapshot.nextStepTitle, !next.isEmpty {
                HStack(spacing: 4) {
                    Text("watch.label.next_step_prefix")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    Text(next)
                        .font(.system(size: 10, weight: .medium))
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                }
                .padding(.top, 2)
            }
            
            // Botones de Control de Cocinado
            HStack(spacing: 12) {
                // Play / Pause
                Button {
                    WatchHapticsManager.shared.playButtonFeedback()
                    if snapshot.isPaused {
                        connectivity.sendCommand(.resume)
                    } else {
                        connectivity.sendCommand(.pause)
                    }
                } label: {
                    Image(systemName: snapshot.isPaused ? "play.fill" : "pause.fill")
                        .font(.title3)
                }
                .tint(snapshot.isPaused ? KitchenColors.basilGreen : KitchenColors.flameOrange)
                
                // Siguiente Paso
                Button {
                    WatchHapticsManager.shared.playButtonFeedback()
                    connectivity.sendCommand(.nextStep)
                } label: {
                    Image(systemName: "forward.end.fill")
                        .font(.title3)
                }
                .tint(Color.white.opacity(0.2))
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
    }
    
    // MARK: - Estado: Receta Completada
    
    private var completedView: some View {
        VStack(spacing: 8) {
            Text(verbatim: "🎉")
                .font(.system(size: 40))
            
            Text("watch.completed.title")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("watch.completed.subtitle")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                WatchHapticsManager.shared.playButtonFeedback()
                connectivity.sendCommand(.requestSync)
            } label: {
                Text("watch.action.done")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(KitchenColors.basilGreen)
            .padding(.top, 6)
        }
        .padding()
    }
    
    // MARK: - Estado: Inactivo / Esperando iPhone
    
    private var idleView: some View {
        VStack(spacing: 10) {
            Image(systemName: "frying.pan.fill")
                .font(.system(size: 36))
                .foregroundStyle(KitchenColors.saffron)
            
            Text("watch.idle.title")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("watch.idle.subtitle")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
            
            Button {
                WatchHapticsManager.shared.playButtonFeedback()
                connectivity.requestSyncFromPhone()
            } label: {
                Label("watch.action.refresh_sync", systemImage: "arrow.clockwise")
                    .font(.caption2)
            }
            .buttonStyle(.bordered)
            .padding(.top, 4)
        }
        .padding()
    }
}
