import SwiftUI

// MARK: - OnboardingView
/// Onboarding flow introducing users to each tab of the app
struct OnboardingView: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var currentPage = 0
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private let pages = OnboardingPage.allPages
    
    private var usesCompactLayout: Bool {
        dynamicTypeSize.usesExpandedChrome || verticalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.currentPrimary.opacity(0.1), Color.currentAccent.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index], usesCompactLayout: usesCompactLayout)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom controls
                VStack(spacing: usesCompactLayout ? 12 : 24) {
                    // Page indicator dots
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.currentAccent : Color.currentSecondaryText.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Navigation buttons
                    VStack(spacing: 12) {
                        if currentPage > 0 {
                            Button("Previous") {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if currentPage < pages.count - 1 {
                            Button("Next") {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .frame(maxWidth: .infinity)
                        } else {
                            Button("Get Started") {
                                logger.logUserAction("Complete onboarding")
                                completeOnboarding()
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .frame(maxWidth: .infinity)
                            .accessibilityIdentifier(AccessibilityIdentifiers.onboardingGetStarted)
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, usesCompactLayout ? 12 : 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func completeOnboarding() {
        logger.info("Onboarding completed")
        UserDefaults.standard.set(true, forKey: ThemePreferences.hasCompletedOnboarding)
        AppEvent.post(.onboardingCompleted)
    }
}

// MARK: - OnboardingPageView
struct OnboardingPageView: View {
    let page: OnboardingPage
    let usesCompactLayout: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: usesCompactLayout ? 20 : 32) {
                Spacer(minLength: usesCompactLayout ? 8 : 24)

                // Icon
                ZStack {
                    Circle()
                        .fill(page.color.opacity(0.2))
                        .frame(width: usesCompactLayout ? 88 : 120, height: usesCompactLayout ? 88 : 120)

                    Image(systemName: page.icon)
                        .font(.system(size: usesCompactLayout ? 36 : 50, weight: .medium))
                        .foregroundColor(page.color)
                }

                // Content
                VStack(spacing: 16) {
                    Text(page.title)
                        .h2()
                        .foregroundColor(Color.currentText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(page.description)
                        .bodyLarge()
                        .foregroundColor(Color.currentSecondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 8)

                Spacer(minLength: usesCompactLayout ? 8 : 24)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

// MARK: - OnboardingPage Model
struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to TrackBoth",
            description: "Track your habits and vices with simple yes/no logging. Build streaks, set goals, and visualize your progress over time.",
            icon: "house.fill",
            color: Color.currentPrimary
        ),
        OnboardingPage(
            title: "Home Tab",
            description: "Your daily habit dashboard. Toggle habits on/off, view your streaks, and see today's progress at a glance.",
            icon: "house.fill",
            color: Color.currentSuccess
        ),
        OnboardingPage(
            title: "History Tab",
            description: "View your tracking history in a beautiful calendar. See patterns, search entries, and review your journey over time.",
            icon: "calendar",
            color: Color.currentWarning
        ),
        OnboardingPage(
            title: "Goals Tab",
            description: "Set monthly and yearly targets for your habits. Track progress with visual indicators and stay motivated to reach your goals.",
            icon: "target",
            color: Color.currentAccent
        ),
        OnboardingPage(
            title: "Charts Tab",
            description: "Visualize your data with interactive charts. See trends, streaks, and patterns to understand your habits better.",
            icon: "chart.bar.fill",
            color: Color.currentPrimary
        ),
        OnboardingPage(
            title: "Motivation Tab",
            description: "Build your motivation library. Add reasons for avoiding vices and revisit them when you need strength to stay on track.",
            icon: "heart.text.square",
            color: Color.currentAccent
        )
    ]
}

#Preview {
    OnboardingView()
}
