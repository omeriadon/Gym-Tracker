//
//  ExercizeGroupDetailView.swift
//  Gym Tracker
//
//  Created by Adon Omeri on 13/4/2025.
//

import SwiftUI
import SwiftData

struct ExercizeGroupDetailView: View {
    var name: String
    
    // Find the ExercizeGroupStruct for this group name
    private var groupStruct: ExercizeGroupStruct? {
        exerciseGroups.first { $0.name.capitalized == name.capitalized }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Add the gradient background
                GradientBackgroundView.random()
                
                VStack {
                    Spacer()
                        .frame(height: 15)
                    
                    List {
                        Section {
                            ForEach(allExercizes.filter { $0.group.capitalized == name.capitalized }) { exercize in
                                NavigationLink {
                                    ExercizeDetailView(exercize: exercize)
                                } label: {
                                    Label("\(exercize.name)", systemImage: "dumbbell")
                                }
                            }
                        } header: {
                            Text("\(name) Exercises")
                                .font(.headline)
                        }
                        .listRowBackground(UltraThinView())
                    }
                    .scrollContentBackground(.hidden)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle(name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    BookmarkButton(name: name, type: .exerciseGroup)
                }
            }
        }
    }
}

#Preview {
    ExercizeGroupDetailView(name: "Chest")
}
