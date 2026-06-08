import SwiftData
import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer = false
    @AppStorage("appearance") private var appearance = AppAppearance.system.rawValue

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView {
                    withAnimation(.spring(duration: 0.5)) {
                        hasCompletedOnboarding = true
                    }
                }
            } else if !hasAcceptedDisclaimer {
                DisclaimerView {
                    withAnimation(.spring(duration: 0.5)) {
                        hasAcceptedDisclaimer = true
                    }
                }
            } else {
                MainTabView()
            }
        }
        .preferredColorScheme(preferredScheme)
    }

    private var preferredScheme: ColorScheme? {
        switch AppAppearance(rawValue: appearance) ?? .system {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}
