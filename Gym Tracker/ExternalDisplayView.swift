//
//  ExternalDisplayView.swift
//  Gym Tracker
//
//  Created by Adon Omeri on 14/4/2025.
//

import Foundation
import SwiftUI


struct ExternalDisplayView: View {
    
    @EnvironmentObject private var workoutManager: WorkoutManager

    
    var body: some View {
        
        
        
//        if let workout = workoutManager.activeWorkout {
//            NavigationStack {
//                VStack {
//                    Text("test")
//                }
//                .navigationTitle(workout.name)
//            }
//        } else {
//            Text("No active workout")
//                .font(.largeTitle)
//        }
        
        Text("Hello, World!")
            .font(.system(size: 96, weight: .bold))
            .foregroundColor(.blue)
            .multilineTextAlignment(.center)
            .onAppear {
                print("External display view appeared.")
            }
    }
}


