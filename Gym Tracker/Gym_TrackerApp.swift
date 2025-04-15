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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    
    @State private var isDarkMode = UserSettings.shared.themeMode == .dark
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var observableModelContainer = ObservableModelContainer()
    
    init() {
        loadAndGroupExercizes()
    }
    
    var body: some Scene {
        WindowGroup {
            
            
            VStack {
                WorkoutBannerView()
                
                
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

            }
            .onAppear {
                setupThemeChangeListener()
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .environmentObject(workoutManager)
            .environment(\.modelContext, observableModelContainer.container.mainContext)
            
            .environmentObject(observableModelContainer)


        }

    }
    
    func setupThemeChangeListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ThemeChanged"), object: nil, queue: .main) { _ in
            isDarkMode = UserSettings.shared.themeMode == .dark
        }
    }
}

