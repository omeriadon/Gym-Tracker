//
    //  ExercizeListView.swift
    //  Gym Tracker
    //
    //  Created by Adon Omeri on 12/4/2025.
    //

import SwiftUI
import SwiftData

struct ExercizeListView: View {
    @State private var searchText = ""
    @State private var isSearchActive = true
    @State private var selectedTokens: [SearchToken] = []
    @Environment(\.modelContext) private var modelContext
    @Query var bookmarks: [Bookmark]
    
    var suggestedTokens: [SearchToken] {
        var tokens = allExercizes.commonGroups(limit: Int.max).map { SearchToken.category(ExercizeToken(rawValue: $0) ?? .other) }
        tokens.append(contentsOf: allExercizes.commonMuscles(limit: Int.max).map { SearchToken.muscle($0) })
        return tokens
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackgroundView.random()
                
                List {
                    let filteredExercizes = allExercizes.filtered(by: selectedTokens, searchText: searchText, bookmarks: bookmarks)
                    
                    if filteredExercizes.isEmpty {
                        Text("No exercises found")
                            .foregroundColor(.secondary)
                            .listRowBackground(UltraThinView())
                    } else {
                        ForEach(filteredExercizes, id: \.id) { exercize in
                            NavigationLink {
                                ExercizeDetailView(exercize: exercize)
                            } label: {
                                VStack(alignment: .leading) {
                                    Label("\(exercize.name)", systemImage: "dumbbell")
                                    Text(exercize.muscle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .listRowBackground(UltraThinView())
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Exercises")
            .searchable(
                text: $searchText,
                tokens: $selectedTokens,
                suggestedTokens: .constant(suggestedTokens),
                isPresented: $isSearchActive,
                placement: .toolbar,
                prompt: "Search exercises"
            ) { token in
                switch token {
                    case .category(let category):
                        Label(category.rawValue, systemImage: category.icon)
                    case .muscle(let muscle):
                        Label(muscle, systemImage: getMuscleIcon(muscle))
                    default:
                        Label("Error", systemImage: "triangle.exclamationmark")
                        
                }            }
            .searchSuggestions {
                if searchText.isEmpty {
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

                    Section("Other") {
                        Button {
                            selectedTokens.append(.bookmarked)
                        } label: {
                            Label("Bookmarked", systemImage: "bookmark.fill")
                        }
                    }
                } else {
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
}

