//
//  GradientBackgroundView.swift
//  Gym Tracker
//
//  Created by Adon Omeri on 12/4/2025.
//

import SwiftUI
import ColorfulX

/// A view that creates a subtle, slowly moving gradient background
/// This view wraps ColorfulX's ColorfulView with convenient defaults
/// and adds a fade to black/white at the top half
struct GradientBackgroundView: View {
    // Theme settings with default values
    @State private var colors: [Color]
    @State private var speed: Double
    @State private var bias: Double = 0.0
    @State private var noise: Double
    @State private var transitionSpeed: Double
    @State private var opacity: Double
    
    @Environment(\.colorScheme) private var colorScheme
    
    /// Creates a gradient background with the specified settings or random subtle defaults
    /// - Parameters:
    ///   - colors: Array of colors to use for the gradient. Providing nil will generate multiple shades of a random dark color.
    ///   - speed: Speed of the animation (0.1-1.0 recommended for subtlety)
    ///   - noise: Amount of noise/texture in the gradient (0.0-0.3 recommended for subtlety)
    ///   - transitionSpeed: How quickly colors transition (0.1-0.5 recommended for subtlety)
    ///   - opacity: Opacity of the entire gradient (0.1-0.5 recommended for subtlety)
    init(
        colors: [Color]? = nil,
        speed: Double = 0.25, // Slightly increased speed for more movement
        noise: Double = 0.25, // More noise for texture
        transitionSpeed: Double = 0.35, // Slightly faster transitions
        opacity: Double = 0.3
    ) {
        // If no colors provided, generate multiple shades of a random dark color
        let initialColors = colors ?? GradientBackgroundView.generateMultipleShades()
        _colors = State(initialValue: initialColors)
        _speed = State(initialValue: speed)
        _noise = State(initialValue: noise)
        _transitionSpeed = State(initialValue: transitionSpeed)
        _opacity = State(initialValue: opacity)
    }
    
    var body: some View {
        ZStack {
            // Base animated gradient
            ColorfulView(
                color: $colors,
                speed: $speed,
                bias: $bias,
                noise: $noise,
                transitionSpeed: $transitionSpeed
            )
            .opacity(opacity)
            
            // Top overlay that fades to black/white
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Top part that is solid black/white
                    Rectangle()
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .frame(height: geometry.size.height * 0.15)
                    
                    // Gradient from solid black/white to transparent
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: colorScheme == .dark ? Color.black : Color.white, location: 0),
                            .init(color: (colorScheme == .dark ? Color.black : Color.white).opacity(0), location: 1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: geometry.size.height * 0.35)
                    
                    Spacer() // Remaining space is transparent
                }
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Helper Methods
    
    /// Generates a single dark, rich color for the background
    /// - Returns: A single dark color (red, blue, purple, or green)
    static func generateSingleDarkColor() -> Color {
        // Define dark rich colors
        let darkColors = [
            Color(red: 0.5, green: 0.0, blue: 0.0),  // Dark Red
            Color(red: 0.0, green: 0.0, blue: 0.4),  // Dark Blue
            Color(red: 0.3, green: 0.0, blue: 0.3),  // Dark Purple
            Color(red: 0.0, green: 0.3, blue: 0.0),  // Dark Green
        ]
        
        // Return a random dark color
        return darkColors.randomElement() ?? Color(red: 0.0, green: 0.0, blue: 0.4) // Default to dark blue
    }
    
    /// Generates multiple shades of the same color family
    /// - Returns: An array of 3-4 colors that are different shades of the same base color
    static func generateMultipleShades() -> [Color] {
        // Choose a random base color first
        let baseColor = generateSingleDarkColor()
        
        // Extract RGB components from UIColor
        let uiColor = UIColor(baseColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Determine which color family we're working with
        var colorFamily: ColorFamily = .blue // default
        
        if red > 0.4 && green < 0.2 && blue < 0.2 {
            colorFamily = .red
        } else if green > 0.2 && red < 0.2 && blue < 0.2 {
            colorFamily = .green
        } else if blue > 0.3 && red < 0.2 && green < 0.2 {
            colorFamily = .blue
        } else if blue > 0.2 && red > 0.2 && green < 0.2 {
            colorFamily = .purple
        }
        
        // Generate 3-4 different shades of the same color
        return generateShades(for: colorFamily, count: Int.random(in: 3...4))
    }
    
    /// Helper enum to represent color families
    private enum ColorFamily {
        case red, green, blue, purple
    }
    
    /// Generates specific shades for a given color family
    /// - Parameters:
    ///   - family: The color family to generate shades for
    ///   - count: The number of shades to generate
    /// - Returns: An array of colors in the same family
    private static func generateShades(for family: ColorFamily, count: Int) -> [Color] {
        switch family {
        case .red:
            return [
                Color(red: 0.5, green: 0.0, blue: 0.0),   // Dark red
                Color(red: 0.6, green: 0.1, blue: 0.1),   // Medium red
                Color(red: 0.4, green: 0.0, blue: 0.1),   // Darker red with hint of blue
                Color(red: 0.5, green: 0.1, blue: 0.0)    // Red with hint of orange
            ].shuffled().prefix(count).map { $0 }
            
        case .green:
            return [
                Color(red: 0.0, green: 0.3, blue: 0.0),   // Dark green
                Color(red: 0.1, green: 0.4, blue: 0.1),   // Medium green
                Color(red: 0.0, green: 0.3, blue: 0.1),   // Green with hint of blue
                Color(red: 0.1, green: 0.3, blue: 0.0)    // Green with hint of yellow
            ].shuffled().prefix(count).map { $0 }
            
        case .blue:
            return [
                Color(red: 0.0, green: 0.0, blue: 0.4),   // Dark blue
                Color(red: 0.1, green: 0.1, blue: 0.5),   // Medium blue
                Color(red: 0.0, green: 0.1, blue: 0.4),   // Blue with hint of green
                Color(red: 0.1, green: 0.0, blue: 0.4)    // Blue with hint of purple
            ].shuffled().prefix(count).map { $0 }
            
        case .purple:
            return [
                Color(red: 0.3, green: 0.0, blue: 0.3),   // Dark purple
                Color(red: 0.4, green: 0.0, blue: 0.4),   // Medium purple
                Color(red: 0.3, green: 0.0, blue: 0.4),   // Purple with more blue
                Color(red: 0.4, green: 0.0, blue: 0.3)    // Purple with more red
            ].shuffled().prefix(count).map { $0 }
        }
    }
    
    /// Returns a new instance with different shades of a random dark color
    /// Useful for ensuring different views get different color schemes
    static func random() -> GradientBackgroundView {
        let randomSpeed = Double.random(in: 0.2...0.4) // Increased range for more movement
        let randomNoise = Double.random(in: 0.2...0.4) // More noise for visual interest
        let randomTransitionSpeed = Double.random(in: 0.3...0.5) // Faster transitions
        let randomOpacity = Double.random(in: 0.2...0.4)
        
        return GradientBackgroundView(
            colors: generateMultipleShades(), // Multiple shades of the same color
            speed: randomSpeed,
            noise: randomNoise,
            transitionSpeed: randomTransitionSpeed,
            opacity: randomOpacity
        )
    }
}

// MARK: - Adding Gradient to Other Views
extension View {
    /// Adds a subtle animated gradient background to any view
    /// - Returns: The original view with a gradient background
    func withGradientBackground() -> some View {
        ZStack {
            GradientBackgroundView.random()
            self
        }
    }
}

#Preview {
    VStack {
        Text("Subtle Gradient Background")
            .font(.title)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
            )
            .padding()
    }
    .withGradientBackground()
}
