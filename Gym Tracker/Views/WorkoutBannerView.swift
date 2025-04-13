import SwiftUI

struct WorkoutBannerView: View {
    @Environment(WorkoutManager.self) private var workoutManager
    
    var body: some View {
        if let workout = workoutManager.activeWorkout {
            VStack {
                HStack {
                    Text(workout.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(formatDuration(workout.duration))
                        .font(.subheadline)
                        .monospacedDigit()
                    
                    Button("End") {
                        workoutManager.endWorkout()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding()
            }
            .background(.ultraThinMaterial)
        }
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