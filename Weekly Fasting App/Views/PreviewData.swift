import SwiftData
import SwiftUI

@MainActor
enum PreviewData {
    static let container: ModelContainer = {
        let schema = Schema([FastingPlan.self, FastRecord.self, UserPreferences.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])

        FastingPlan.defaultPlans().forEach { container.mainContext.insert($0) }
        container.mainContext.insert(UserPreferences())

        let calendar = Calendar.current
        let start = calendar.date(byAdding: .hour, value: -7, to: Date())!
        container.mainContext.insert(
            FastRecord(startDate: start, plannedEndDate: start.addingTimeInterval(16 * 3600), targetHours: 16)
        )

        for offset in 1...5 {
            let startDate = calendar.date(byAdding: .day, value: -offset, to: Date())!
            container.mainContext.insert(
                FastRecord(
                    startDate: startDate,
                    plannedEndDate: startDate.addingTimeInterval(16 * 3600),
                    targetHours: 16,
                    status: .completed,
                    endedAt: startDate.addingTimeInterval(16 * 3600)
                )
            )
        }

        return container
    }()
}

#Preview("Home") {
    MainTabView()
        .modelContainer(PreviewData.container)
}
