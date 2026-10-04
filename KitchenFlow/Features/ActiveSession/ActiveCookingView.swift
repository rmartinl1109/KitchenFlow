import SwiftUI

/// Vista inmersiva para el seguimiento activo de una receta en la cocina.
struct ActiveCookingView: View {
    @Bindable var engine: CookingTimerEngine
    @Environment(\.dismiss) private var dismiss
    @AppStorage("keepScreenAwake") private var keepScreenAwake: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                if engine.sessionState == .completed {
                    completedView
                } else {
                    activeSessionContent
                }
            }
            .navigationTitle(engine.activeRecipe?.title ?? String(localized: "cooking.session.title", comment: "Título de la pantalla"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        engine.stopSession()
                        dismiss()
                    }) {
                        Label(
                            title: { Text("cooking.session.action_finish", comment: "Finalizar") },
                            icon: { Image(systemName: "xmark.circle.fill") }
                        )
                    }
                    .tint(.secondary)
                }
            }
            .onAppear {
                if keepScreenAwake {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
    
    // MARK: - Contenido Durante el Cocinado
    
    private var activeSessionContent: some View {
        VStack(spacing: 24) {
            // Cabecera con número de paso
            if let recipe = engine.activeRecipe, let step = engine.currentStep {
                VStack(spacing: 6) {
                    let stepNumber = engine.currentStepIndex + 1
                    let totalSteps = recipe.steps.count
                    Text(
                        String(
                            format: NSLocalizedString("cooking.session.step_progress", comment: "Progreso de paso"),
                            stepNumber,
                            totalSteps
                        )
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.0)
                    
                    Text(step.title)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 8)
            }
            
            // Notificación flotante de intervalo anidado (si se ha activado)
            if let notice = engine.currentIntervalNotice {
                HStack(spacing: 12) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title3)
                        .symbolEffect(.bounce, options: .repeating)
                        .foregroundStyle(.white)
                    
                    Text(
                        String(
                            format: NSLocalizedString("cooking.session.nested_interval_alert", comment: "Alerta de intervalo"),
                            notice
                        )
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            engine.dismissIntervalAlert()
                        }
                    }) {
                        Text("cooking.session.dismiss_alert", comment: "Entendido")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Capsule())
                            .foregroundStyle(.white)
                    }
                }
                .padding()
                .background(KitchenColors.flameOrange)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: KitchenColors.flameOrange.opacity(0.3), radius: 8, y: 4)
                .padding(.horizontal)
                .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
            
            // Reloj circular interactivo de fase
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 16)
                    .frame(width: 260, height: 260)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(engine.stepProgressFraction))
                    .stroke(
                        KitchenColors.primaryGradient(),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 260, height: 260)
                    .animation(.easeInOut(duration: 0.3), value: engine.stepProgressFraction)
                
                VStack(spacing: 4) {
                    if engine.sessionState == .waitingForManualAction {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(KitchenColors.saffron)
                        
                        Text("cooking.session.manual_wait_notice", comment: "Esperando confirmación")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    } else {
                        Text(engine.formattedRemainingTime)
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                        
                        let totalStr = engine.formattedOverallElapsed
                        Text(
                            String(
                                format: NSLocalizedString("cooking.session.elapsed_total", comment: "Tiempo total transcurrido"),
                                totalStr
                            )
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Indicador de próximo aviso de intervalo programado
            if let nextAlert = engine.nextIntervalAlertNotice {
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .foregroundStyle(KitchenColors.saffron)
                    Text("\(nextAlert.message) (\(nextAlert.secondsRemaining)s)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(Capsule())
            }
            
            // Instrucción detallada del paso
            if let step = engine.currentStep, !step.instructions.isEmpty {
                Text(step.instructions)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineLimit(3)
            }
            
            Spacer()
            
            // Botonera de control
            actionControls
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
    }
    
    // MARK: - Botonera de Control
    
    private var actionControls: some View {
        VStack(spacing: 14) {
            if engine.sessionState == .waitingForManualAction {
                Button(action: {
                    withAnimation {
                        engine.confirmManualStepDone()
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("cooking.session.confirm_action", comment: "Hecho, continuar")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(KitchenColors.basilGreen)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            } else {
                HStack(spacing: 16) {
                    // Botón Pausar / Reanudar
                    Button(action: {
                        withAnimation {
                            if engine.sessionState == .running {
                                engine.pause()
                            } else {
                                engine.resume()
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: engine.sessionState == .running ? "pause.fill" : "play.fill")
                            Text(
                                engine.sessionState == .running
                                ? "cooking.session.action_pause"
                                : "cooking.session.action_resume",
                                comment: "Pausar o reanudar"
                            )
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(KitchenColors.saffron)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    
                    // Botón Saltar Paso
                    Button(action: {
                        withAnimation {
                            engine.skipToNextStep()
                        }
                    }) {
                        HStack {
                            Image(systemName: "forward.fill")
                            Text("cooking.session.action_skip", comment: "Saltar paso")
                        }
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(uiColor: .tertiarySystemFill))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
        }
    }
    
    // MARK: - Vista de Plato Completado
    
    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("👨‍🍳")
                .font(.system(size: 90))
                .scaleEffect(1.1)
                .animation(.spring(bounce: 0.5), value: engine.sessionState)
            
            VStack(spacing: 8) {
                Text("cooking.session.completed_title", comment: "¡Buen provecho!")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                
                Text("cooking.session.completed_message", comment: "Completado")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            let totalStr = engine.formattedOverallElapsed
            Text(
                String(
                    format: NSLocalizedString("cooking.session.elapsed_total", comment: "Tiempo total"),
                    totalStr
                )
            )
            .font(.headline)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(KitchenColors.basilGreen.opacity(0.15))
            .foregroundStyle(KitchenColors.basilGreen)
            .clipShape(Capsule())
            
            Spacer()
            
            Button(action: {
                engine.stopSession()
                dismiss()
            }) {
                Text("cooking.session.back_to_recipes", comment: "Volver a recetas")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(KitchenColors.primaryGradient())
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
