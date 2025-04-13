import ActivityKit
import Foundation

struct WorkoutAttributes: ActivityAttributes {
    let workoutName: String
    let workoutId: UUID
    
    struct ContentState: Codable & Hashable {
        var duration: TimeInterval
        var currentExerciseName: String?
        var setCount: Int
        var status: String
    }
}