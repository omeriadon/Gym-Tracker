import SwiftUI
import SwiftData

class WorkoutListManager {
    static let shared = WorkoutListManager()
    private var modelContext: ModelContext

    private init() {
        self.modelContext = EnvironmentValues().modelContext
    }

    func fetchWorkouts() -> [Workout] {
        let fetchDescriptor = FetchDescriptor<Workout>()
        return (try? modelContext.fetch(fetchDescriptor)) ?? []
    }
}

struct WorkoutListView: View {
    @State private var workouts: [Workout] = []

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackgroundView.random()

                VStack {
                    Spacer()
                        .frame(height: 15)

                    if workouts.isEmpty {
                        Text("No Workouts")
                            .foregroundColor(.secondary)
                    } else {
                        List {
                            ForEach(workouts) { workout in
                                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                    VStack(alignment: .leading) {
                                        Text(workout.name)
                                            .font(.headline)
                                        Text(workout.date, style: .date)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .listRowBackground(UltraThinView())
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle("Workouts")
            .onAppear {
                workouts = WorkoutListManager.shared.fetchWorkouts()
            }
        }
    }
}

#Preview {
    WorkoutListView()
}
