//
//  ContentView.swift
//  Gym Tracker
//
//  Created by Adon Omeri on 12/4/2025.
//

import SwiftUI
import ColorfulX

struct ContentView: View {
    @State private var name = SettingsView.getName()
    @State private var workoutManager = WorkoutManager()
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                NavigationStack {
                    ZStack {
                        GradientBackgroundView.random()
                        
                        VStack {
                            Text("Hello, \(name)")
                                .font(.largeTitle)
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(10)
                        }
                    }
                    .onAppear {
                        name = ContentView.getName()
                    }
                    .navigationTitle("GymTracker")
                }
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
    }
    
    static func getName() -> String {
        let settings = UserSettings.shared
        return settings.firstName
    }
}

#Preview {
    ContentView()
}
