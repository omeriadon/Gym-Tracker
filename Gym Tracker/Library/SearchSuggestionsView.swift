import SwiftUI
import SwiftData

struct SearchSuggestionsView: View {
    let searchText: String
    @Binding var selectedTokens: [SearchToken]
    @Environment(\.modelContext) private var modelContext
    
    private func getMuscleIcon(_ muscle: String) -> String {
        switch muscle.lowercased() {
        case "chest": return "figure.strengthtraining.functional"
        case "back": return "figure.strengthtraining.traditional"
        case "legs": return "figure.run"
        case "arms": return "figure.arms.open"
        case "shoulders": return "figure.boxing"
        default: return "figure.strengthtraining.traditional"
        }
    }
    
    var body: some View {
        Group {
            if searchText.isEmpty {
                VStack {
                    Section("Categories") {
                        ForEach(ExercizeToken.allCases) { category in
                            Button {
                                selectedTokens.append(.category(category))
                            } label: {
                                Label(category.rawValue, systemImage: category.icon)
                            }
                        }
                    }
                    
                    Section("Common Muscles") {
                        ForEach(allExercizes.commonMuscles(), id: \.self) { muscle in
                            Button {
                                selectedTokens.append(.muscle(muscle))
                            } label: {
                                Label(muscle, systemImage: getMuscleIcon(muscle))
                            }
                        }
                    }

                }
            } else {
                VStack {
                    // Show matching categories
                    let matchingCategories = ExercizeToken.allCases.filter {
                        $0.rawValue.lowercased().contains(searchText.lowercased())
                    }
                    
                    if !matchingCategories.isEmpty {
                        Section("Categories") {
                            ForEach(matchingCategories) { category in
                                Button {
                                    selectedTokens.append(.category(category))
                                } label: {
                                    Label(category.rawValue, systemImage: category.icon)
                                }
                            }
                        }
                    }
                    
                    // Show matching muscles
                    let matchingMuscles = allExercizes.commonMuscles().filter {
                        $0.lowercased().contains(searchText.lowercased())
                    }
                    
                    if !matchingMuscles.isEmpty {
                        Section("Muscles") {
                            ForEach(matchingMuscles, id: \.self) { muscle in
                                Button {
                                    selectedTokens.append(.muscle(muscle))
                                } label: {
                                    Label(muscle, systemImage: getMuscleIcon(muscle))
                                }
                            }
                        }
                    }

                }
            }
        }
    }
}

#Preview {
    SearchSuggestionsView(searchText: "", selectedTokens: .constant([]))
}