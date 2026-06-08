import SwiftData
import SwiftUI

struct PlannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FastingPlan.weekday) private var plans: [FastingPlan]

    private let durationColumns = [
        GridItem(.adaptive(minimum: 52), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    ForEach(plans) { plan in
                        dayCard(plan)
                    }

                    PremiumCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("Fasting Stages", systemImage: "sparkles")
                                .font(.headline)

                            ForEach(stageRows, id: \.0) { row in
                                HStack {
                                    Text(row.0)
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text(row.1)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Weekly Planner")
        }
    }

    private func dayCard(_ plan: FastingPlan) -> some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.dayName)
                            .font(.title3.bold())
                        Text(plan.isEnabled ? "\(PlannerViewModel.durationDescription(for: plan.durationHours)) fast" : "No fast planned")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { plan.isEnabled },
                        set: { newValue in
                            withAnimation(.spring(duration: 0.3)) {
                                plan.isEnabled = newValue
                                try? modelContext.save()
                            }
                        }
                    ))
                    .labelsHidden()
                }

                LazyVGrid(columns: durationColumns, alignment: .leading, spacing: 10) {
                    ForEach(PlannerViewModel.presetDurations, id: \.self) { duration in
                        DurationPill(
                            title: PlannerViewModel.shortDurationLabel(for: duration),
                            isSelected: Int(plan.durationHours) == Int(duration)
                        ) {
                            update(plan: plan, hours: duration)
                        }
                    }

                    DurationPill(title: "Custom", isSelected: !PlannerViewModel.presetDurations.contains(plan.durationHours)) {
                        update(plan: plan, hours: plan.durationHours)
                    }
                }

                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Custom Duration")
                            .font(.subheadline.weight(.semibold))
                        Text("1 hour to 7 days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Stepper(value: Binding(
                        get: { plan.durationHours },
                        set: { update(plan: plan, hours: $0) }
                    ), in: 1...168, step: 1) {
                        Text(PlannerViewModel.shortDurationLabel(for: plan.durationHours))
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var stageRows: [(String, String)] {
        [
            ("0-4 hours", "Fed State"),
            ("4-12 hours", "Fat Burning Starting"),
            ("12-16 hours", "Fat Burning"),
            ("16-24 hours", "Ketosis Zone"),
            ("24+ hours", "Deep Fast")
        ]
    }

    private func update(plan: FastingPlan, hours: Double) {
        let clampedHours = min(max(hours, 1), 168)
        withAnimation(.spring(duration: 0.28)) {
            plan.durationHours = clampedHours
            plan.isEnabled = true
            try? modelContext.save()
        }
    }
}
