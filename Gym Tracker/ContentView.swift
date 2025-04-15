//
//  ContentView.swift
//  Gym Tracker
//
//  Created by Adon Omeri on 12/4/2025.
//

import SwiftUI
import ColorfulX
import SwiftData

struct ContentView: View {
    @State var name = SettingsView.getName()
    @EnvironmentObject private var workoutManager: WorkoutManager
    @Query var completedWorkouts: [Workout]

    var lastThreeWorkouts: [Workout] {
        return completedWorkouts.suffix(3).reversed()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackgroundView.random()
                
                if completedWorkouts.isEmpty {
                    ContentUnavailableView {
                        Label("No Workouts", systemImage: "dumbbell")
                    } description: {
                        Text("Start your fitness journey today!")
                    } actions: {
                        Button {
                            // This will be handled by the tab view selection
                        } label: {
                            Text("Start Workout")
                                .padding()
                                .background(UltraThinView())
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                            .frame(height: 15)
                        
                        List {
                            Section {
                                Text("Hello, \(name)")
                                    .font(.title)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                            }
                            .listRowBackground(UltraThinView())
                            
                            if !lastThreeWorkouts.isEmpty {
                                Section {
                                    ForEach(lastThreeWorkouts) { workout in
                                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                            VStack(alignment: .leading) {
                                                Text(workout.name)
                                                    .font(.headline)
                                                HStack {
                                                    Text(workout.date, style: .date)
                                                    Spacer()
                                                    Text(formatDuration(workout.duration))
                                                        .monospacedDigit()
                                                }
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                } header: {
                                    Label("Recent Workouts", systemImage: "clock.arrow.circlepath")
                                }
                                .listRowBackground(UltraThinView())
                            }
                            
                            Section {
                                NavigationLink {
                                    ProgressView()
                                } label: {
                                    Label("View Progress", systemImage: "chart.line.uptrend.xyaxis")
                                        .frame(height: 40)
                                }
                            } header: {
                                Label("Progress", systemImage: "chart.bar")
                            }
                            .listRowBackground(UltraThinView())
                        }
                        .scrollContentBackground(.hidden)
                    }
                    .scrollIndicators(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
            .onAppear {
                name = ContentView.getName()
            }
            .navigationTitle("GymTracker")
        }
    }
    
    static func getName() -> String {
        let settings = UserSettings.shared
        return settings.firstName
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
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
    ContentView()
}
