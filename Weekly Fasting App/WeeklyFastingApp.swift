import SwiftData
import SwiftUI

@main
struct WeeklyFastingApp: App {
    private let modelContainer: ModelContainer = {
        let schema = Schema([
            FastingPlan.self,
            FastRecord.self,
            UserPreferences.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(modelContainer)
        }
    }
}
