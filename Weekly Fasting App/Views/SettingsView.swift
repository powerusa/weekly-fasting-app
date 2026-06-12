import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("appearance") private var storedAppearance = AppAppearance.system.rawValue
    @Query private var preferences: [UserPreferences]
    @StateObject private var healthKitService = HealthKitService.shared
    @State private var showingDisclaimer = false
    @State private var showingAppleHealthExplanation = false

    private let privacyPolicyURL = URL(string: "https://powerusa.github.io/weekly-fasting-app/privacy-policy.html")!
    private var appleHealthStatusText: String {
        healthKitService.isConnected ? "Apple Health: Connected" : "Apple Health: Not Connected"
    }

    private var preference: UserPreferences? {
        preferences.first
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Fasting") {
                    if let preference {
                        Picker("Default Fasting Length", selection: Binding(
                            get: { preference.defaultFastingHours },
                            set: {
                                preference.defaultFastingHours = min(max($0, 1), 168)
                                try? modelContext.save()
                            }
                        )) {
                            ForEach(PlannerViewModel.presetDurations, id: \.self) { duration in
                                Text(PlannerViewModel.durationDescription(for: duration)).tag(duration)
                            }
                        }

                        Stepper(value: Binding(
                            get: { preference.defaultFastingHours },
                            set: {
                                preference.defaultFastingHours = min(max($0, 1), 168)
                                try? modelContext.save()
                            }
                        ), in: 1...168, step: 1) {
                            HStack {
                                Label("Custom Default", systemImage: "slider.horizontal.3")
                                Spacer()
                                Text(PlannerViewModel.shortDurationLabel(for: preference.defaultFastingHours))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Apple Health") {
                    AppleHealthInfoSection(statusText: appleHealthStatusText)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)

                    Text("Connect Apple Health to allow Weekly Fasting to sync fasting and wellness data. You can use the app without Apple Health.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button {
                        showingAppleHealthExplanation = true
                    } label: {
                        Label("Connect Apple Health", systemImage: "heart.fill")
                    }

                    if !healthKitService.isAvailable {
                        Text("Apple Health is not available on this device.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Notifications") {
                    if let preference {
                        Toggle("Notifications", isOn: Binding(
                            get: { preference.notificationsEnabled },
                            set: {
                                preference.notificationsEnabled = $0
                                try? modelContext.save()
                            }
                        ))
                        Toggle("Fast Started", isOn: notificationBinding(\.notifyFastStarted))
                        Toggle("Almost Finished", isOn: notificationBinding(\.notifyAlmostFinished))
                        Toggle("Fast Completed", isOn: notificationBinding(\.notifyFastCompleted))
                    }
                }

                Section("Appearance") {
                    Picker("Appearance", selection: Binding(
                        get: { AppAppearance(rawValue: storedAppearance) ?? .system },
                        set: { appearance in
                            storedAppearance = appearance.rawValue
                            preference?.appearance = appearance
                            try? modelContext.save()
                        }
                    )) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.rawValue).tag(appearance)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("App Store") {
                    HStack {
                        Label("Access", systemImage: "checkmark.seal.fill")
                        Spacer()
                        Text("Full App")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("About") {
                    Button("Health Disclaimer") {
                        showingDisclaimer = true
                    }

                    Link(destination: privacyPolicyURL) {
                        HStack {
                            Label("Privacy Policy", systemImage: "lock.shield.fill")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack {
                        Text("App Version")
                        Spacer()
                        Text(Bundle.main.appVersion)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
        }
        .onAppear {
            healthKitService.refreshAuthorizationStatus()
        }
        .sheet(isPresented: $showingAppleHealthExplanation) {
            AppleHealthPermissionSheet(isAvailable: healthKitService.isAvailable) {
                await healthKitService.requestAuthorization()
            }
        }
        .sheet(isPresented: $showingDisclaimer) {
            InfoSheet(title: "Health Disclaimer", systemImage: "heart.text.square.fill", text: "This app is for tracking and educational purposes only. It is not medical advice. Always consult your doctor before fasting.")
        }
        .alert("Apple Health", isPresented: Binding(
            get: { healthKitService.errorMessage != nil },
            set: { if !$0 { healthKitService.errorMessage = nil } }
        )) {
            Button("OK") { healthKitService.errorMessage = nil }
        } message: {
            Text(healthKitService.errorMessage ?? "")
        }
        .alert("Apple Health", isPresented: Binding(
            get: { healthKitService.statusMessage != nil },
            set: { if !$0 { healthKitService.statusMessage = nil } }
        )) {
            Button("OK") { healthKitService.statusMessage = nil }
        } message: {
            Text(healthKitService.statusMessage ?? "")
        }
    }

    private func notificationBinding(_ keyPath: ReferenceWritableKeyPath<UserPreferences, Bool>) -> Binding<Bool> {
        Binding(
            get: { preference?[keyPath: keyPath] ?? true },
            set: { newValue in
                preference?[keyPath: keyPath] = newValue
                try? modelContext.save()
            }
        )
    }
}
