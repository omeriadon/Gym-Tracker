import Foundation
import ActivityKit
import SwiftUI
import SwiftData

class WorkoutManager: ObservableObject {
    static let shared = WorkoutManager()
    
    @Published var activeWorkout: Workout?
    @Published var workoutStartTime: Date?
    var appTimer: Timer?
    var liveActivityTimer: Timer?
    var liveActivity: Activity<WorkoutAttributes>?
    
    init() {
        // Check if there's an active workout when initializing
        if let existingWorkout = WorkoutStorage.shared.activeWorkout, existingWorkout.isActive {
            self.activeWorkout = existingWorkout
            self.workoutStartTime = existingWorkout.date
            startTimers()
            
            if ActivityAuthorizationInfo().areActivitiesEnabled {
                startLiveActivity(workout: existingWorkout)
            }
        }
    }
    
    func getDefaultWorkoutName() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
    
    @MainActor func startWorkout(name: String? = nil) {
        // End any existing workout first
        if activeWorkout != nil {
            endWorkout()
        }
        
        let workout = Workout(
            id: UUID(),
            name: name ?? getDefaultWorkoutName(),
            date: Date(),
            duration: 0,
            notes: "",
            exercizeSets: [],
            isActive: true
        )
        
        self.activeWorkout = workout
        self.workoutStartTime = Date()
        startTimers()
        
        // Only try to start Live Activity if supported
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            startLiveActivity(workout: workout)
        }
        
        WorkoutStorage.shared.activeWorkout = workout
        WorkoutStorage.shared.saveWorkoutState()
    }
    
    @MainActor func endWorkout() {
        guard let workout = activeWorkout, workout.isActive else {
            print("No active workout to end or workout already inactive.")
            return
        }

        // Ensure the duration is set correctly before ending the workout
        workout.duration = Date().timeIntervalSince(workoutStartTime ?? Date())
        workout.isActive = false
        
        // Save the workout first before clearing state
        WorkoutStorage.shared.insertWorkout(workout)

        // Clear state
        activeWorkout = nil
        workoutStartTime = nil
        WorkoutStorage.shared.clearActiveWorkout()

        // Clean up timers
        appTimer?.invalidate()
        appTimer = nil
        liveActivityTimer?.invalidate()
        liveActivityTimer = nil

        if liveActivity != nil {
            endLiveActivity()
        }
    }
    
    func discardWorkout() {
        guard let workout = activeWorkout else { return }
        
        // If there's a live activity, end it
        if liveActivity != nil {
            endLiveActivity()
        }
        
        // Clean up timers
        appTimer?.invalidate()
        appTimer = nil
        liveActivityTimer?.invalidate()
        liveActivityTimer = nil
        
        // Clear state
        activeWorkout = nil
        workoutStartTime = nil
        WorkoutStorage.shared.clearActiveWorkout()
        WorkoutStorage.shared.deleteWorkout(workout)
    }

    func startTimers() {
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
    
    func startLiveActivity(workout: Workout) {
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
    
    func updateLiveActivity(duration: TimeInterval) {
        guard let liveActivity = liveActivity,
              let workout = activeWorkout else { return }
        
        let state = WorkoutAttributes.ContentState(
            duration: duration,
            currentExerciseName: workout.exercizeSets.last?.exercize.name,
            setCount: workout.exercizeSets.count,
            status: "In Progress"
        )
        
        Task {
            await liveActivity.update(ActivityContent(state: state, staleDate: nil))
        }
    }
    
    func endLiveActivity() {
        guard let liveActivity = liveActivity,
              let workout = activeWorkout else { return }
        
        let finalState = WorkoutAttributes.ContentState(
            duration: workout.duration,
            currentExerciseName: nil,
            setCount: workout.exercizeSets.count,
            status: "Completed"
        )
        
        Task {
            await liveActivity.end(ActivityContent(state: finalState, staleDate: nil),
                                   dismissalPolicy: .immediate)
        }
        
        self.liveActivity = nil
    }
}
