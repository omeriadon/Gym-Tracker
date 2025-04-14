//
//  WorkoutDetailView.swift
//  Gym Tracker
//
//  Created by Adon Omeri on 14/4/2025.
//

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    var workout: Workout
    @Environment(\.modelContext) private var modelContext
    @State private var name: String
    @State private var notes: String
    @State private var isBookmarked: Bool = false

    init(workout: Workout) {
        self.workout = workout
        _name = State(initialValue: workout.name)
        _notes = State(initialValue: workout.notes)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackgroundView.random()

                VStack {
                    Spacer()
                        .frame(height: 15)

                    List {
                        Section {
                            TextField("Workout Name", text: $name, onCommit: saveName)
                        } header: {
                            Label("Name", systemImage: "pencil")
                        }
                        .listRowBackground(UltraThinView())

                        Section {
                            TextEditor(text: $notes)
                                .onChange(of: notes) {
                                    saveNotes() }
                        } header: {
                            Label("Notes", systemImage: "book")
                        }
                        .listRowBackground(UltraThinView())
                    }
                    .scrollContentBackground(.hidden)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle(workout.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if isBookmarked {
                            let name = workout.name
                            let fetchDescriptor = FetchDescriptor<Bookmark>(predicate: #Predicate { $0.name == name && $0.type == "workout" })
                            if let bookmark = try? modelContext.fetch(fetchDescriptor).first {
                                modelContext.delete(bookmark)
                                try? modelContext.save()
                            }
                        } else {
                            let newBookmark = Bookmark(name: workout.name, type: "workout")
                            modelContext.insert(newBookmark)
                            try? modelContext.save()
                        }
                        isBookmarked.toggle()
                    } label: {
                        Label("Bookmark", systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
                    }
                    .onAppear {
                        let name = workout.name
                        let fetchDescriptor = FetchDescriptor<Bookmark>(predicate: #Predicate { $0.name == name && $0.type == "workout" })
                        if let bookmarks = try? modelContext.fetch(fetchDescriptor) {
                            isBookmarked = !bookmarks.isEmpty
                        }
                    }
                }
            }
        }
    }

    private func saveName() {
        workout.name = name
        try? modelContext.save()
    }

    private func saveNotes() {
        workout.notes = notes
        try? modelContext.save()
    }
}

#Preview {
    WorkoutDetailView(workout: Workout(id: UUID(), name: "name", date: Date.now, duration: 46, notes: "notes", exerciseSets: []))
}
