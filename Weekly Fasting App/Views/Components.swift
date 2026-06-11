import SwiftUI

struct PremiumCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 8)
    }
}

struct GradientButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
}

struct ProgressRing<Content: View>: View {
    let progress: Double
    let lineWidth: CGFloat
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Circle()
                .stroke(.secondary.opacity(0.13), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.45, dampingFraction: 0.86), value: progress)
            content
        }
        .padding(lineWidth / 2)
    }
}

struct DurationPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 46)
                .foregroundStyle(isSelected ? .white : .primary)
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.secondary.opacity(0.1))

                    if isSelected {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(isSelected ? 0.22 : 0), lineWidth: 1)
                }
                .shadow(color: isSelected ? .blue.opacity(0.22) : .clear, radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color

    var body: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct AppleHealthInfoSection: View {
    let statusText: String?
    let showsCareKitNote: Bool

    init(statusText: String? = nil, showsCareKitNote: Bool = true) {
        self.statusText = statusText
        self.showsCareKitNote = showsCareKitNote
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Apple Health Integration", systemImage: "heart.fill")
                .font(.headline)
                .foregroundStyle(.primary)

            Text("This app uses HealthKit to save fasting sessions and related wellness data to Apple Health when you give permission.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let statusText {
                Label(statusText, systemImage: statusText.contains("Connected") ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(statusText.contains("Connected") ? .green : .secondary)
            }

            Text("You can manage or revoke Apple Health permissions anytime in the Apple Health app.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if showsCareKitNote {
                Text("This app does not use CareKit.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct AppleHealthPermissionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onContinue: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 54))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.red)

                Text("Apple Health Integration")
                    .font(.largeTitle.bold())
                    .fixedSize(horizontal: false, vertical: true)

                Text("Weekly Fasting App can save your fasting sessions and related wellness data to Apple Health. Health access is optional and only used with your permission.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                GradientButton(title: "Continue to Apple Health", systemImage: "heart.fill") {
                    dismiss()
                    onContinue()
                }
            }
            .padding(24)
            .frame(maxWidth: 620, alignment: .leading)
            .background(Color.appBackground)
            .navigationTitle("Apple Health")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct TimeRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
            Spacer()
            Text(value)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

struct InfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let systemImage: String
    let text: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Image(systemName: systemImage)
                    .font(.system(size: 62))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
                Text(text)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                Spacer()
            }
            .padding(28)
            .background(Color.appBackground)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct AppLogoView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))

            Circle()
                .trim(from: 0.08, to: 0.88)
                .stroke(.white.opacity(0.9), style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round))
                .frame(width: size * 0.58, height: size * 0.58)
                .rotationEffect(.degrees(-70))

            Image(systemName: "moon.fill")
                .font(.system(size: size * 0.28, weight: .semibold))
                .foregroundStyle(.white)
                .offset(x: size * 0.12, y: -size * 0.1)

            Image(systemName: "calendar")
                .font(.system(size: size * 0.3, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))
                .offset(x: -size * 0.12, y: size * 0.13)
        }
        .frame(width: size, height: size)
    }
}

extension Color {
    static var appBackground: Color {
        Color(uiColor: .systemBackground)
    }

    static var cardBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }
}

extension Bundle {
    var appVersion: String {
        let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}
