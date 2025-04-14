//
    //  Gym_TrackerApp.swift
    //  Gym Tracker
    //
    //  Created by Adon Omeri on 12/4/2025.
    //

import SwiftUI
import SwiftData
import ColorfulX

class ObservableModelContainer: ObservableObject, Observable {
    let container: ModelContainer

    init() {
        self.container = try! ModelContainer(for: Workout.self, ExercizeSet.self, Exercize.self, Bookmark.self)
    }
}

@main
struct Gym_TrackerApp: App {
    @State private var isDarkMode = UserSettings.shared.themeMode == .dark
    @State private var workoutManager = WorkoutManager()
    @StateObject private var observableModelContainer = ObservableModelContainer()

    init() {
        loadAndGroupExercizes()
    }
    
    var body: some Scene {
        WindowGroup {
            
            WorkoutBannerView()
                .environment(workoutManager)
                .environmentObject(observableModelContainer)
                .preferredColorScheme(isDarkMode ? .dark : .light)

        
            Spacer()
                .frame(height: 1)
            
            
            ZStack(alignment: .top) {
                TabView {
                    ContentView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    
                    ActiveWorkoutView()
                        .tabItem {
                            Label("Workout", systemImage: "figure.run")
                        }
                    
                    LibraryView()
                        .tabItem {
                            Label("Library", systemImage: "books.vertical")
                        }
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }

            }
            .environment(workoutManager)
            .environmentObject(observableModelContainer)
            .environment(\.modelContext, observableModelContainer.container.mainContext)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear {
                setupThemeChangeListener()
            }
        }
    }
    
    func setupThemeChangeListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ThemeChanged"), object: nil, queue: .main) { _ in
            isDarkMode = UserSettings.shared.themeMode == .dark
        }
    }
}

