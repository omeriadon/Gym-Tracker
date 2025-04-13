import SwiftUI
import SwiftData

// Token for exercise categories
enum ExercizeToken: String, Identifiable, Hashable, CaseIterable {
    case chest = "Chest"
    case back = "Back" 
    case legs = "Legs"
    case shoulders = "Shoulders"
    case arms = "Arms"
    case core = "Core"
    case cardio = "Cardio"
    case other = "Other"

    
    var id: Self { self }
    
    var icon: String {
        switch self {
        case .chest: return "figure.strengthtraining.functional"
        case .back: return "figure.strengthtraining.traditional"
        case .legs: return "figure.run"
        case .arms: return "figure.arms.open"
        case .shoulders: return "figure.boxing"
        case .core: return "figure.core.training"
        case .cardio: return "heart"
        case .other: return "questionmark.circle"

        }
    }
}

// Combined search token type
enum SearchToken: Hashable, Identifiable {
    case category(ExercizeToken)
    case muscle(String)
    case bookmarked
    
    var id: String {
        switch self {
        case .category(let token): return "category-\(token.rawValue)"
        case .muscle(let value): return "muscle-\(value)"
        case .bookmarked: return "bookmarked"
        }
    }
}

// Extension with helper functions for search functionality
extension Array where Element == Exercize {
    func filtered(by tokens: [SearchToken], searchText: String, bookmarks: [BookmarkEntity]? = nil) -> [Exercize] {
        if searchText.isEmpty && tokens.isEmpty {
            return self
        }
        
        return self.filter { exercize in
            let matchesText = searchText.isEmpty || 
                exercize.name.lowercased().contains(searchText.lowercased())
            
            let matchesTokens = tokens.isEmpty || tokens.allSatisfy { token in
                switch token {
                case .category(let category):
                    return exercize.group == category.rawValue
                case .muscle(let muscle):
                    return exercize.muscle.lowercased().contains(muscle.lowercased())
                case .bookmarked:
                    if let bookmarks = bookmarks {
                        return bookmarks.contains { 
                            $0.name == exercize.name && 
                            $0.type == BookmarkType.exercise.rawValue 
                        }
                    }
                    return false
                }
            }
            
            return matchesText && matchesTokens
        }
    }
    
    func commonMuscles(limit: Int = 5) -> [String] {
        // Extract all muscles from exercises and create an array of strings
        var allMuscles: [String] = []
        
        for exercise in self {
            // Split the muscle string by commas and add each muscle
            let muscles = exercise.muscle.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            allMuscles.append(contentsOf: muscles)
        }
        
        // Count occurrences of each muscle
        let counts = Dictionary(grouping: allMuscles, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        // Return top muscles
        return counts.prefix(limit).map { $0.key }
    }

    func commonGroups(limit: Int = 5) -> [String] {
        // Extract all groups from exercises and create an array of strings
        var allGroups: [String] = []

        for exercise in self {
            allGroups.append(exercise.group)
        }

        // Count occurrences of each group
        let counts = Dictionary(grouping: allGroups, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }

        // Return top groups
        return counts.prefix(limit).map { $0.key }
    }
}

// Extension to provide uniqued() functionality for arrays
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
