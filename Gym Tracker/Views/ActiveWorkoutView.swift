import SwiftUI

struct ActiveWorkoutView: View {
    @Environment(WorkoutManager.self) private var workoutManager
    @State private var showingNewWorkoutSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let workout = workoutManager.activeWorkout {
                    // Active workout view
                    VStack {
                        Text("Active Workout: \(workout.name)")
                            .font(.headline)
                        
                        // TODO: Add exercise list, timer, and other workout controls
                        
                        Spacer()
                    }
                } else {
                    // No active workout view
                    VStack {
                        Text("No Active Workout")
                            .font(.headline)
                            .padding()
                        
                        Button("Start New Workout") {
                            showingNewWorkoutSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Workout")
            .sheet(isPresented: $showingNewWorkoutSheet) {
                // TODO: Add proper new workout form
                VStack {
                    Text("New Workout")
                        .font(.headline)
                        .padding()
                    
                    Button("Start Default Workout") {
                        workoutManager.startWorkout()
                        showingNewWorkoutSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Cancel", role: .cancel) {
                        showingNewWorkoutSheet = false
                    }
                    .padding()
                }
                .presentationDetents([.height(200)])
            }
        }
    }
}