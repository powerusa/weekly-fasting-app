import Foundation
import SwiftData

@Model
final class FastingPlan {
    @Attribute(.unique) var id: UUID
    var weekday: Int
    var durationHours: Double
    var isEnabled: Bool
    var createdAt: Date

    init(weekday: Int, durationHours: Double = 16, isEnabled: Bool = false) {
        self.id = UUID()
        self.weekday = weekday
        self.durationHours = durationHours
        self.isEnabled = isEnabled
        self.createdAt = Date()
    }

    var dayName: String {
        Self.dayNames[weekday - 1]
    }

    var shortName: String {
        Self.shortDayNames[weekday - 1]
    }

    static let dayNames = [
        "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ]

    static let shortDayNames = [
        "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
    ]

    static func defaultPlans() -> [FastingPlan] {
        [
            FastingPlan(weekday: 1, durationHours: 16, isEnabled: true),
            FastingPlan(weekday: 2, durationHours: 16),
            FastingPlan(weekday: 3, durationHours: 18, isEnabled: true),
            FastingPlan(weekday: 4, durationHours: 16),
            FastingPlan(weekday: 5, durationHours: 24, isEnabled: true),
            FastingPlan(weekday: 6, durationHours: 16),
            FastingPlan(weekday: 7, durationHours: 16)
        ]
    }
}
