//
    //  Gym_TrackerApp.swift
    //  Gym Tracker
    //
    //  Created by Adon Omeri on 12/4/2025.
    //

import SwiftUI
import SwiftData
import ColorfulX

@main
struct Gym_TrackerApp: App {
    @State private var isDarkMode = UserSettings.shared.themeMode == .dark
    @State private var workoutManager = WorkoutManager()
    
    init() {
        loadAndGroupExercizes()
    }
    
    var body: some Scene {
        WindowGroup {
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
                
                WorkoutBannerView()
            }
            .environment(workoutManager)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear {
                setupThemeChangeListener()
            }
        }
        .modelContainer(for: [BookmarkEntity.self], isAutosaveEnabled: true)
    }
    
    func setupThemeChangeListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ThemeChanged"), object: nil, queue: .main) { _ in
            isDarkMode = UserSettings.shared.themeMode == .dark
        }
    }
}

