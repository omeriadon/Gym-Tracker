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

                VStack {
                    Text("Hello, \(name)")
                        .font(.largeTitle)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    
                    Spacer()
                        .frame(height: 40)

                    if !lastThreeWorkouts.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Last 3 Workouts")
                                .font(.headline)
                                .padding(.top)

                            ForEach(lastThreeWorkouts, id: \.id) { workout in
                                HStack {
                                    Text(workout.name)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(formatDuration(workout.duration))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    }
                }
                .padding()
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
