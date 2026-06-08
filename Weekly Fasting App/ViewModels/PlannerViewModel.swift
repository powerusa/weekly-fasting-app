import Foundation
import SwiftData

enum PlannerViewModel {
    static let presetDurations: [Double] = [12, 14, 16, 18, 20, 24, 36, 48, 72, 96, 120, 168]

    static func shortDurationLabel(for hours: Double) -> String {
        let value = Int(hours.rounded())
        if value >= 48, value.isMultiple(of: 24) {
            return "\(value / 24)d"
        }
        return "\(value)h"
    }

    static func durationDescription(for hours: Double) -> String {
        let value = Int(hours.rounded())
        if value >= 48, value.isMultiple(of: 24) {
            let days = value / 24
            return days == 1 ? "1 day" : "\(days) days"
        }
        return value == 1 ? "1 hour" : "\(value) hours"
    }

    static func seedDefaultPlansIfNeeded(_ plans: [FastingPlan], context: ModelContext) {
        guard plans.isEmpty else { return }
        FastingPlan.defaultPlans().forEach { context.insert($0) }
        try? context.save()
    }

    static func seedPreferencesIfNeeded(_ preferences: [UserPreferences], context: ModelContext) {
        guard preferences.isEmpty else { return }
        context.insert(UserPreferences())
        try? context.save()
    }

    static func nextScheduledFast(from plans: [FastingPlan], date: Date = Date()) -> FastingPlan? {
        let enabledPlans = plans.filter(\.isEnabled).sorted { $0.weekday < $1.weekday }
        guard !enabledPlans.isEmpty else { return nil }

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let mondayBasedWeekday = weekday == 1 ? 7 : weekday - 1

        return enabledPlans.first { $0.weekday >= mondayBasedWeekday } ?? enabledPlans.first
    }
}
