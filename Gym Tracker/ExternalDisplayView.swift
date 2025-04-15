    //
    //  ExternalDisplayView.swift
    //  Gym Tracker
    //
    //  Created by Adon Omeri on 14/4/2025.
    //

import Foundation
import SwiftUI
import SwiftData

struct ExternalDisplayView: View {
    @EnvironmentObject private var workoutManager: WorkoutManager
    @State private var isDarkMode = UserSettings.shared.themeMode == .dark
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    GradientBackgroundView.random().ignoresSafeArea()
                    
                    if let workout = workoutManager.activeWorkout {
                        
                        
                        
                        
                        VStack {
                            
                            HStack {
                                
                                Spacer()
                                
                                Text(workout.date, style: .date)
                                    .padding()
                                    .font(.largeTitle)
                            }
                            .frame(height: 125)
                            
                            HStack {
                                
                                
                                
                                
                                
                                VStack {
                                    Text(workout.notes)
                                }
                                .frame(width: (UIScreen.main.bounds.width / 3 - 20), height: 600)
                                .padding()
                                .background(UltraThinView().blur(radius:5))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                
                                
                                VStack {
                                    
                                    
                                    
                                    
                                    VStack {
                                        Text("Exercize Sets")
                                            .font(.largeTitle)
                                        
                                        
                                        List {
                                            Section {
                                                ForEach(workout.exercizeSets) { exercizeSet in
                                                    HStack(alignment: .top) {
                                                        VStack(alignment: .leading) {
                                                            Text(exercizeSet.exercize.name)
                                                            Text(exercizeSet.exercize.muscle)
                                                                .foregroundStyle(.secondary)
                                                        }
                                                        Spacer()
                                                        Text(exercizeSet.exercize.group)
                                                            .foregroundStyle(.secondary)
                                                        
                                                    }
                                                    .frame(height: 40)
                                                }
                                            }
                                            .listRowBackground(UltraThinView())
                                        }
                                        
                                        .scrollContentBackground(.hidden)
                                        
                                    }
                                    .padding()
                                    .background(UltraThinView().blur(radius:5))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    
                                    
                                    
                                    
                                }
                                
                            }
                            .frame(width: UIScreen.main.bounds.width - 20)
                            
                            
                            
                            
                        }
                        
                            //                    .frame(width: UIScreen.main.bounds.width - 40)
                        
                        .padding()
                        .toolbar {
                            
                            ToolbarItem(placement: .navigationBarLeading) {
                                
                                Text(workout.name)
                                    .font(.largeTitle)
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                if let startTime = workoutManager.workoutStartTime {
                                    Text(formatDuration(currentTime.timeIntervalSince(startTime)))
                                        .font(.system(size: 96, design: .monospaced))
                                        .contentTransition(.numericText())
                                        .animation(.default, value: currentTime)
                                }
                                
                            }
                            
                            
                        }
                        
                        
                        
                        
                        
                        
                        
                        
                        
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "figure.run")
                                .font(.system(size: 60))
                            Text("No active workout")
                                .font(.largeTitle)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .scaleEffect(scaleFactor(for: geometry.size))  // Dynamic scaling based on display size
                .frame(width: geometry.size.width, height: geometry.size.height)  // Using geometry size for frame

            }

        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onReceive(timer) { time in
            currentTime = time
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ThemeChanged"), object: nil, queue: .main) { _ in
                isDarkMode = UserSettings.shared.themeMode == .dark
            }
        }
        
    }
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func scaleFactor(for size: CGSize) -> CGFloat {
            // Calculate scale factor based on target size
        let targetWidth: CGFloat = 2388  // Your target width
        let targetHeight: CGFloat = 1668  // Your target height
        
        let widthScale = size.width / targetWidth
        let heightScale = size.height / targetHeight
        
            // Return the smaller scale factor to maintain aspect ratio
        return min(widthScale, heightScale)
    }
    
    
}



#Preview(traits: .fixedLayout(width: 9146, height: 9642)) {
    
    let manager = WorkoutManager.shared
    manager.activeWorkout = Workout(id: UUID(), name: "Workout Name Long Longest", date: Date.now, duration: 1952, notes: "notes\nnotes\nnotes", exercizeSets: [ExercizeSet(id: UUID(), reps: 12, weight: 45, timestamp: Date.now, timeinterval: 14, exercize: Exercize(id: UUID(), name: "Exercize One", notes: ["notes one", "notes two"], muscle: "Muscle", timestamp: Date.now, group: "Chest"), hitFailure: .almostFailure), ExercizeSet(id: UUID(), reps: 12, weight: 45, timestamp: Date.now, timeinterval: 14, exercize: Exercize(id: UUID(), name: "Exercize One", notes: ["notes one", "notes two"], muscle: "Muscle", timestamp: Date.now, group: "Chest"), hitFailure: .almostFailure)], isActive: true)
    manager.workoutStartTime = Date.now
    
    
    return ExternalDisplayView()
        .environmentObject(WorkoutManager.shared)
    
}
