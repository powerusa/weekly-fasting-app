import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FastRecord.startDate, order: .reverse) private var records: [FastRecord]
    @Query(sort: \FastingPlan.weekday) private var plans: [FastingPlan]
    @Query private var preferences: [UserPreferences]
    @StateObject private var timer = FastingTimerViewModel()

    private var activeFast: FastRecord? {
        records.first { $0.status == .active }
    }

    private var weeklyCompleted: [FastRecord] {
        HistoryViewModel.completedThisWeek(from: records)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    statusCard
                    nextFastCard
                    weeklyProgressCard
                    GradientButton(title: activeFast == nil ? "Quick Start Fast" : "Fast Running", systemImage: "bolt.fill") {
                        guard activeFast == nil else { return }
                        startQuickFast()
                    }
                    .disabled(activeFast != nil)
                    .opacity(activeFast == nil ? 1 : 0.55)
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Today")
        }
        .onAppear {
            timer.startClock()
            completeExpiredActiveFastIfNeeded()
        }
        .onDisappear {
            timer.stopClock()
        }
    }

    private var statusCard: some View {
        PremiumCard {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(activeFast == nil ? "Today’s Status" : "Active Fast")
                            .font(.headline)
                        Text(activeFast == nil ? "Ready when you are" : "Stay steady and hydrated.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: activeFast == nil ? "sun.max.fill" : "moon.stars.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }

                if let activeFast {
                    ProgressRing(progress: timer.progress(for: activeFast), lineWidth: 18) {
                        VStack(spacing: 6) {
                            Text(timer.countdownText(for: activeFast))
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .monospacedDigit()
                            Text("Remaining")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: 232)

                    Label(timer.currentStage(for: activeFast).title, systemImage: timer.currentStage(for: activeFast).systemImage)
                        .font(.headline)
                        .foregroundStyle(.primary)
                } else {
                    ProgressRing(progress: Double(weeklyCompleted.count) / 3, lineWidth: 18) {
                        VStack(spacing: 6) {
                            Text("\(weeklyCompleted.count)")
                                .font(.system(size: 54, weight: .bold, design: .rounded))
                            Text("Completed")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: 232)
                }
            }
        }
    }

    private var nextFastCard: some View {
        PremiumCard {
            HStack(spacing: 14) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 42, height: 42)
                    .background(.blue.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Scheduled Fast")
                        .font(.headline)

                    if let next = PlannerViewModel.nextScheduledFast(from: plans) {
                        Text("\(next.dayName), \(Int(next.durationHours)) hours")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No fasting days selected")
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
        }
    }

    private var weeklyProgressCard: some View {
        PremiumCard {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weekly Progress")
                        .font(.headline)
                    Text("\(Int(HistoryViewModel.totalHoursThisWeek(from: records).rounded())) fasting hours")
                        .font(.title2.bold())
                    Text("\(weeklyCompleted.count) completed fasts this week")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 46))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.purple)
            }
        }
    }

    private func startQuickFast() {
        let hours = preferences.first?.defaultFastingHours ?? 16
        let start = Date()
        let end = start.addingTimeInterval(hours * 3600)
        let record = FastRecord(startDate: start, plannedEndDate: end, targetHours: hours)
        modelContext.insert(record)
        try? modelContext.save()

        let prefs = preferences.first
        Task {
            await NotificationService.shared.scheduleFastNotifications(
                startDate: start,
                endDate: end,
                settings: NotificationSettings(
                    enabled: prefs?.notificationsEnabled ?? true,
                    fastStarted: prefs?.notifyFastStarted ?? true,
                    almostFinished: prefs?.notifyAlmostFinished ?? true,
                    completed: prefs?.notifyFastCompleted ?? true
                )
            )
        }
    }

    private func completeExpiredActiveFastIfNeeded() {
        guard let activeFast, Date() >= activeFast.plannedEndDate else { return }
        activeFast.status = .completed
        activeFast.endedAt = activeFast.plannedEndDate
        try? modelContext.save()
    }
}
