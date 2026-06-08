import Foundation
import SwiftUI

struct FastingStage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
}

@MainActor
final class FastingTimerViewModel: ObservableObject {
    @Published var now = Date()

    private var timer: Timer?

    func startClock() {
        stopClock()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.now = Date()
            }
        }
    }

    func stopClock() {
        timer?.invalidate()
        timer = nil
    }

    func progress(for record: FastRecord) -> Double {
        guard record.plannedDuration > 0 else { return 0 }
        return min(max(now.timeIntervalSince(record.startDate) / record.plannedDuration, 0), 1)
    }

    func elapsedTime(for record: FastRecord) -> TimeInterval {
        max(0, now.timeIntervalSince(record.startDate))
    }

    func remainingTime(for record: FastRecord) -> TimeInterval {
        max(0, record.plannedEndDate.timeIntervalSince(now))
    }

    func countdownText(for record: FastRecord) -> String {
        Self.formatDuration(remainingTime(for: record))
    }

    func elapsedText(for record: FastRecord) -> String {
        Self.formatDuration(elapsedTime(for: record))
    }

    func currentStage(for record: FastRecord) -> FastingStage {
        Self.stage(forElapsedHours: elapsedTime(for: record) / 3600)
    }

    static func formatDuration(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval.rounded()))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    static func stage(forElapsedHours hours: Double) -> FastingStage {
        switch hours {
        case 0..<4:
            FastingStage(title: "Fed State", subtitle: "0-4 hours", systemImage: "fork.knife.circle.fill")
        case 4..<12:
            FastingStage(title: "Fat Burning Starting", subtitle: "4-12 hours", systemImage: "flame.circle.fill")
        case 12..<16:
            FastingStage(title: "Fat Burning", subtitle: "12-16 hours", systemImage: "flame.fill")
        case 16..<24:
            FastingStage(title: "Ketosis Zone", subtitle: "16-24 hours", systemImage: "moon.stars.fill")
        default:
            FastingStage(title: "Deep Fast", subtitle: "24+ hours", systemImage: "sparkles")
        }
    }
}
