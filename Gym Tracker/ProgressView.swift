//
    //  ProgressView.swift
    //  Gym Tracker
    //
    //  Created by Adon Omeri on 15/4/2025.
    //

import SwiftUI
import SwiftData
import ColorfulX

struct ProgressView: View {
    @Query var completedWorkouts: [Workout]
    
    @State var colors: [Color] = [.green, .red, .white, .blue]
    @State var speed: Double = 4
    @State var noise: Double = 30
    
    var longestWorkout: Workout? {
        completedWorkouts.max(by: { $0.duration < $1.duration })
    }
    
    var totalExercises: Int {
        completedWorkouts.reduce(0) { $0 + $1.exercizeSets.count }
    }
    
    var totalWeight: Double {
        completedWorkouts.reduce(0) { $0 + $1.exercizeSets.reduce(0) { $0 + ($1.weight * Double($1.reps)) } }
    }
    
    var averageWorkoutDuration: TimeInterval? {
        guard !completedWorkouts.isEmpty else { return nil }
        let total = completedWorkouts.reduce(0) { $0 + $1.duration }
        return total / Double(completedWorkouts.count)
    }
    
    var mostFrequentExercise: (name: String, count: Int)? {
        let exercises = completedWorkouts.flatMap { $0.exercizeSets.map { $0.exercize.name } }
        let counted = Dictionary(grouping: exercises, by: { $0 }).mapValues { $0.count }
        return counted.max(by: { $0.value < $1.value }).map { ($0.key, $0.value) }
    }
    
    // New computed properties
    var mostUsedMuscleGroup: (name: String, count: Int)? {
        let groups = completedWorkouts.flatMap { $0.exercizeSets.map { $0.exercize.group } }
        let counted = Dictionary(grouping: groups, by: { $0 }).mapValues { $0.count }
        return counted.max(by: { $0.value < $1.value }).map { ($0.key, $0.value) }
    }
    
    var averageWeightPerExercise: Double {
        guard totalExercises > 0 else { return 0 }
        return totalWeight / Double(totalExercises)
    }
    
    var totalFailureSets: Int {
        completedWorkouts.reduce(0) { total, workout in
            total + workout.exercizeSets.filter { $0.hitFailure == .completeFailure }.count
        }
    }
    
    var averageExercisesPerWorkout: Double {
        guard !completedWorkouts.isEmpty else { return 0 }
        return Double(totalExercises) / Double(completedWorkouts.count)
    }
    
    private var cards: [(systemImage: String, title: String, content: AnyView)] {
        var result: [(systemImage: String, title: String, content: AnyView)] = []
        
        // Workouts Completed Card
        result.append((
            systemImage: "figure.run",
            title: "Workouts Completed",
            content: AnyView(
                ColorfulView(color: $colors, speed: $speed, noise: $noise)
                    .frame(width: 200, height: 80)
                    .mask {
                        Text("\(completedWorkouts.count)")
                            .monospacedDigit()
                            .font(.system(size: 96))
                            .fontDesign(.monospaced)
                            .fontWeight(.black)
                    }
            )
        ))
        
        // Total Sets Card
        result.append((
            systemImage: "number",
            title: "Total Sets",
            content: AnyView(
                ColorfulView(color: $colors, speed: $speed, noise: $noise)
                    .frame(height: 80)
                    .mask {
                        Text("\(totalExercises)")
                            .monospacedDigit()
                            .font(.system(size: 60, weight: .black, design: .monospaced))
                    }
            )
        ))
        
        // Total Volume Card
        result.append((
            systemImage: "scalemass",
            title: "Total Volume",
            content: AnyView(
                ColorfulView(color: $colors, speed: $speed, noise: $noise)
                    .frame(height: 80)
                    .mask {
                        Text("\(Int(totalWeight))kg")
                            .monospacedDigit()
                            .font(.system(size: 60, weight: .black, design: .monospaced))
                    }
            )
        ))
        
        // Average Duration Card
        if let avgDuration = averageWorkoutDuration {
            result.append((
                systemImage: "timer",
                title: "Average Duration",
                content: AnyView(
                    ColorfulView(color: $colors, speed: $speed, noise: $noise)
                        .frame(height: 80)
                        .mask {
                            Text(formatDuration(avgDuration))
                                .monospacedDigit()
                                .font(.system(size: 60, weight: .black, design: .monospaced))
                        }
                )
            ))
        }
        
        // Most Popular Exercise Card
        if let (name, count) = mostFrequentExercise {
            result.append((
                systemImage: "dumbbell.fill",
                title: "Most Popular Exercise",
                content: AnyView(
                    ColorfulView(color: $colors, speed: $speed, noise: $noise)
                        .frame(height: 80)
                        .mask {
                            VStack(spacing: 4) {
                                Text(name)
                                    .font(.system(size: 32, weight: .black))
                                Text("\(count) times")
                                    .font(.system(size: 24, weight: .bold))
                            }
                        }
                )
            ))
        }
        
        // Longest Workout Card
        if let longest = longestWorkout {
            result.append((
                systemImage: "clock",
                title: "Longest Workout",
                content: AnyView(
                    ColorfulView(color: $colors, speed: $speed, noise: $noise)
                        .frame(height: 80)
                        .mask {
                            VStack(spacing: 4) {
                                Text(formatDuration(longest.duration))
                                    .monospacedDigit()
                                    .font(.system(size: 40, weight: .black))
                                Text(longest.name)
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                )
            ))
        }
        
        // Add new cards
        result.append((
            systemImage: "square.stack.3d.up",
            title: "Most Trained Group",
            content: AnyView(
                ColorfulView(color: $colors, speed: $speed, noise: $noise)
                    .frame(height: 80)
                    .mask {
                        if let (name, count) = mostUsedMuscleGroup {
                            VStack(spacing: 4) {
                                Text(name)
                                    .font(.system(size: 32, weight: .black))
                                Text("\(count) sets")
                                    .font(.system(size: 24, weight: .bold))
                            }
                        }
                    }
            )
        ))
        
        result.append((
            systemImage: "flame.fill",
            title: "Training Intensity",
            content: AnyView(
                ColorfulView(color: $colors, speed: $speed, noise: $noise)
                    .frame(height: 80)
                    .mask {
                        VStack(spacing: 4) {
                            Text("\(totalFailureSets)")
                                .font(.system(size: 40, weight: .black))
                            Text("Failure Sets")
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
            )
        ))
        
        result.append((
            systemImage: "chart.bar.fill",
            title: "Workout Density",
            content: AnyView(
                ColorfulView(color: $colors, speed: $speed, noise: $noise)
                    .frame(height: 80)
                    .mask {
                        VStack(spacing: 4) {
                            Text(String(format: "%.1f", averageExercisesPerWorkout))
                                .font(.system(size: 40, weight: .black))
                            Text("Sets/Workout")
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
            )
        ))
        
        result.append((
            systemImage: "scalemass.fill",
            title: "Average Weight/Set",
            content: AnyView(
                ColorfulView(color: $colors, speed: $speed, noise: $noise)
                    .frame(height: 80)
                    .mask {
                        VStack(spacing: 4) {
                            Text(String(format: "%.1f", averageWeightPerExercise))
                                .font(.system(size: 40, weight: .black))
                            Text("kg per set")
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
            )
        ))
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackgroundView()
                
                if completedWorkouts.isEmpty {
                    ContentUnavailableView {
                        Label("No Workouts", systemImage: "figure.run")
                    } description: {
                        Text("Start working out to see your progress")
                    }
                } else {
                    TabView {
                        ForEach(0..<cards.count, id: \.self) { index in
                            VStack {
                                CardView(systemImage: cards[index].systemImage, 
                                        title: cards[index].title) {
                                    cards[index].content
                                }
                                .frame(width: UIScreen.main.bounds.width - 40)
                                }
                            }
                        
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                }
            }
            .navigationTitle("Progress")

        }
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
    ProgressView()
}
