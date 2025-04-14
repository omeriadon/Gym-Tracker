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
                    Button {
                        if isBookmarked {
                            let name = exercize.name
                            let fetchDescriptor = FetchDescriptor<Bookmark>(predicate: #Predicate { $0.name == name && $0.type == "exercise" })


                            if let bookmark = try? modelContext.fetch(fetchDescriptor).first {
                                modelContext.delete(bookmark)
                                try? modelContext.save()
                            }
                        } else {
                            let newBookmark = Bookmark(name: exercize.name, type: "exercise")
                            modelContext.insert(newBookmark)
                            try? modelContext.save()
                        }
                        isBookmarked.toggle()
                    } label: {
                        Label("Bookmark", systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
                    }
                    .onAppear {
                        let name = exercize.name
                        let fetchDescriptor = FetchDescriptor<Bookmark>(predicate: #Predicate { $0.name == name && $0.type == "exercise" })
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
    ExercizeDetailView(exercize: Exercize(id: UUID(), name: "name", notes: ["note", "note"], muscle: "muscle", timestamp: Date.now, group: "Chest"))
}
