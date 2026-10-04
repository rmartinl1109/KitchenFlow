import SwiftUI
import WidgetKit
import ActivityKit

/// Configuración del Widget de Live Activity y Dynamic Island para KitchenFlow.
struct CookingActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CookingActivityAttributes.self) { context in
            // Vista de Pantalla de Bloqueo / Banner
            CookingLockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Región Izquierda
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Text(context.attributes.recipeEmoji)
                            .font(.title3)
                        Text(context.attributes.recipeTitle)
                            .font(.subheadline.weight(.bold))
                            .lineLimit(1)
                    }
                }
                
                // Región Derecha: Temporizador
                DynamicIslandExpandedRegion(.trailing) {
                    let minutes = context.state.remainingSeconds / 60
                    let seconds = context.state.remainingSeconds % 60
                    Text(String(format: "%02d:%02d", minutes, seconds))
                        .font(.title2.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(KitchenColors.saffron)
                }
                
                // Región Inferior: Paso actual, avisos anidados y siguiente paso
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(context.state.stepTitle)
                                .font(.footnote.weight(.semibold))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if let next = context.state.nextStepTitle {
                                Text(
                                    String(
                                        format: NSLocalizedString("live_activity.next_step", comment: "Siguiente"),
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
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(KitchenColors.flameOrange)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                // Modo compacto lateral izquierdo
                CookingDynamicIslandViews.compactLeading(context: context)
            } compactTrailing: {
                // Modo compacto lateral derecho
                CookingDynamicIslandViews.compactTrailing(context: context)
            } minimal: {
                // Modo mínimo cuando hay varias Live Activities simultáneas
                CookingDynamicIslandViews.minimal(context: context)
            }
        }
    }
}
