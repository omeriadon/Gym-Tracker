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
}

#Preview {
    ContentView()
}
