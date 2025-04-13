//
//  JSON.swift
//  Gym Tracker
//
//  Created by Adon Omeri on 12/4/2025.
//

import Foundation


    // Global arrays for different exercise groups
var chestExercizes: [Exercize] = []
var backExercizes: [Exercize] = []
var legsExercizes: [Exercize] = []
var armsExercizes: [Exercize] = []
var coreExercizes: [Exercize] = []
var cardioExercizes: [Exercize] = []
var otherExercizes: [Exercize] = []

var allExercizes: [Exercize] = []


struct RawExercize: Codable {
    var name: String
    var equipment: String
    var muscle: [String]
    var instructions: [String]
    var exerciseGroup: String // This corresponds to the group name in the JSON
}



enum ExercizeGroupEnum: String, Codable {
    case chest
    case back
    case legs
    case shoulders
    case arms
    case core
    case cardio
    case other
}




func loadAndGroupExercizes() {
    
    
    guard let url = Bundle.main.url(forResource: "exercizes", withExtension: "json"),
          let jsonData = try? Data(contentsOf: url) else {
        print("Failed to load JSON file")
        return
    }

    
    let decoder = JSONDecoder()
    do {
        let rawExercizes = try decoder.decode([RawExercize].self, from: jsonData)
        
            // Iterate through each raw exercise and categorize based on the exercise group
        for rawExercize in rawExercizes {
            let exercize = Exercize(
                id: UUID(),
                name: rawExercize.name,
                notes: rawExercize.instructions,
                muscle: rawExercize.muscle.joined(separator: ", "),
                timestamp: Date(), // Use the current date or a specific one
                group: rawExercize.exerciseGroup // Directly use the exercise group from the JSON
            )
            
            // Assign the exercize to the combined array
            allExercizes.append(exercize)
            
                // Assign the exercise to the appropriate group based on the exerciseGroup string
            switch rawExercize.exerciseGroup.lowercased() {
                case "chest":
                    chestExercizes.append(exercize)
                case "back":
                    backExercizes.append(exercize)
                case "legs":
                    legsExercizes.append(exercize)
                case "arms":
                    armsExercizes.append(exercize)
                case "core":
                    coreExercizes.append(exercize)
                case "cardio":
                    cardioExercizes.append(exercize)
                default:
                    otherExercizes.append(exercize)
            }
        }
    } catch {
        print("Error decoding JSON: \(error.localizedDescription)")
    }
}








let exerciseGroups: [ExercizeGroupStruct] = [
    ExercizeGroupStruct(id: UUID(), name: "Chest", themeColour: RGBColour(red: 0.8, green: 0.2, blue: 0.2)),
    ExercizeGroupStruct(id: UUID(), name: "Back", themeColour: RGBColour(red: 0.2, green: 0.6, blue: 0.8)),
    ExercizeGroupStruct(id: UUID(), name: "Legs", themeColour: RGBColour(red: 0.7, green: 0.4, blue: 0.7)),
    ExercizeGroupStruct(id: UUID(), name: "Shoulders", themeColour: RGBColour(red: 0.8, green: 0.6, blue: 0.2)),
    ExercizeGroupStruct(id: UUID(), name: "Arms", themeColour: RGBColour(red: 0.2, green: 0.7, blue: 0.4)),
    ExercizeGroupStruct(id: UUID(), name: "Core", themeColour: RGBColour(red: 0.5, green: 0.5, blue: 0.8)),
    ExercizeGroupStruct(id: UUID(), name: "Cardio", themeColour: RGBColour(red: 0.9, green: 0.3, blue: 0.3)),
    ExercizeGroupStruct(id: UUID(), name: "Other", themeColour: RGBColour(red: 0.9, green: 0.3, blue: 0.3))
]




