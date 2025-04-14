import Foundation
import SwiftData
import SwiftUI

enum BookmarkType: String, Codable {
    case exercise
    case exerciseGroup
    case workout
}

@Model
class Bookmark {
    var id: UUID
    var name: String
    var type: String
    var timestamp: Date
    
    init(name: String, type: String) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.timestamp = Date()
    }
}

struct BookmarksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [Bookmark]
    @Query private var workouts: [Workout]

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackgroundView.random()

                VStack {
                    Spacer()
                        .frame(height: 15)

                    if bookmarks.isEmpty {
                        Text("No Bookmarks")
                            .foregroundColor(.secondary)
                    } else {
                        List {
                            // Exercise Groups Section
                            let groupBookmarks = bookmarks.filter { $0.type == BookmarkType.exerciseGroup.rawValue }
                            if !groupBookmarks.isEmpty {
                                Section("Groups") {
                                    ForEach(groupBookmarks) { bookmark in
                                        NavigationLink(destination: ExercizeGroupDetailView(name: bookmark.name)) {
                                            Text(bookmark.name)
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                modelContext.delete(bookmark)
                                                try? modelContext.save()
                                            } label: {
                                                Label("Remove", systemImage: "bookmark.slash.fill")
                                            }
                                        }
                                    }
                                }
                                .listRowBackground(UltraThinView())
                            }

                            // Exercises Section
                            let exerciseBookmarks = bookmarks.filter { $0.type == BookmarkType.exercise.rawValue }
                            if !exerciseBookmarks.isEmpty {
                                Section("Exercizes") {
                                    ForEach(exerciseBookmarks) { bookmark in
                                        if let exercise = allExercizes.first(where: { $0.name == bookmark.name }) {
                                            NavigationLink(destination: ExercizeDetailView(exercize: exercise)) {
                                                Text(bookmark.name)
                                            }
                                            .swipeActions(edge: .trailing) {
                                                Button(role: .destructive) {
                                                    modelContext.delete(bookmark)
                                                    try? modelContext.save()
                                                } label: {
                                                    Label("Remove", systemImage: "bookmark.slash.fill")
                                                }
                                            }
                                        }
                                    }
                                }
                                .listRowBackground(UltraThinView())
                            }

                            // Workouts Section
                            let workoutBookmarks = bookmarks.filter { $0.type == BookmarkType.workout.rawValue }
                            if !workoutBookmarks.isEmpty {
                                Section("Workouts") {
                                    ForEach(workoutBookmarks) { bookmark in
                                        if let workout = workouts.first(where: { $0.name == bookmark.name }) {
                                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                                Text(bookmark.name)
                                            }
                                            .swipeActions(edge: .trailing) {
                                                Button(role: .destructive) {
                                                    modelContext.delete(bookmark)
                                                    try? modelContext.save()
                                                } label: {
                                                    Label("Remove", systemImage: "bookmark.slash.fill")
                                                }
                                            }
                                        }
                                    }
                                }
                                .listRowBackground(UltraThinView())
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle("Bookmarks")
        }
    }
}

