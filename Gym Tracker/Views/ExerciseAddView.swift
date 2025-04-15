import SwiftUI
import SwiftData

struct ExerciseAddView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var workoutManager: WorkoutManager
    @Binding var showingExerciseSheet: Bool
    @Binding var showExitConfirmation: Bool
    
    // State for the selected exercise flow
    @State private var selectedExercise: Exercize?
    @State private var reps = ""
    @State private var weight = ""
    @State private var failureLevel: FailureLevel = .noFailure
    
    var body: some View {
        NavigationStack {
            if selectedExercise == nil {
                ExerciseSelectionView(selectedExercise: $selectedExercise)

            } else {
                ExerciseSetLogView(
                    exercise: selectedExercise!,
                    onSave: { set in
                        if let workout = workoutManager.activeWorkout {
                            workout.exercizeSets.append(set)
                            WorkoutStorage.shared.saveWorkoutState()
                            showingExerciseSheet = false
                        }
                    },
                    onCancel: {
                        selectedExercise = nil
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .cancel) {
                            if selectedExercise != nil {
                                showExitConfirmation = true
                            } else {
                                showingExerciseSheet = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }

        }
        .presentationDetents([.large])
        .presentationCornerRadius(30)
        .presentationBackground(content: { UltraThinView() })
        .interactiveDismissDisabled()
        .alert("Exit Exercise Logging?", isPresented: $showExitConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Exit") {
                selectedExercise = nil
                showingExerciseSheet = false
            }
        } message: {
            Text("Are you sure you want to exit? Your current set will not be saved.")
        }
    }
}

private struct ExerciseSelectionView: View {
    @EnvironmentObject private var workoutManager: WorkoutManager
    @Binding var selectedExercise: Exercize?
    @State private var searchText = ""
    
    var filteredExercises: [Exercize] {
        if searchText.isEmpty {
            return allExercizes
        }
        return allExercizes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List {
            if let workout = workoutManager.activeWorkout {
                let groupedSets = Dictionary(grouping: workout.exercizeSets) { $0.exercize.name }
                if !workout.exercizeSets.isEmpty {
                    Section {
                        ForEach(Array(groupedSets.keys).sorted(), id: \.self) { exerciseName in
                            if let sets = groupedSets[exerciseName] {
                                QuickAddExerciseGroup(exerciseName: exerciseName, sets: sets)
                            }
                        }
                    } header: {
                        Label("Quick Add Previous Sets", systemImage: "clock.arrow.circlepath")
                    }
                    .listRowBackground(UltraThinView())
                }
                
                Section {
                    ForEach(filteredExercises, id: \.id) { exercise in
                        Button {
                            selectedExercise = exercise
                        } label: {
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .foregroundStyle(.primary)
                                Text(exercise.muscle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Label("All Exercises", systemImage: "dumbbell")
                }
                .listRowBackground(UltraThinView())
            }
        }
        .scrollContentBackground(.hidden)
        .searchable(text: $searchText, prompt: "Search exercises")
        .navigationTitle("Select Exercise")
    }
}

private struct QuickAddExerciseGroup: View {
    @EnvironmentObject private var workoutManager: WorkoutManager
    let exerciseName: String
    let sets: [ExercizeSet]
    
    var body: some View {
        DisclosureGroup {
            ForEach(sets, id: \.id) { set in
                QuickAddSetButton(set: set)
            }
        } label: {
            Text(exerciseName)
        }
    }
}

private struct QuickAddSetButton: View {
    @EnvironmentObject private var workoutManager: WorkoutManager
    let set: ExercizeSet
    
    var body: some View {
        Button {
            let newSet = ExercizeSet(
                id: UUID(),
                reps: set.reps,
                weight: set.weight,
                timestamp: Date(),
                timeinterval: Date().timeIntervalSince(workoutManager.activeWorkout!.date),
                exercize: set.exercize,
                hitFailure: set.hitFailure
            )
            workoutManager.activeWorkout!.exercizeSets.append(newSet)
            WorkoutStorage.shared.saveWorkoutState()
        } label: {
            HStack {
                Circle()
                    .fill(set.hitFailure.color)
                    .frame(width: 12, height: 12)
                Text("\(set.reps) reps @ \(String(format: "%.1f", set.weight))kg")
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }
}
