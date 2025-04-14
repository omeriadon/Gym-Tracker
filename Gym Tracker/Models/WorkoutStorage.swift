import SwiftUI
import SwiftData

@Observable
class WorkoutStorage {
    var activeWorkout: Workout?
    private var modelContext: ModelContext?
    
    static let shared = WorkoutStorage()

    private init() {}
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func saveWorkoutState() {
        guard let modelContext = modelContext else {
            print("Model context not set")
            return
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save workout state: \(error)")
        }
    }
    
    func insertWorkout(_ workout: Workout) {
        guard let modelContext = modelContext else {
            print("Model context not set")
            return
        }
        
        modelContext.insert(workout)
        saveWorkoutState()
    }

    func deleteWorkout(_ workout: Workout) {
        guard let modelContext = modelContext else {
            print("Model context not set")
            return
        }
        
        modelContext.delete(workout)
        saveWorkoutState()
    }
    
    func clearActiveWorkout() {
        activeWorkout = nil
        saveWorkoutState()
    }
}
