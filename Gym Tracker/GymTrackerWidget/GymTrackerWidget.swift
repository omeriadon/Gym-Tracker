import WidgetKit
import ActivityKit
import SwiftUI

@main
struct GymTrackerWidgets: WidgetBundle {
    var body: some Widget {
        WorkoutActivityConfiguration()
    }
}

struct WorkoutActivityConfiguration: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutAttributes.self) { context in
            // Lock Screen/Banner UI
            WorkoutLiveActivityView(context: context)
                .activitySystemActionForegroundColor(.indigo)
                .activityBackgroundTint(.purple.opacity(0.2))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.workoutName, systemImage: "figure.run")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(formatDuration(context.state.duration))
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        if let exercise = context.state.currentExerciseName {
                            Text(exercise)
                                .font(.subheadline)
                        }
                        Spacer()
                        Text("Sets: \(context.state.setCount)")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Label("Workout", systemImage: "figure.run")
                    .font(.caption2)
            } compactTrailing: {
                Text(formatDuration(context.state.duration))
                    .font(.caption2)
                    .monospacedDigit()
            } minimal: {
                Label("", systemImage: "figure.run")
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}