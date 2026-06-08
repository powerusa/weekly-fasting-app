import SwiftUI

struct OnboardingView: View {
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple, Color(red: 0.35, green: 0.18, blue: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 34) {
                Spacer()

                AppLogoView(size: 118)
                    .shadow(color: .black.opacity(0.22), radius: 28, y: 18)

                VStack(spacing: 12) {
                    Text("Weekly Fasting App")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Plan your fasting week, track progress, and stay consistent.")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.86))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 24)
                }

                Spacer()

                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(.white)
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)
                .padding(.bottom, 28)
            }
        }
    }
}
