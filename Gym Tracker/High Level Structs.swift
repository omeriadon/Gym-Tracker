//
    //  High Level Structs.swift
    //  Gym Tracker
    //
    //  Created by Adon Omeri on 12/4/2025.
    //

import Foundation
import SwiftUICore
import SwiftData



    //MARK: Structs





@Model
class Exercize {
    var id: UUID
    var name: String
    var notes: [String]
    var muscle: String
    var group: String  // Changed from ExercizeGroup enum to String
    
    init(id: UUID, name: String, notes: [String], muscle: String,  timestamp: Date, group: String) {
        self.id = id
        self.name = name
        self.notes = notes
        self.muscle = muscle
        self.group = group
    }
}



@Model
class ExercizeSet {
    
    
    var id: UUID
    var reps: Int
    var weight: Double // kg
    var timestamp: Date
    var timeinterval: TimeInterval
    var hitFailure: FailureLevel

    var exercize: Exercize
    
    
    init(id: UUID, reps: Int, weight: Double, timestamp: Date, timeinterval: TimeInterval, exercize: Exercize, hitFailure: FailureLevel) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.timestamp = timestamp
        self.timeinterval = timeinterval
        self.exercize = exercize
        self.hitFailure = hitFailure
    }
}



class ExercizeGroupStruct {
    
    var id: UUID
    var name: String // e.g. "Legs"
    var themeColour: RGBColour
    
    
    init(id: UUID, name: String, themeColour: RGBColour) {
        self.id = id
        self.name = name
        self.themeColour = themeColour
    }
}



@Model
class Workout {
    
    var id: UUID
    var name: String
    var date: Date
    var duration: TimeInterval 
    var notes: String
    var exercizeSets: [ExercizeSet]
    var isActive: Bool
    
    init(id: UUID, name: String, date: Date, duration: TimeInterval, notes: String, exercizeSets: [ExercizeSet], isActive: Bool = false) {
        self.id = id
        self.name = name
        self.date = date
        self.duration = duration
        self.notes = notes
        self.exercizeSets = exercizeSets
        self.isActive = isActive
    }
}






    //MARK: Enums

enum FailureLevel: String, Codable {
    case noFailure
    case mildDiscomfort
    case almostFailure
    case completeFailure
    
    var description: String {
        switch self {
            case .noFailure:
                return "No Failure"
            case .mildDiscomfort:
                return "Mild Discomfort"
            case .almostFailure:
                return "Almost Failure"
            case .completeFailure:
                return "Complete Failure"
        }
    }
    
    var color: Color {
        switch self {
            case .noFailure:
                return .red
            case .mildDiscomfort:
                return .orange
            case .almostFailure:
                return .green
            case .completeFailure:
                return .blue
        }
    }
}




enum ThemeMode: String, Codable {
    case light
    case dark
}

enum MeasurementUnit: String, Codable {
    case metric
    case imperial
}





    //MARK: Misc




struct RGBColour: Codable {
    var red: Double
    var green: Double
    var blue: Double
    
    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue)
    }
}

class UserSettings {
    // Keys for UserDefaults
    private enum Keys {
        static let userID = "userSettings.id"
        static let firstName = "userSettings.firstName"
        static let themeMode = "userSettings.themeMode"
        static let preferredUnits = "userSettings.preferredUnits"
    }
    
    // Singleton instance
    static let shared = UserSettings()
    
    // Properties with getters and setters
    var id: UUID {
        get {
            if let uuidString = UserDefaults.standard.string(forKey: Keys.userID),
               let uuid = UUID(uuidString: uuidString) {
                return uuid
            } else {
                let newID = UUID()
                UserDefaults.standard.set(newID.uuidString, forKey: Keys.userID)
                return newID
            }
        }
        set {
            UserDefaults.standard.set(newValue.uuidString, forKey: Keys.userID)
        }
    }
    
    var firstName: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.firstName) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.firstName)
        }
    }
    
    var themeMode: ThemeMode {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: Keys.themeMode),
               let mode = ThemeMode(rawValue: rawValue) {
                return mode
            } else {
                return .light
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.themeMode)
        }
    }
    
    var preferredUnits: MeasurementUnit {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: Keys.preferredUnits),
               let unit = MeasurementUnit(rawValue: rawValue) {
                return unit
            } else {
                return .metric
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.preferredUnits)
        }
    }
    
    // Reset all settings
    func resetAllSettings() {
        UserDefaults.standard.set("Person", forKey: Keys.firstName)
        UserDefaults.standard.removeObject(forKey: Keys.userID)
        UserDefaults.standard.removeObject(forKey: Keys.themeMode)
        UserDefaults.standard.removeObject(forKey: Keys.preferredUnits)
    }
    
    // Convenience method to save all settings at once
    func saveSettings(firstName: String, themeMode: ThemeMode, preferredUnits: MeasurementUnit) {
        self.firstName = firstName
        self.themeMode = themeMode
        self.preferredUnits = preferredUnits
    }
    
    // Function to get all settings as a dictionary
    func getAllSettings() -> [String: Any] {
        return [
            "id": id.uuidString,
            "firstName": firstName,
            "themeMode": themeMode.rawValue,
            "preferredUnits": preferredUnits.rawValue
        ]
    }
    
    // Private initializer for singleton
    private init() {
        // Initialize with default values if not already set
        if UserDefaults.standard.string(forKey: Keys.userID) == nil {
            id = UUID()
        }
    }
}




