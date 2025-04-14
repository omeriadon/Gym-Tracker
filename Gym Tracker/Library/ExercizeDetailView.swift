//
//  ExercizeDetailView.swift
//  Gym Tracker
//
//  Created by Adon Omeri on 12/4/2025.
//

import SwiftUI
import SwiftData

struct ExercizeDetailView: View {
    
    var exercize: Exercize
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarkedItems: [BookmarkEntity]
    @State private var isBookmarked: Bool = false
    
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
                            
                            Text(exercize.muscle)
                            
                            
                        } header: {
                            
                            Label("Muscle", systemImage: "figure")
                            
                        }
                        .listRowBackground(UltraThinView())
                        
                        
                        Section {
                            
                            NavigationLink(exercize.group, destination: ExercizeGroupDetailView(name: exercize.group))
                            
                            
                        } header: {
                            
                            Label("Muscle Group", systemImage: "square.2.layers.3d")
                            
                        }
                        .listRowBackground(UltraThinView())
                        
                        
                        Section {
                            ForEach(exercize.notes, id: \.self) { note in
                                Text(note)
                            }
                            
                        } header: {
                            
                            Label("Instructions", systemImage: "book")
                            
                        }
                        .listRowBackground(UltraThinView())
                    }
                    .scrollContentBackground(.hidden) // This makes the List background transparent
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle(exercize.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    bookmarkButton(
                        name: exercize.name,
                        type: .exercise,
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
            item.name == exercize.name && item.type == BookmarkType.exercise.rawValue
        }
    }
    
    private func toggleBookmark() {
        if isBookmarked {
            // Remove bookmark
            if let bookmarkToDelete = bookmarkedItems.first(where: { 
                $0.name == exercize.name && $0.type == BookmarkType.exercise.rawValue 
            }) {
                modelContext.delete(bookmarkToDelete)
                try? modelContext.save()
            }
        } else {
            // Add bookmark
            let newBookmark = BookmarkEntity(name: exercize.name, type: BookmarkType.exercise.rawValue)
            modelContext.insert(newBookmark)
            do {
                try modelContext.save()
            } catch {
                print("ERROR SAVING: \(error.localizedDescription)")
            }
        }
        
        // Update state
        isBookmarked.toggle()
        
    }
}

#Preview {
    ExercizeDetailView(exercize: Exercize(id: UUID(), name: "name", notes: ["note", "note"], muscle: "muscle", timestamp: Date.now, group: "Chest"))
}
