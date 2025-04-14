import SwiftUI
import ColorfulX

struct WorkoutBannerView: View {
    @Environment(WorkoutManager.self) private var workoutManager
    @State private var isAppearing = false
    
    var body: some View {
        Color.clear
            .frame(height: 0)
            .safeAreaInset(edge: .top) {
                if let workout = workoutManager.activeWorkout {
                    VStack(spacing: 4) {
                        HStack {
                            Text(workout.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .transition(.moveAndFade())
                            
                            Spacer()
                            
                            withAnimation(.default) {
                                Text(formatDuration(workout.duration))
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundStyle(.primary)
                                    .contentTransition(.numericText())
                            }
                            
                            
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    workoutManager.endWorkout()
                                }
                            } label: {
                                Text("End")
                                    .fontWeight(.medium)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                        
                        if let currentExercise = workout.exerciseSets.last?.excersize.name {
                            Text(currentExercise)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                                .transition(.moveAndFade())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(
                        ZStack {
                            GradientBackgroundView.random()
                            Rectangle()
                                .fill(.ultraThinMaterial)
                        }
                    )
                    .opacity(isAppearing ? 1 : 0)
                    .offset(y: isAppearing ? 0 : -20)
                    .onAppear {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isAppearing = true
                        }
                    }
                    .onDisappear {
                        isAppearing = false
                    }
                }
            }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

extension AnyTransition {
    static func moveAndFade() -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
}
