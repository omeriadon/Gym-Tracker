import WidgetKit
import SwiftUI
import SwiftData
import os

private let logger = Logger(subsystem: "com.omeriadon.GymTracker", category: "HomeScreenWidget")

struct HomeScreenProvider: TimelineProvider {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            Workout.self,
            ExercizeSet.self,
            Exercize.self,
            Bookmark.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.omeriadon.GymTracker")
        )
        
        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            logger.error("Failed to create model container: \(error.localizedDescription)")
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    func placeholder(in context: Context) -> HomeScreenEntry {
        HomeScreenEntry(date: Date(), lastWorkout: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (HomeScreenEntry) -> ()) {
        Task { @MainActor in
            let entry = await getEntry()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HomeScreenEntry>) -> ()) {
        Task { @MainActor in
            let entry = await getEntry()
            let currentDate = Date()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    @MainActor
    private func getEntry() async -> HomeScreenEntry {
        let context = modelContainer.mainContext
        var fetchDescriptor = FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { !$0.isActive }, sortBy: [SortDescriptor(\Workout.date, order: .reverse)]
        )
        fetchDescriptor.fetchLimit = 1
        
        do {
            let lastWorkout = try context.fetch(fetchDescriptor).first
            logger.debug("Found last workout: \(lastWorkout?.name ?? "nil"), date: \(lastWorkout?.date ?? Date())")
            return HomeScreenEntry(date: Date(), lastWorkout: lastWorkout)
        } catch {
            logger.error("Failed to fetch workout: \(error.localizedDescription)")
            return HomeScreenEntry(date: Date(), lastWorkout: nil)
        }
    }
}

struct HomeScreenEntry: TimelineEntry {
    let date: Date
    let lastWorkout: Workout?
}

struct HomeScreenWidgetEntryView: View {
    var entry: HomeScreenProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var shouldShowWorkoutEncouragement: Bool {
        guard let lastWorkout = entry.lastWorkout else { return true }
        let hoursSinceLastWorkout = Date().timeIntervalSince(lastWorkout.date) / 3600
        return hoursSinceLastWorkout >= 5
    }
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry, shouldEncourage: shouldShowWorkoutEncouragement)
        case .systemMedium:
            MediumWidgetView(entry: entry, shouldEncourage: shouldShowWorkoutEncouragement)
        default:
            Text("Unsupported widget size")
        }
    }
}

private struct SmallWidgetView: View {
    let entry: HomeScreenEntry
    let shouldEncourage: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            if shouldEncourage {
                Spacer(minLength: 0)
                Image(systemName: "figure.run")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("Time to")
                    .font(.callout)
                Text("Work Out!")
                    .font(.headline)
                Spacer(minLength: 0)
            } else if let workout = entry.lastWorkout {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last Workout")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(workout.name)
                        .font(.callout)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer(minLength: 4)
                    
                    Label("\(workout.exercizeSets.count)", systemImage: "number")
                        .font(.caption2)
                    Text(formatDuration(workout.duration))
                        .font(.caption2.monospaced())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .containerBackground(.ultraThinMaterial, for: .widget)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}

private struct MediumWidgetView: View {
    let entry: HomeScreenEntry
    let shouldEncourage: Bool
    
    var body: some View {
        HStack {
            if shouldEncourage {
                VStack(spacing: 8) {
                    Image(systemName: "figure.run")
                        .font(.title)
                        .foregroundStyle(.blue)
                    Text("Time to Work Out!")
                        .font(.headline)
                    Text("It's been a while since your last session")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            } else if let workout = entry.lastWorkout {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Workout")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(workout.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    HStack {
                        Label("\(workout.exercizeSets.count) sets", systemImage: "number")
                            .font(.caption)
                        Spacer()
                        Text(formatDuration(workout.duration))
                            .font(.caption.monospaced())
                    }
                    .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
        .containerBackground(.ultraThinMaterial, for: .widget)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return hours > 0 ? String(format: "%d:%02d hr", hours, minutes) : String(format: "%d min", minutes)
    }
}

struct HomeScreenWidget: Widget {
    let kind: String = "HomeScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HomeScreenProvider()) { entry in
            HomeScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Gym Tracker")
        .description("See your last workout or get motivated")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
