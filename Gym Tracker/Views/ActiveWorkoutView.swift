import SwiftUI

struct ActiveWorkoutView: View {
    @Environment(WorkoutManager.self) private var workoutManager
    @State private var showingNewWorkoutSheet = false
    
    @State var TEMPname: String = "New Workout"
    @State var TEMPnotes: String = ""


    
    var body: some View {
        NavigationView {
            ZStack {
                    // Add the gradient background
                GradientBackgroundView.random()
                
                VStack {
                    if let workout = workoutManager.activeWorkout {
                            // Active workout view
                        VStack {
                            Text("Active Workout: \(workout.name)")
                                .font(.headline)
                            
                                // TODO: Add exercise list, timer, and other workout controls
                            
                            Spacer()
                        }
                    } else {
                            // No active workout view
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
                .navigationTitle(workoutManager.activeWorkout?.name ?? "New Workout")
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
                                    workoutManager.startWorkout()
                                    workoutManager.activeWorkout?.name = TEMPname
                                    workoutManager.activeWorkout?.date = Date.now
                                    workoutManager.activeWorkout?.notes = TEMPnotes
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
}
