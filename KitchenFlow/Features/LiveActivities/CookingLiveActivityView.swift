import SwiftUI
import WidgetKit
import ActivityKit

/// Interfaz visual de la Live Activity para la Pantalla de Bloqueo y la Dynamic Island.
struct CookingLockScreenLiveActivityView: View {
    let context: ActivityViewContext<CookingActivityAttributes>
    
    private var formattedTime: String {
        let minutes = context.state.remainingSeconds / 60
        let seconds = context.state.remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cabecera: Receta y Paso
            HStack(alignment: .center, spacing: 8) {
                Text(context.attributes.recipeEmoji)
                    .font(.title3)
                
                Text(context.attributes.recipeTitle)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                
                Spacer()
                
                let stepNumber = context.state.currentStepIndex + 1
                let totalSteps = context.attributes.totalStepsCount
                Text(
                    String(
                        format: NSLocalizedString("cooking.session.step_progress", comment: "Paso X de Y"),
                        stepNumber,
                        totalSteps
                    )
                )
                .font(.caption2.weight(.bold))
                .foregroundStyle(KitchenColors.saffron)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(KitchenColors.saffron.opacity(0.15))
                .clipShape(Capsule())
            }
            
            // Cuerpo Principal: Paso actual y Dial
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.stepTitle)
                        .font(.headline.weight(.semibold))
                        .lineLimit(2)
                    
                    if context.state.isPaused {
                        Text("live_activity.paused", comment: "Pausado")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.orange)
                    } else if context.state.requiresManualConfirmation && context.state.remainingSeconds == 0 {
                        Text("cooking.session.manual_wait_notice", comment: "Esperando confirmación")
                            .font(.caption)
                            .foregroundStyle(KitchenColors.saffron)
                    } else if let next = context.state.nextStepTitle {
                        Text(
                            String(
                                format: NSLocalizedString("live_activity.next_step", comment: "Siguiente paso"),
                                next
                            )
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Temporizador circular compacto
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 6)
                        .frame(width: 58, height: 58)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(context.state.stepProgressFraction))
                        .stroke(
                            KitchenColors.primaryGradient(),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 58, height: 58)
                    
                    Text(formattedTime)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
            }
            
            // Alerta de intervalo anidado (si se ha disparado)
            if let notice = context.state.intervalNotice {
                HStack(spacing: 8) {
                    Image(systemName: "bell.badge.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                    
                    Text(notice)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(KitchenColors.flameOrange)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
    }
}

/// Contenedor de la Dynamic Island en sus diferentes modos de presentación.
struct CookingDynamicIslandViews {
    static func compactLeading(context: ActivityViewContext<CookingActivityAttributes>) -> some View {
        HStack(spacing: 4) {
            Text(context.attributes.recipeEmoji)
                .font(.caption)
            Text("P\(context.state.currentStepIndex + 1)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(KitchenColors.saffron)
        }
    }
    
    static func compactTrailing(context: ActivityViewContext<CookingActivityAttributes>) -> some View {
        let minutes = context.state.remainingSeconds / 60
        let seconds = context.state.remainingSeconds % 60
        let timeStr = String(format: "%02d:%02d", minutes, seconds)
        return Text(timeStr)
            .font(.caption.weight(.bold))
            .monospacedDigit()
            .foregroundStyle(KitchenColors.saffron)
    }
    
    static func minimal(context: ActivityViewContext<CookingActivityAttributes>) -> some View {
        Text(context.attributes.recipeEmoji)
            .font(.caption)
    }
    
    @ViewBuilder
    static func expanded(context: ActivityViewContext<CookingActivityAttributes>) -> some View {
        let minutes = context.state.remainingSeconds / 60
        let seconds = context.state.remainingSeconds % 60
        let timeStr = String(format: "%02d:%02d", minutes, seconds)
        
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Text(context.attributes.recipeEmoji)
                        .font(.title3)
                    Text(context.attributes.recipeTitle)
                        .font(.subheadline.weight(.bold))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(timeStr)
                    .font(.title2.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(KitchenColors.saffron)
            }
            
            HStack {
                Text(context.state.stepTitle)
                    .font(.footnote.weight(.medium))
                    .lineLimit(1)
                
                Spacer()
                
                if let next = context.state.nextStepTitle {
                    Text(
                        String(
                            format: NSLocalizedString("live_activity.next_step", comment: "Siguiente paso"),
                            next
                        )
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                }
            }
            
            if let notice = context.state.intervalNotice {
                HStack(spacing: 6) {
                    Image(systemName: "bell.fill")
                        .font(.caption2)
                        .foregroundStyle(.white)
                    Text(notice)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(KitchenColors.flameOrange)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
