import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var workoutManager: WorkoutManager
    @State private var showingNewWorkoutSheet = false
    
    @State var TEMPname: String = "New Workout"
    @State var TEMPnotes: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView.random()
                
                VStack {
                    if let workout = workoutManager.activeWorkout {
                        VStack {
                            Text("Active Workout: \(workout.name)")
                                .font(.headline)
                            // Display workout duration
                            if let startTime = workoutManager.workoutStartTime {
                                Text(formatDuration(Date().timeIntervalSince(startTime)))
                                    .font(.title2)
                                    .monospacedDigit()
                            }
                            Spacer()
                            
                            Button("End Workout") {
                                workoutManager.endWorkout()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                    } else {
                        VStack {
                            Text("No Active Workout")
                                .font(.headline)
                                .padding()
                            Button("Start New Workout") {
                                showingNewWorkoutSheet = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .navigationTitle("Active Workout")
                .sheet(isPresented: $showingNewWorkoutSheet) {
                    NavigationStack {
                        Spacer()
                            .frame(height: 15)
                        VStack {
                            List {
                                Section {
                                    TextField("Workout name", text: $TEMPname)
                                    TextField("Notes", text: $TEMPnotes)
                                }
                                .listRowBackground(UltraThinView())
                            }
                            .scrollContentBackground(.hidden)
                            VStack {
                                Spacer()
                                Button {
                                    // Initialize WorkoutStorage with the model context
                                    WorkoutStorage.shared.setModelContext(modelContext)
                                    
                                    // Start the workout using WorkoutManager
                                    workoutManager.startWorkout(name: TEMPname)
                                    
                                    // Update the notes if provided
                                    if !TEMPnotes.isEmpty {
                                        workoutManager.activeWorkout?.notes = TEMPnotes
                                    }
                                    
                                    showingNewWorkoutSheet = false
                                } label: {
                                    Text("Start Workout")
                                        .padding()
                                        .background { UltraThinView() }
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                }
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                        .toolbar {
                            Button(role: .cancel) {
                                showingNewWorkoutSheet = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding()
                        .navigationTitle("New Workout")
                    }
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(30)
                    .presentationBackground(content: { UltraThinView() })
                    .scrollDismissesKeyboard(.immediately)
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
