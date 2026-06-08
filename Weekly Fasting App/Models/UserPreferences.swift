import Foundation
import SwiftData

enum AppAppearance: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }
}

@Model
final class UserPreferences {
    @Attribute(.unique) var id: String
    var defaultFastingHours: Double
    var notificationsEnabled: Bool
    var notifyFastStarted: Bool
    var notifyAlmostFinished: Bool
    var notifyFastCompleted: Bool
    var appearanceRawValue: String

    init(
        id: String = "primary",
        defaultFastingHours: Double = 16,
        notificationsEnabled: Bool = true,
        notifyFastStarted: Bool = true,
        notifyAlmostFinished: Bool = true,
        notifyFastCompleted: Bool = true,
        appearance: AppAppearance = .system
    ) {
        self.id = id
        self.defaultFastingHours = defaultFastingHours
        self.notificationsEnabled = notificationsEnabled
        self.notifyFastStarted = notifyFastStarted
        self.notifyAlmostFinished = notifyAlmostFinished
        self.notifyFastCompleted = notifyFastCompleted
        self.appearanceRawValue = appearance.rawValue
    }

    var appearance: AppAppearance {
        get { AppAppearance(rawValue: appearanceRawValue) ?? .system }
        set { appearanceRawValue = newValue.rawValue }
    }
}
