import Charts
import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FastRecord.startDate, order: .reverse) private var records: [FastRecord]

    private var finishedThisWeek: [FastRecord] {
        HistoryViewModel.finishedThisWeek(from: records)
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
        .onAppear {
            HistoryViewModel.completeExpiredActiveFasts(in: records, context: modelContext)
        }
    }

    private var historyContent: some View {
        VStack(spacing: 18) {
            HStack(spacing: 12) {
                StatCard(title: "Finished", value: "\(finishedThisWeek.count)", systemImage: "checkmark.circle.fill", color: .blue)
                StatCard(title: "Hours", value: "\(Int(HistoryViewModel.totalHoursThisWeek(from: records).rounded()))", systemImage: "clock.fill", color: .purple)
            }

            HStack(spacing: 12) {
                StatCard(title: "This Week", value: "\(finishedThisWeek.count)", systemImage: "calendar", color: .teal)
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
                    Text("Fasts This Week")
                        .font(.headline)

                    if finishedThisWeek.isEmpty {
                        Text("Finished fasts will appear here.")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(finishedThisWeek) { record in
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(record.startDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.subheadline.weight(.semibold))
                                    Text(record.status == .completed ? "\(Int(record.targetHours)) hour target" : "Ended early")
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
