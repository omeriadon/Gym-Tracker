import SwiftUI
import SwiftData

class WorkoutListManager {
    static let shared = WorkoutListManager()
    private var modelContext: ModelContext?
    
    private init() {}
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func fetchWorkouts() -> [Workout] {
        guard let modelContext = modelContext else {
            print("Model context not set")
            return []
        }
        let fetchDescriptor = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\Workout.date, order: .reverse)])
        return (try? modelContext.fetch(fetchDescriptor)) ?? []
    }
}

struct WorkoutListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]

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
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let workoutToDelete = workouts[index]
                                    modelContext.delete(workoutToDelete)
                                    do {
                                        try modelContext.save()
                                    } catch {
                                        print("Failed to delete workout: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle("Workouts")
        }
    }
}

#Preview {
    WorkoutListView()
}
