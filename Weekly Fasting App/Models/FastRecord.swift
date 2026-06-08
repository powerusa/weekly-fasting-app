import Foundation
import SwiftData

enum FastStatus: String, Codable {
    case active
    case completed
    case endedEarly
    case canceled
}

@Model
final class FastRecord {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var plannedEndDate: Date
    var endedAt: Date?
    var targetHours: Double
    var statusRawValue: String
    var createdAt: Date

    init(
        startDate: Date,
        plannedEndDate: Date,
        targetHours: Double,
        status: FastStatus = .active,
        endedAt: Date? = nil
    ) {
        self.id = UUID()
        self.startDate = startDate
        self.plannedEndDate = plannedEndDate
        self.targetHours = targetHours
        self.statusRawValue = status.rawValue
        self.endedAt = endedAt
        self.createdAt = Date()
    }

    var status: FastStatus {
        get { FastStatus(rawValue: statusRawValue) ?? .active }
        set { statusRawValue = newValue.rawValue }
    }

    var duration: TimeInterval {
        (endedAt ?? Date()).timeIntervalSince(startDate)
    }

    var plannedDuration: TimeInterval {
        plannedEndDate.timeIntervalSince(startDate)
    }

    var completedHours: Double {
        max(0, duration / 3600)
    }

    var isFinished: Bool {
        status != .active
    }
}
