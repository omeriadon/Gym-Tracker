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
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarkedItems: [BookmarkEntity]
    @State private var isBookmarked: Bool = false
    
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    bookmarkButton(
                        name: name,
                        type: .exerciseGroup,
                        modelContext: modelContext
                    )
                }
            }
            .onAppear {
                checkIfBookmarked()
            }
        }
    }
    
    private func checkIfBookmarked() {
        isBookmarked = bookmarkedItems.contains { item in
            item.name == name && item.type == BookmarkType.exerciseGroup.rawValue
        }
    }
    
    private func toggleBookmark() {
        if isBookmarked {
            // Remove bookmark
            if let bookmarkToDelete = bookmarkedItems.first(where: { 
                $0.name == name && $0.type == BookmarkType.exerciseGroup.rawValue 
            }) {
                modelContext.delete(bookmarkToDelete)
                try? modelContext.save()
            }
        } else {
            // Add bookmark
            let newBookmark = BookmarkEntity(name: name, type: BookmarkType.exerciseGroup.rawValue)
            modelContext.insert(newBookmark)
            try? modelContext.save()
        }
        
        // Update state
        isBookmarked.toggle()
    }
}

#Preview {
    ExercizeGroupDetailView(name: "Chest")
}
