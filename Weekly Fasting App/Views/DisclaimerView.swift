import SwiftUI

struct DisclaimerView: View {
    var onAccept: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 78))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)

                VStack(spacing: 14) {
                    Text("Health Disclaimer")
                        .font(.largeTitle.bold())

                    Text("This app is for tracking and educational purposes only. It is not medical advice. Always consult your doctor before fasting.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal)

                Spacer()

                GradientButton(title: "I Understand", systemImage: "checkmark.circle.fill", action: onAccept)
                    .padding(.horizontal)
                    .padding(.bottom, 22)
            }
            .background(Color.appBackground)
        }
    }
}
