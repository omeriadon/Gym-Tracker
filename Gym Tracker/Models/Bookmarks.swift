import Foundation
import SwiftData
import SwiftUI

enum BookmarkType: String, Codable {
    case exercise
    case exerciseGroup
}

@Model
class BookmarkEntity {
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
    @Query private var bookmarkedItems: [BookmarkEntity]
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Add the gradient background
                GradientBackgroundView.random()
                
                VStack {
                    Spacer()
                        .frame(height: 15)
                    
                    List {
                        if bookmarkedItems.isEmpty {
                            Section {
                                VStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "bookmark.slash")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                        .padding(.top, 20)
                                    
                                    Text("No Bookmarks")
                                        .font(.headline)
                                    
                                    Text("Bookmark exercises and groups to see them here.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                        .padding(.bottom, 20)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .listRowBackground(UltraThinView())
                        } else {
                            // Group bookmarks
                            let groupBookmarks = filteredBookmarks.filter { 
                                $0.type == BookmarkType.exerciseGroup.rawValue 
                            }
                            
                            if !groupBookmarks.isEmpty {
                                Section {
                                    ForEach(groupBookmarks) { bookmark in
                                        NavigationLink(destination: ExercizeGroupDetailView(name: bookmark.name)) {
                                            let group = exerciseGroups.first { $0.name == bookmark.name }
                                            HStack {
                                                Image(systemName: "folder.fill")
                                                    .foregroundColor(group?.themeColour.swiftUIColor ?? .blue)
                                                Text(bookmark.name)
                                            }
                                        }
                                    }
                                } header: {
                                    Label("Bookmarked Groups", systemImage: "square.stack.fill")
                                }
                                .listRowBackground(UltraThinView())
                            }
                            
                            // Exercise bookmarks
                            let exerciseBookmarks = filteredBookmarks.filter { 
                                $0.type == BookmarkType.exercise.rawValue 
                            }
                            
                            if !exerciseBookmarks.isEmpty {
                                Section {
                                    ForEach(exerciseBookmarks) { bookmark in
                                        if let exercise = allExercizes.first(where: { $0.name == bookmark.name }) {
                                            NavigationLink(destination: ExercizeDetailView(exercize: exercise)) {
                                                VStack(alignment: .leading) {
                                                    Text(bookmark.name)
                                                        .font(.headline)
                                                    Text(exercise.group)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                    }
                                } header: {
                                    Label("Bookmarked Exercises", systemImage: "dumbbell.fill")
                                }
                                .listRowBackground(UltraThinView())
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle("Bookmarks")
            .searchable(text: $searchText, prompt: "Search bookmarks")
        }
    }
    
    private var filteredBookmarks: [BookmarkEntity] {
        if searchText.isEmpty {
            return bookmarkedItems
        } else {
            return bookmarkedItems.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
}



// Extension to provide bookmark functionality
extension View {
    func bookmarkButton(
        name: String,
        type: BookmarkType,
        modelContext: ModelContext
    ) -> some View {
        let isBookmarked = checkIsBookmarked(name: name, type: type, modelContext: modelContext)
        
        return Button {
            if (isBookmarked) {
                removeBookmark(name: name, type: type, modelContext: modelContext)
            } else {
                addBookmark(name: name, type: type, modelContext: modelContext)
            }
        } label: {
            Label("Bookmark", systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
        }
    }
    
    // Check if item is bookmarked
    private func checkIsBookmarked(name: String, type: BookmarkType, modelContext: ModelContext) -> Bool {
        let predicate = #Predicate<BookmarkEntity> { 
            $0.name == name && $0.type == type.rawValue 
        }
        let descriptor = FetchDescriptor<BookmarkEntity>(predicate: predicate)
        
        do {
            let results = try modelContext.fetch(descriptor)
            return !results.isEmpty
        } catch {
            print("Error checking bookmark: \(error)")
            return false
        }
    }
    
    // Add a bookmark
    private func addBookmark(name: String, type: BookmarkType, modelContext: ModelContext) {
        let bookmark = BookmarkEntity(name: name, type: type.rawValue)
        modelContext.insert(bookmark)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving bookmark: \(error)")
        }
    }
    
    // Remove a bookmark
    private func removeBookmark(name: String, type: BookmarkType, modelContext: ModelContext) {
        let predicate = #Predicate<BookmarkEntity> { 
            $0.name == name && $0.type == type.rawValue 
        }
        let descriptor = FetchDescriptor<BookmarkEntity>(predicate: predicate)
        
        do {
            let results = try modelContext.fetch(descriptor)
            for bookmark in results {
                modelContext.delete(bookmark)
            }
            try modelContext.save()
        } catch {
            print("Error removing bookmark: \(error)")
        }
    }
}
