import Charts
import SwiftData
import SwiftUI

struct HistoryView: View {
    @Query(sort: \FastRecord.startDate, order: .reverse) private var records: [FastRecord]

    private var completedThisWeek: [FastRecord] {
        HistoryViewModel.completedThisWeek(from: records)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    historyContent
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("History")
        }
    }

    private var historyContent: some View {
        VStack(spacing: 18) {
            HStack(spacing: 12) {
                StatCard(title: "Completed", value: "\(completedThisWeek.count)", systemImage: "checkmark.circle.fill", color: .blue)
                StatCard(title: "Hours", value: "\(Int(HistoryViewModel.totalHoursThisWeek(from: records).rounded()))", systemImage: "clock.fill", color: .purple)
            }

            HStack(spacing: 12) {
                StatCard(title: "This Week", value: "\(completedThisWeek.count)", systemImage: "calendar", color: .teal)
                StatCard(title: "Best Streak", value: "\(HistoryViewModel.bestStreak(from: records))", systemImage: "flame.fill", color: .orange)
            }

            PremiumCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Last 7 Days")
                        .font(.headline)

                    Chart(HistoryViewModel.lastSevenDays(from: records)) { item in
                        BarMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Hours", item.hours)
                        )
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .purple], startPoint: .bottom, endPoint: .top)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisValueLabel(format: .dateTime.weekday(.narrow))
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .frame(height: 220)
                }
            }

            PremiumCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Completed Fasts This Week")
                        .font(.headline)

                    if completedThisWeek.isEmpty {
                        Text("Completed fasts will appear here.")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(completedThisWeek) { record in
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(record.startDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.subheadline.weight(.semibold))
                                    Text("\(Int(record.targetHours)) hour target")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(Int(record.completedHours.rounded()))h")
                                    .font(.headline.monospacedDigit())
                            }
                            Divider()
                        }
                    }
                }
            }
        }
    }
}
