import Foundation
import SwiftData
import SwiftUI

enum BookmarkType: String, Codable {
    case exercise
    case exerciseGroup
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

class BookmarkManager {
    static let shared = BookmarkManager()
    @Environment(\.modelContext) private var modelContext

    func addBookmark(name: String, type: BookmarkType) {
        let bookmark = Bookmark(name: name, type: type.rawValue)
        BookmarkStorage.shared.saveBookmark(bookmark)
    }

    func removeBookmark(name: String, type: BookmarkType) {
        BookmarkStorage.shared.deleteBookmark(name: name, type: type)
    }

    @MainActor func isBookmarked(name: String, type: BookmarkType) -> Bool {
        return BookmarkStorage.shared.isBookmarked(name: name, type: type)
    }
}

class BookmarkStorage {
    static let shared = BookmarkStorage()

    private init() {}

    func saveBookmark(_ bookmark: Bookmark) {
        Task { @MainActor in
            do {
                let modelContainer = try ModelContainer(for: Bookmark.self)
                let context = modelContainer.mainContext

                context.insert(bookmark)
                try context.save()
                print("Bookmark saved successfully: \(bookmark.name)")
            } catch {
                print("Failed to save bookmark: \(error.localizedDescription)")
            }
        }
    }

    func deleteBookmark(name: String, type: BookmarkType) {
        Task { @MainActor in
            do {
                let modelContainer = try ModelContainer(for: Bookmark.self)
                let context = modelContainer.mainContext

                let fetchDescriptor = FetchDescriptor<Bookmark>(predicate: #Predicate { $0.name == name && $0.type == type.rawValue })
                if let bookmark = try context.fetch(fetchDescriptor).first {
                    context.delete(bookmark)
                    try context.save()
                    print("Bookmark deleted successfully: \(name)")
                }
            } catch {
                print("Failed to delete bookmark: \(error.localizedDescription)")
            }
        }
    }

    @MainActor func isBookmarked(name: String, type: BookmarkType) -> Bool {
        do {
            let modelContainer = try ModelContainer(for: Bookmark.self)
            let context = modelContainer.mainContext

            let fetchDescriptor = FetchDescriptor<Bookmark>(predicate: #Predicate { $0.name == name && $0.type == type.rawValue })
            return try !context.fetch(fetchDescriptor).isEmpty
        } catch {
            print("Failed to check bookmark: \(error.localizedDescription)")
            return false
        }
    }
}

struct BookmarksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [Bookmark]

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
                                    }
                                }
                                .listRowBackground(UltraThinView())

                            }

                            // Exercises Section
                            let exerciseBookmarks = bookmarks.filter { $0.type == BookmarkType.exercise.rawValue }
                            if !exerciseBookmarks.isEmpty {
                                Section("Exercises") {
                                    ForEach(exerciseBookmarks) { bookmark in
                                        if let exercise = allExercizes.first(where: { $0.name == bookmark.name }) {
                                            NavigationLink(destination: ExercizeDetailView(exercize: exercise)) {
                                                Text(bookmark.name)
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

struct BookmarkButton: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isBookmarked: Bool
    let name: String
    let type: BookmarkType

    init(name: String, type: BookmarkType) {
        self.name = name
        self.type = type
        _isBookmarked = State(initialValue: BookmarkManager.shared.isBookmarked(name: name, type: type))
    }

    var body: some View {
        Button {
            if isBookmarked {
                BookmarkManager.shared.removeBookmark(name: name, type: type)
            } else {
                BookmarkManager.shared.addBookmark(name: name, type: type)
            }
            isBookmarked.toggle()
        } label: {
            Label("Bookmark", systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
        }
    }
}
