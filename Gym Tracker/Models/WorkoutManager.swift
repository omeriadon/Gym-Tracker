import Foundation
import ActivityKit
import SwiftUI
import SwiftData

@Observable
class WorkoutManager {
    var activeWorkout: Workout?
    var workoutStartTime: Date?
    private var appTimer: Timer?
    private var liveActivityTimer: Timer?
    private var liveActivity: Activity<WorkoutAttributes>?



    init() {
        // Initialize any needed properties
    }
    
    func startWorkout(name: String = "New Workout") {
        let workout = Workout(
            id: UUID(),
            name: name,
            date: Date(),
            duration: 0,
            notes: "",
            exerciseSets: [],
            isActive: true
        )
        
        self.activeWorkout = workout
        self.workoutStartTime = Date()
        startTimers()
        
        // Only try to start Live Activity if supported
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            startLiveActivity(workout: workout)
        }
    }
    
    @MainActor func endWorkout() {
        guard let workout = activeWorkout else { return }

        // Ensure the duration is set correctly before ending the workout
        workout.duration = Date().timeIntervalSince(workoutStartTime ?? Date())
        
        // Save using WorkoutStorage which creates a new instance
        WorkoutStorage.shared.saveWorkout(workout)

        activeWorkout?.isActive = false
        activeWorkout = nil
        workoutStartTime = nil

        appTimer?.invalidate()
        appTimer = nil
        liveActivityTimer?.invalidate()
        liveActivityTimer = nil

        if let _ = liveActivity {
            endLiveActivity()
        }
    }
    
    private func startTimers() {
        // App timer updates every second
        appTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self,
                  let startTime = self.workoutStartTime else { return }
            
            let duration = Date().timeIntervalSince(startTime)
            self.activeWorkout?.duration = duration
        }
        
        // Live activity timer updates every 5 seconds
        liveActivityTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self,
                  let startTime = self.workoutStartTime,
                  let _ = liveActivity else { return }
            
            let duration = Date().timeIntervalSince(startTime)
            self.updateLiveActivity(duration: duration)
        }
    }
    
    private func startLiveActivity(workout: Workout) {
        let attributes = WorkoutAttributes(
            workoutName: workout.name,
            workoutId: workout.id
        )
        
        let initialState = WorkoutAttributes.ContentState(
            duration: 0,
            currentExerciseName: nil,
            setCount: 0,
            status: "Started"
        )
        
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            liveActivity = try Activity.request(
                attributes: attributes,
                content: content
            )
        } catch {
            print("Error starting live activity: \(error.localizedDescription)")
            liveActivity = nil
        }
    }
    
    private func updateLiveActivity(duration: TimeInterval) {
        guard let liveActivity = liveActivity,
              let workout = activeWorkout else { return }
        
        let state = WorkoutAttributes.ContentState(
            duration: duration,
            currentExerciseName: workout.exerciseSets.last?.excersize.name,
            setCount: workout.exerciseSets.count,
            status: "In Progress"
        )
        
        Task {
            await liveActivity.update(ActivityContent(state: state, staleDate: nil))
        }
    }
    
    private func endLiveActivity() {
        guard let liveActivity = liveActivity,
              let workout = activeWorkout else { return }
        
        let finalState = WorkoutAttributes.ContentState(
            duration: workout.duration,
            currentExerciseName: nil,
            setCount: workout.exerciseSets.count,
            status: "Completed"
        )
        
        Task {
            await liveActivity.end(ActivityContent(state: finalState, staleDate: nil),
                                 dismissalPolicy: .default)
        }
        
        self.liveActivity = nil
    }
}
