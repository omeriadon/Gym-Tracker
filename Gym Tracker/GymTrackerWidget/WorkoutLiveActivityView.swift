import SwiftUI
import WidgetKit
import ActivityKit

struct WorkoutLiveActivityView: View {
    let context: ActivityViewContext<WorkoutAttributes>
    
    private var duration: TimeInterval { context.state.duration }
    private var setCount: Int { context.state.setCount }
    private var currentExercise: String? { context.state.currentExerciseName }
    
    var body: some View {
        VStack {
            HStack {
                Label(context.attributes.workoutName, systemImage: "figure.run")
                    .font(.headline)
                Spacer()
                Text(formatDuration(duration))
                    .font(.system(.body, design: .monospaced))
            }
            
            if let exercise = currentExercise {
                Text(exercise)
                    .font(.subheadline)
            }
            
            Text("Sets completed: \(setCount)")
                .font(.caption)
        }
        .padding()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}