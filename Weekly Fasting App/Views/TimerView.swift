import SwiftData
import SwiftUI

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FastRecord.startDate, order: .reverse) private var records: [FastRecord]
    @Query private var preferences: [UserPreferences]
    @StateObject private var timer = FastingTimerViewModel()
    @State private var selectedHours: Double = 16
    @State private var showingEditStartTime = false
    @State private var editedStartDate = Date()

    private let durationColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private var activeFast: FastRecord? {
        records.first { $0.status == .active }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let activeFast {
                        activeTimer(activeFast)
                    } else {
                        idleTimer
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Timer")
        }
        .sheet(isPresented: $showingEditStartTime) {
            NavigationStack {
                Form {
                    DatePicker("Start Time", selection: $editedStartDate, displayedComponents: [.date, .hourAndMinute])
                }
                .navigationTitle("Edit Start Time")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingEditStartTime = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveEditedStartTime()
                            showingEditStartTime = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .onAppear {
            selectedHours = preferences.first?.defaultFastingHours ?? 16
            HistoryViewModel.completeExpiredActiveFasts(in: records, context: modelContext)
            timer.startClock()
        }
        .onChange(of: timer.now) {
            HistoryViewModel.completeExpiredActiveFasts(in: records, context: modelContext)
        }
        .onDisappear {
            timer.stopClock()
        }
    }

    private func activeTimer(_ record: FastRecord) -> some View {
        VStack(spacing: 20) {
            PremiumCard {
                VStack(spacing: 22) {
                    ProgressRing(progress: timer.progress(for: record), lineWidth: 20) {
                        VStack(spacing: 8) {
                            Text(timer.countdownText(for: record))
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .minimumScaleFactor(0.65)
                            Text("Remaining")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: 278)

                    let stage = timer.currentStage(for: record)
                    HStack {
                        Label(stage.title, systemImage: stage.systemImage)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(stage.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            PremiumCard {
                VStack(spacing: 16) {
                    TimeRow(title: "Start Time", value: record.startDate.formatted(date: .omitted, time: .shortened), systemImage: "play.circle.fill")
                    TimeRow(title: "End Time", value: record.plannedEndDate.formatted(date: .omitted, time: .shortened), systemImage: "flag.checkered.circle.fill")
                    TimeRow(title: "Elapsed", value: timer.elapsedText(for: record), systemImage: "clock.fill")
                    TimeRow(title: "Remaining", value: timer.countdownText(for: record), systemImage: "hourglass")
                }
            }

            VStack(spacing: 12) {
                GradientButton(title: "End Fast", systemImage: "checkmark.circle.fill") {
                    endFast(record)
                }

                Button {
                    editedStartDate = record.startDate
                    showingEditStartTime = true
                } label: {
                    Label("Edit Start Time", systemImage: "calendar")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button(role: .destructive) {
                    cancelFast(record)
                } label: {
                    Label("Cancel Fast", systemImage: "xmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }

    private var idleTimer: some View {
        VStack(spacing: 20) {
            PremiumCard {
                VStack(spacing: 24) {
                    ProgressRing(progress: 0, lineWidth: 20) {
                        VStack(spacing: 8) {
                            Text(PlannerViewModel.shortDurationLabel(for: selectedHours))
                                .font(.system(size: 58, weight: .bold, design: .rounded))
                                .minimumScaleFactor(0.7)
                            Text("Ready to Start")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: 278)

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Fasting Length")
                                .font(.headline)
                            Spacer()
                            Text(PlannerViewModel.durationDescription(for: selectedHours))
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }

                        LazyVGrid(columns: durationColumns, alignment: .leading, spacing: 10) {
                            ForEach(PlannerViewModel.presetDurations, id: \.self) { hours in
                                DurationPill(
                                    title: PlannerViewModel.shortDurationLabel(for: hours),
                                    isSelected: Int(selectedHours) == Int(hours)
                                ) {
                                    withAnimation(.spring(duration: 0.25)) {
                                        selectedHours = hours
                                    }
                                }
                            }
                        }

                        Stepper(value: $selectedHours, in: 1...168, step: 1) {
                            Label("Custom", systemImage: "slider.horizontal.3")
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                }
            }

            GradientButton(title: "Start Fast", systemImage: "timer") {
                startFast(hours: selectedHours)
            }
        }
    }

    private func startFast(hours: Double) {
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

    private func endFast(_ record: FastRecord) {
        let end = Date()
        record.endedAt = end
        record.status = end >= record.plannedEndDate ? .completed : .endedEarly
        NotificationService.shared.cancelFastNotifications()
        try? modelContext.save()
    }

    private func cancelFast(_ record: FastRecord) {
        record.endedAt = Date()
        record.status = .canceled
        NotificationService.shared.cancelFastNotifications()
        try? modelContext.save()
    }

    private func saveEditedStartTime() {
        guard let record = activeFast else { return }
        record.startDate = editedStartDate
        record.plannedEndDate = editedStartDate.addingTimeInterval(record.targetHours * 3600)
        try? modelContext.save()
    }
}
