import SwiftUI

struct ExerciseSetLogView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var workoutManager: WorkoutManager
    let exercise: Exercize
    let onSave: (ExercizeSet) -> Void
    let onCancel: () -> Void
    
    @State private var reps = ""
    @State private var weight = ""
    @State private var failureLevel: FailureLevel = .noFailure
    
    var body: some View {
        List {
            Section {
                Text(exercise.name)
                    .font(.headline)
            } header: {
                Label("Selected Exercise", systemImage: "dumbbell")
            }
            .listRowBackground(UltraThinView())
            
            Section {
                TextField("Reps", text: $reps)
                    .keyboardType(.numberPad)
                TextField("Weight (kg)", text: $weight)
                    .keyboardType(.decimalPad)
                Picker("Failure Level", selection: $failureLevel) {
                    ForEach([FailureLevel.noFailure, .mildDiscomfort, .almostFailure, .completeFailure], id: \.self) { level in
                        HStack {
                            Circle()
                                .fill(level.color)
                                .frame(width: 12, height: 12)
                            Text(level.description)
                        }
                    }
                }
                .listRowBackground(failureLevel.color.opacity(0.2))
                .pickerStyle(.menu)
                

            } header: {
                Label("Set Details", systemImage: "chart.bar")
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Log Exercise Set")
        
        Button {
            guard let repsInt = Int(reps),
                  let weightDouble = Double(weight),
                  let workout = workoutManager.activeWorkout else { return }
            
            let set = ExercizeSet(
                id: UUID(),
                reps: repsInt,
                weight: weightDouble,
                timestamp: Date(),
                timeinterval: Date().timeIntervalSince(workout.date),
                excersize: exercise,
                hitFailure: failureLevel
            )
            
            onSave(set)
        } label: {
            Text("Save Set")
                .padding()
                .background { UltraThinView() }
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .disabled(reps.isEmpty || weight.isEmpty)
        .padding()
    }
}
