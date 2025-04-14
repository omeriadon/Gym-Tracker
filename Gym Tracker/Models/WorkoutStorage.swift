import SwiftUI
import SwiftData

// A simple singleton to handle workout storage
class WorkoutStorage {
    static let shared = WorkoutStorage()
    
    private init() {}
    
    func saveWorkout(_ workout: Workout) {
        Task { @MainActor in
            do {
                let modelContainer = try ModelContainer(for: Workout.self)
                let context = modelContainer.mainContext
                
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
                
                context.insert(newWorkout)
                try context.save()
                print("Workout saved successfully: \(workout.name)")
            } catch {
                print("Failed to save workout: \(error.localizedDescription)")
            }
        }
    }
}
