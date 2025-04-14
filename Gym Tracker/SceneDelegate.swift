//
//  SceneDelegate.swift
//  Gym Tracker
//
//  Created by Adon Omeri on 14/4/2025.
//

import Foundation
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            print("Not a valid window scene")
            return
        }
        
            // Debugging: Print the session role to check what role we are dealing with
        print("Session role: \(session.role)")
        
        if session.role == .windowExternalDisplayNonInteractive {
            print("External display connected!")
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: ExternalDisplayView()) // Display the content on the external screen
            self.window = window
            window.makeKeyAndVisible()
        } else {
            print("No external display detected")
        }
    }
}

