import SwiftData
import SwiftUI

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FastingPlan.weekday) private var plans: [FastingPlan]
    @Query private var preferences: [UserPreferences]

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            PlannerView()
                .tabItem {
                    Label("Planner", systemImage: "calendar")
                }

            TimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.blue)
        .task {
            PlannerViewModel.seedDefaultPlansIfNeeded(plans, context: modelContext)
            PlannerViewModel.seedPreferencesIfNeeded(preferences, context: modelContext)
        }
    }
}
