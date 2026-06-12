import Foundation
import HealthKit

@MainActor
final class HealthKitService: ObservableObject {
    static let shared = HealthKitService()

    @Published private(set) var isConnected = false
    @Published private(set) var isAvailable = HKHealthStore.isHealthDataAvailable()
    @Published var errorMessage: String?
    @Published var statusMessage: String?

    private let healthStore = HKHealthStore()

    private var fastingSessionType: HKCategoryType? {
        HKObjectType.categoryType(forIdentifier: .mindfulSession)
    }

    private init() {
        refreshAuthorizationStatus()
    }

    func refreshAuthorizationStatus() {
        guard isAvailable, let fastingSessionType else {
            isConnected = false
            return
        }

        isConnected = healthStore.authorizationStatus(for: fastingSessionType) == .sharingAuthorized
    }

    func requestAuthorization() async {
        guard isAvailable, let fastingSessionType else {
            errorMessage = "Apple Health is not available on this device."
            isConnected = false
            return
        }

        do {
            try await healthStore.requestAuthorization(toShare: Set([fastingSessionType]), read: Set([fastingSessionType]))
            refreshAuthorizationStatus()
            statusMessage = isConnected ? "Apple Health is connected." : "Apple Health permission was not enabled. You can change this anytime in the Apple Health app."
        } catch {
            errorMessage = "Apple Health permission could not be completed."
            refreshAuthorizationStatus()
        }
    }

    func saveFastSession(_ record: FastRecord) async {
        guard isAvailable, isConnected, let fastingSessionType else { return }

        let endDate = record.endedAt ?? record.plannedEndDate
        guard endDate > record.startDate else { return }

        let sample = HKCategorySample(
            type: fastingSessionType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: record.startDate,
            end: endDate,
            metadata: [
                HKMetadataKeyExternalUUID: record.id.uuidString,
                "WeeklyFastingTargetHours": record.targetHours,
                "WeeklyFastingStatus": record.status.rawValue
            ]
        )

        do {
            try await healthStore.save(sample)
        } catch {
            errorMessage = "Apple Health sync could not save this fasting session."
        }
    }
}
