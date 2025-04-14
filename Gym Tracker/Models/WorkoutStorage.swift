import SwiftUI
import SwiftData

// A simple singleton to handle workout storage
class WorkoutStorage {
    static let shared = WorkoutStorage(modelContext: EnvironmentValues().modelContext)
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveWorkout(_ workout: Workout) {
        Task { @MainActor in
            do {
                // Create a new workout instance in the context
                let newWorkout = Workout(
                    id: workout.id,
                    name: workout.name,
                    date: workout.date,
                    duration: workout.duration,
                    notes: workout.notes,
                    exerciseSets: workout.exerciseSets,
                    isActive: false
                )
                
                modelContext.insert(newWorkout)
                try modelContext.save()
                print("Workout saved successfully: \(workout.name)")
            } catch {
                print("Failed to save workout: \(error.localizedDescription)")
            }
        }
    }
}
