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
                    Button {
                        if isBookmarked {
                            let fetchDescriptor = FetchDescriptor<Bookmark>(predicate: #Predicate { $0.name == name && $0.type == "exerciseGroup" })
                            if let bookmark = try? modelContext.fetch(fetchDescriptor).first {
                                modelContext.delete(bookmark)
                                try? modelContext.save()
                            }
                        } else {
                            let newBookmark = Bookmark(name: name, type: "exerciseGroup")
                            modelContext.insert(newBookmark)
                            try? modelContext.save()
                        }
                        isBookmarked.toggle()
                    } label: {
                        Label("Bookmark", systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
                    }
                    .onAppear {
                        let fetchDescriptor = FetchDescriptor<Bookmark>(predicate: #Predicate { $0.name == name && $0.type == "exerciseGroup" })
                        if let bookmarks = try? modelContext.fetch(fetchDescriptor) {
                            isBookmarked = !bookmarks.isEmpty
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ExercizeGroupDetailView(name: "Chest")
}
