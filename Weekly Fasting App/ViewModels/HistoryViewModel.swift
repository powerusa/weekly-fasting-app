import Foundation

struct DayFastingSummary: Identifiable {
    let id = UUID()
    let date: Date
    let hours: Double
}

enum HistoryViewModel {
    static func completedThisWeek(from records: [FastRecord]) -> [FastRecord] {
        let calendar = Calendar.current
        return records.filter { record in
            record.status == .completed && calendar.isDate(record.startDate, equalTo: Date(), toGranularity: .weekOfYear)
        }
    }

    static func totalHoursThisWeek(from records: [FastRecord]) -> Double {
        completedThisWeek(from: records).reduce(0) { $0 + $1.completedHours }
    }

    static func bestStreak(from records: [FastRecord]) -> Int {
        let completedDays = Set(records.filter { $0.status == .completed }.map {
            Calendar.current.startOfDay(for: $0.startDate)
        })
        let sortedDays = completedDays.sorted()
        guard !sortedDays.isEmpty else { return 0 }

        var best = 1
        var current = 1
        for index in 1..<sortedDays.count {
            let previous = sortedDays[index - 1]
            let currentDay = sortedDays[index]
            if Calendar.current.dateComponents([.day], from: previous, to: currentDay).day == 1 {
                current += 1
                best = max(best, current)
            } else {
                current = 1
            }
        }
        return best
    }

    static func lastSevenDays(from records: [FastRecord]) -> [DayFastingSummary] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let hours = records
                .filter { record in
                    record.status == .completed && calendar.isDate(record.startDate, inSameDayAs: date)
                }
                .reduce(0) { $0 + $1.completedHours }

            return DayFastingSummary(date: date, hours: hours)
        }
    }
}
