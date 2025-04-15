//
//  SceneDelegate.swift
//  Gym Tracker
//
//  Created by Adon Omeri on 14/4/2025.
//

import Foundation
import SwiftUI
import SwiftData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var observableModelContainer = ObservableModelContainer()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            print("Not a valid window scene")
            return
        }
        
        print("Session role: \(session.role)")
        
        if session.role == .windowExternalDisplayNonInteractive {
            print("External display connected!")
            let window = UIWindow(windowScene: windowScene)
            
            let contentView = ExternalDisplayView()
                .environmentObject(WorkoutManager.shared)
                .environment(\.modelContext, observableModelContainer.container.mainContext)
            
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        } else {
            print("No external display detected")
        }
    }
}

