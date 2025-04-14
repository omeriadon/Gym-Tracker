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
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var notes: String
    @State private var isBookmarked: Bool = false
    @State private var showDeleteAlert = false
    @State private var editingSet: ExercizeSet?
    @State private var editReps: String = ""
    @State private var editWeight: String = ""
    @State private var editFailureLevel: FailureLevel = .noFailure

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
                            TextField("Workout Name", text: $name)
                                .onChange(of: name) {
                                    saveName() }
                        } header: {
                            Label("Name", systemImage: "pencil")
                        }
                        .listRowBackground(UltraThinView())
                        
                        Section {
                            Text(formatDuration(workout.duration))
                                .monospacedDigit()
                            Text(workout.date.formatted(date: .long, time: .shortened))
                        } header: {
                            Label("Details", systemImage: "clock")
                        }
                        .listRowBackground(UltraThinView())

                        if !workout.exerciseSets.isEmpty {
                            Section {
                                ForEach(workout.exerciseSets) { set in
                                    HStack {
                                        Circle()
                                            .fill(set.hitFailure.color)
                                            .frame(width: 12, height: 12)
                                        Text(set.excersize.name)
                                        Spacer()
                                        Text("\(set.reps) reps @ \(String(format: "%.1f", set.weight))kg")
                                            .foregroundStyle(.secondary)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            if let index = workout.exerciseSets.firstIndex(where: { $0.id == set.id }) {
                                                workout.exerciseSets.remove(at: index)
                                                try? modelContext.save()
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            editingSet = set
                                            editReps = "\(set.reps)"
                                            editWeight = "\(set.weight)"
                                            editFailureLevel = set.hitFailure
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.yellow)
                                    }
                                }
                                .onDelete { indices in
                                    indices.forEach { index in
                                        workout.exerciseSets.remove(at: index)
                                    }
                                    try? modelContext.save()
                                }
                            } header: {
                                Label("Sets", systemImage: "figure.strengthtraining.traditional")
                            }
                            .listRowBackground(UltraThinView())
                        }

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
                .scrollDismissesKeyboard(.immediately)
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label {
                            Text("Delete")
                                .foregroundColor(.red)
                        } icon: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .labelStyle(.iconOnly)
                    }
                }
            }
            .alert("Delete Workout", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    modelContext.delete(workout)
                    try? modelContext.save()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this workout? This action cannot be undone.")
            }
            .popover(item: $editingSet) { set in
                NavigationStack {
                    List {
                        Section {
                            HStack {
                                Text("Reps")
                                TextField("", text: $editReps)
                                    .keyboardType(.numberPad)
                            }
                            HStack {
                                Text("Weight:")
                                TextField("", text: $editWeight)
                                    .keyboardType(.decimalPad)
                            }
                            Picker("Failure Level", selection: $editFailureLevel) {
                                ForEach([FailureLevel.noFailure, .mildDiscomfort, .almostFailure, .completeFailure], id: \.self) { level in
                                    HStack {
                                        Circle()
                                            .fill(level.color)
                                            .frame(width: 12, height: 12)
                                        Text(level.description)
                                    }
                                }
                            }
                            .listRowBackground(editFailureLevel.color.opacity(0.2))

                        } header: {
                            Label("Edit Set", systemImage: "pencil")
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Edit Set")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                if let reps = Int(editReps),
                                   let weight = Double(editWeight) {
                                    set.reps = reps
                                    set.weight = weight
                                    set.hitFailure = editFailureLevel
                                    try? modelContext.save()
                                    editingSet = nil
                                }
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                editingSet = nil
                            }
                        }
                    }
                }
                .frame(minWidth: 300, minHeight: 500)
                .presentationCompactAdaptation(.sheet)
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
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    WorkoutDetailView(workout: Workout(id: UUID(), name: "name", date: Date.now, duration: 46, notes: "notes", exerciseSets: []))
}
