import WidgetKit
import SwiftUI

/// Proveedor de datos para las complicaciones de KitchenFlow en Apple Watch.
struct CookingComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> CookingComplicationEntry {
        CookingComplicationEntry(
            date: Date(),
            snapshot: CookingSessionSnapshot(
                recipeTitle: "Risotto",
                recipeEmoji: "🥘",
                stepTitle: "Sofreír cebolla",
                stepInstruction: "Remover a fuego lento",
                stepIndex: 1,
                totalSteps: 4,
                remainingSeconds: 270,
                stepDurationSeconds: 300,
                isPaused: false,
                isCompleted: false,
                isWaitingConfirmation: false,
                intervalNotice: "Remover sofrito",
                nextStepTitle: "Añadir arroz"
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CookingComplicationEntry) -> Void) {
        let entry = CookingComplicationEntry(
            date: Date(),
            snapshot: WatchConnectivityService.shared.latestSnapshot
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CookingComplicationEntry>) -> Void) {
        let entry = CookingComplicationEntry(
            date: Date(),
            snapshot: WatchConnectivityService.shared.latestSnapshot
        )
        // Actualizar cada minuto si no hay cambios activos
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

/// Entrada de datos para la complicación.
struct CookingComplicationEntry: TimelineEntry {
    let date: Date
    let snapshot: CookingSessionSnapshot
}

/// Complicación nativa para esferas de watchOS.
struct CookingComplicationWidget: Widget {
    let kind: String = "KitchenFlowCookingComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CookingComplicationProvider()) { entry in
            CookingComplicationView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.clear
                }
        }
        .configurationDisplayName("complication.cooking.display_name")
        .description("complication.cooking.description")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

/// Vista adaptable según la familia de complicación elegida en la esfera.
struct CookingComplicationView: View {
    let entry: CookingComplicationEntry
    @Environment(\.widgetFamily) var family

    private var snapshot: CookingSessionSnapshot {
        entry.snapshot
    }

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryCorner:
            cornerView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        @unknown default:
            circularView
        }
    }

    // MARK: - Circular (Gauge con progreso y emoji/minutos)
    private var circularView: some View {
        ZStack {
            if snapshot.isActive {
                Gauge(value: snapshot.progressFraction) {
                    Text(snapshot.recipeEmoji)
                } currentValueLabel: {
                    Text(String(format: "%d'", max(1, snapshot.remainingSeconds / 60)))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(KitchenColors.flameOrange)
            } else {
                Gauge(value: 0.0) {
                    Image(systemName: "timer")
                } currentValueLabel: {
                    Text("KF")
                        .font(.system(size: 10, weight: .bold))
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(KitchenColors.saffron)
            }
        }
    }

    // MARK: - Corner (Esquinas en esferas analógicas)
    private var cornerView: some View {
        if snapshot.isActive {
            Text(snapshot.formattedRemainingTime)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .widgetLabel {
                    Text("\(snapshot.recipeEmoji) \(snapshot.stepTitle)")
                }
        } else {
            Text("KitchenFlow")
                .widgetLabel {
                    Text("🍳 Listo")
                }
        }
    }

    // MARK: - Rectangular (Complicación modular rica)
    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            if snapshot.isActive {
                HStack(spacing: 4) {
                    Text(snapshot.recipeEmoji)
                        .font(.caption2)
                    Text(snapshot.recipeTitle)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    Spacer()
                    Text(snapshot.formattedRemainingTime)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(KitchenColors.flameOrange)
                }
                
                Text(snapshot.stepTitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                ProgressView(value: snapshot.progressFraction)
                    .tint(KitchenColors.flameOrange)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "frying.pan.fill")
                        .foregroundStyle(KitchenColors.saffron)
                    Text("KitchenFlow")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
                Text("complication.idle_label")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Inline (Texto lineal superior)
    private var inlineView: some View {
        if snapshot.isActive {
            Text("\(snapshot.recipeEmoji) \(snapshot.formattedRemainingTime) · \(snapshot.stepTitle)")
        } else {
            Text("KitchenFlow 🍳")
        }
    }
}
