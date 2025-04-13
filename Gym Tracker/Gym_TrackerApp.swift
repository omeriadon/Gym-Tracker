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
    
    
    
    var body: some Scene {
        WindowGroup {
            
            TabView {
                    // Using ZStack approach for tab content to have independent gradients per tab
                Tab {
                    ContentView()
                } label: {
                    Label("GymTracker", systemImage: "house")
                }
                
                Tab {
                    LibraryView()
                } label: {
                    Label("Library", systemImage: "rectangle.stack")
                }
                
                Tab {
                    SettingsView()
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear {
                setupThemeChangeListener()
                loadAndGroupExercizes()
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

