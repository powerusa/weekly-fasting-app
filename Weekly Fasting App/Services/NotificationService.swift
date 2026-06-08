import Foundation
import UserNotifications

struct NotificationSettings {
    var enabled: Bool
    var fastStarted: Bool
    var almostFinished: Bool
    var completed: Bool
}

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorizationIfNeeded() async {
        do {
            _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Notification authorization failed: \(error.localizedDescription)")
        }
    }

    func scheduleFastNotifications(startDate: Date, endDate: Date, settings: NotificationSettings) async {
        guard settings.enabled else { return }
        await requestAuthorizationIfNeeded()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "fast-started",
            "fast-almost-finished",
            "fast-completed"
        ])

        if settings.fastStarted {
            schedule(
                id: "fast-started",
                title: "Fast Started",
                body: "Your fasting timer is running.",
                date: Date().addingTimeInterval(1)
            )
        }

        if settings.almostFinished {
            let almostFinishedDate = endDate.addingTimeInterval(-15 * 60)
            if almostFinishedDate > Date() {
                schedule(
                    id: "fast-almost-finished",
                    title: "Almost Finished",
                    body: "Your fast is nearly complete.",
                    date: almostFinishedDate
                )
            }
        }

        if settings.completed, endDate > Date() {
            schedule(
                id: "fast-completed",
                title: "Fast Completed",
                body: "Your scheduled fast is complete.",
                date: endDate
            )
        }
    }

    func cancelFastNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "fast-started",
            "fast-almost-finished",
            "fast-completed"
        ])
    }

    private func schedule(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
