import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var workoutManager: WorkoutManager
    @State private var showingNewWorkoutSheet = false
    @State private var showingExerciseSheet = false
    @State private var showExitConfirmation = false
    @State private var workoutName: String = ""
    @State private var workoutNotes: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView.random()
                
                VStack {
                    if let workout = workoutManager.activeWorkout {
                        ActiveWorkoutContent(
                            workout: workout,
                            showingExerciseSheet: $showingExerciseSheet
                        )
                    } else {
                        NoActiveWorkoutView(showingNewWorkoutSheet: $showingNewWorkoutSheet)
                    }
                }
                .navigationTitle("Active Workout")
                .sheet(isPresented: $showingNewWorkoutSheet) {
                    NewWorkoutSheet(
                        isPresented: $showingNewWorkoutSheet,
                        name: $workoutName,
                        notes: $workoutNotes,
                        modelContext: modelContext,
                        workoutManager: workoutManager
                    )
                }
                .sheet(isPresented: $showingExerciseSheet) {
                    ExerciseAddView(
                        showingExerciseSheet: $showingExerciseSheet,
                        showExitConfirmation: $showExitConfirmation
                    )
                }
            }
        }
    }
}

private struct ActiveWorkoutContent: View {
    let workout: Workout
    @Binding var showingExerciseSheet: Bool
    @EnvironmentObject private var workoutManager: WorkoutManager
    
    var body: some View {
        VStack {
            Text("Active Workout: \(workout.name)")
                .font(.headline)
            if let startTime = workoutManager.workoutStartTime {
                Text(formatDuration(Date().timeIntervalSince(startTime)))
                    .font(.title2)
                    .monospacedDigit()
            }
            
            ExerciseSetsList(workout: workout)
            
            Spacer()
            
            HStack {
                Button {
                    showingExerciseSheet = true
                } label: {
                    Label("Add Exercise", systemImage: "plus.circle.fill")
                        .padding()
                        .background { UltraThinView() }
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                Button {
                    workoutManager.endWorkout()
                } label: {
                    Label("End Workout", systemImage: "xmark.circle.fill")
                        .padding()
                        .background { UltraThinView() }
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .tint(.red)
            }
        }
    }
}

private struct ExerciseSetsList: View {
    let workout: Workout
    
    var body: some View {
        List {
            if !workout.exerciseSets.isEmpty {
                Section {
                    ForEach(workout.exerciseSets) { set in
                        ExerciseSetRow(set: set, workout: workout)
                    }
                    .onDelete { indices in
                        workout.exerciseSets.remove(atOffsets: indices)
                        WorkoutStorage.shared.saveWorkoutState()
                    }
                } header: {
                    Label("Exercise Sets", systemImage: "figure.strengthtraining.traditional")
                }
                .listRowBackground(UltraThinView())
            }
        }
        .scrollContentBackground(.hidden)
    }
}

private struct ExerciseSetRow: View {
    let set: ExercizeSet
    let workout: Workout
    @State private var isEditing = false
    @State private var editReps: String = ""
    @State private var editWeight: String = ""
    @State private var editFailureLevel: FailureLevel = .noFailure
    
    var body: some View {
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
                    WorkoutStorage.shared.saveWorkoutState()
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                editReps = "\(set.reps)"
                editWeight = "\(set.weight)"
                editFailureLevel = set.hitFailure
                isEditing = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.yellow)
            
            Button {
                let newSet = ExercizeSet(
                    id: UUID(),
                    reps: set.reps,
                    weight: set.weight,
                    timestamp: Date(),
                    timeinterval: Date().timeIntervalSince(workout.date),
                    excersize: set.excersize,
                    hitFailure: set.hitFailure
                )
                workout.exerciseSets.append(newSet)
                WorkoutStorage.shared.saveWorkoutState()
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }
            .tint(.blue)
        }
        .popover(isPresented: $isEditing) {
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
                                WorkoutStorage.shared.saveWorkoutState()
                                isEditing = false
                            }
                        }
                    }

                }
                .presentationCompactAdaptation(.sheet)
                .presentationCornerRadius(30)
                .presentationBackground(content: { UltraThinView() })
            }
        }
        
    }
}

private struct NoActiveWorkoutView: View {
    @Binding var showingNewWorkoutSheet: Bool
    
    var body: some View {
        VStack {
            Text("No Active Workout")
                .font(.headline)
                .padding()
            Button {
                showingNewWorkoutSheet = true
            } label: {
                Text("Start New Workout")
                    .padding()
                    .background { UltraThinView() }
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
    }
}

private struct NewWorkoutSheet: View {
    @Binding var isPresented: Bool
    @Binding var name: String
    @Binding var notes: String
    let modelContext: ModelContext
    let workoutManager: WorkoutManager
    
    var body: some View {
        NavigationStack {
            Spacer()
                .frame(height: 15)
            VStack {
                List {
                    Section {
                        TextField("Workout name (optional)", text: $name)
                        TextField("Notes", text: $notes)
                    }
                    .listRowBackground(UltraThinView())
                }
                .scrollContentBackground(.hidden)
                VStack {
                    Spacer()
                    Button {
                        WorkoutStorage.shared.setModelContext(modelContext)
                        workoutManager.startWorkout(name: name.isEmpty ? nil : name)
                        if !notes.isEmpty {
                            workoutManager.activeWorkout?.notes = notes
                        }
                        isPresented = false
                    } label: {
                        Text("Start Workout")
                            .padding()
                            .background { UltraThinView() }
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }

            .padding()
            .navigationTitle("New Workout")
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(30)
        .presentationBackground(content: { UltraThinView() })
        .scrollDismissesKeyboard(.immediately)
        .interactiveDismissDisabled()
    }
}

private func formatDuration(_ duration: TimeInterval) -> String {
    let hours = Int(duration) / 3600
    let minutes = Int(duration) / 60 % 60
    let seconds = Int(duration) % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}
