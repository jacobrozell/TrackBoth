import SwiftUI
import SwiftData

// MARK: - OnboardingView
/// Emotional first-run flow: pick habits/vices to track, then land on a populated Home screen.
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var currentPage = 0
    @State private var selectedHabitPresets: Set<MetricPreset> = []
    @State private var selectedVicePresets: Set<MetricPreset> = []

    private let pages = OnboardingPage.allPages

    private var usesCompactLayout: Bool {
        dynamicTypeSize.usesExpandedChrome || verticalSizeClass == .compact
    }

    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            ZStack {
                LinearGradient(
                    colors: [Color.currentPrimary.opacity(0.1), Color.currentAccent.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if isIPad {
                    iPadLayout(isLandscape: isLandscape, size: geometry.size)
                } else {
                    phoneLayout
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var phoneLayout: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    pageContent(for: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            bottomControls
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private func iPadLayout(isLandscape: Bool, size: CGSize) -> some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    pageContent(for: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: isLandscape ? 700 : 600)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            bottomControls
                .frame(maxWidth: isLandscape ? 400 : 500)
                .padding(.bottom, isLandscape ? 24 : 32)
        }
    }

    @ViewBuilder
    private func pageContent(for page: OnboardingPage) -> some View {
        switch page.kind {
        case .welcome, .ready:
            OnboardingPageView(page: page, usesCompactLayout: usesCompactLayout)
        case .habitPresets:
            OnboardingPresetPageView(
                title: page.title,
                description: page.description,
                icon: page.icon,
                color: page.color,
                presets: MetricPreset.habitPresets,
                selection: $selectedHabitPresets,
                usesCompactLayout: usesCompactLayout
            )
        case .vicePresets:
            OnboardingPresetPageView(
                title: page.title,
                description: page.description,
                icon: page.icon,
                color: page.color,
                presets: MetricPreset.vicePresets,
                selection: $selectedVicePresets,
                usesCompactLayout: usesCompactLayout
            )
        }
    }

    private var hasSelection: Bool {
        !selectedHabitPresets.isEmpty || !selectedVicePresets.isEmpty
    }

    private var bottomControls: some View {
        VStack(spacing: usesCompactLayout ? 12 : 24) {
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
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Page \(currentPage + 1) of \(pages.count)")

            VStack(spacing: 12) {
                if currentPage > 0 {
                    HStack {
                        Button("Previous") {
                            withAnimation { currentPage -= 1 }
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Spacer()

                        if currentPage < pages.count - 1 && currentPage > 0 {
                            Button("Skip") {
                                logger.logUserAction("Skip onboarding")
                                completeOnboarding()
                            }
                            .foregroundColor(Color.currentSecondaryText)
                        }
                    }
                }

                if currentPage < pages.count - 1 {
                    Button("Next") {
                        withAnimation { currentPage += 1 }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: .infinity)
                } else {
                    VStack(spacing: 8) {
                        if !hasSelection {
                            Text("Pick at least one habit or vice, or we'll help you add one next.")
                                .font(.footnote)
                                .foregroundStyle(Color.currentSecondaryText)
                                .multilineTextAlignment(.center)
                        }

                        Button("Get Started") {
                            logger.logUserAction("Complete onboarding")
                            completeOnboarding()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier(AccessibilityIdentifiers.onboardingGetStarted)
                    }
                }
            }
            .padding(.horizontal, 32)
        }
        .padding(.bottom, usesCompactLayout ? 12 : 24)
    }

    private func completeOnboarding() {
        let presets = Array(selectedHabitPresets) + Array(selectedVicePresets)
        if !presets.isEmpty {
            MetricPresetFactory.createMetrics(from: presets, in: modelContext)
        }

        logger.info("Onboarding completed with \(presets.count) preset metrics")
        UserDefaults.standard.set(true, forKey: ThemePreferences.hasCompletedOnboarding)
        AppEvent.post(.onboardingCompleted)

        if presets.isEmpty {
            AppEvent.post(.openAddMetric)
        }
    }
}

// MARK: - OnboardingPresetPageView
private struct OnboardingPresetPageView: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let presets: [MetricPreset]
    @Binding var selection: Set<MetricPreset>
    let usesCompactLayout: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: usesCompactLayout ? 16 : 24) {
                Spacer(minLength: usesCompactLayout ? 8 : 16)

                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: usesCompactLayout ? 72 : 96, height: usesCompactLayout ? 72 : 96)
                    Image(systemName: icon)
                        .font(.system(size: usesCompactLayout ? 30 : 40, weight: .medium))
                        .foregroundColor(color)
                }

                VStack(spacing: 12) {
                    Text(title)
                        .h2()
                        .foregroundColor(Color.currentText)
                        .multilineTextAlignment(.center)
                    Text(description)
                        .bodyLarge()
                        .foregroundColor(Color.currentSecondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                PresetChipGrid(presets: presets, selection: $selection)
                    .padding(.top, 8)

                Text("Optional — you can add more later.")
                    .font(.caption)
                    .foregroundColor(Color.currentSecondaryText)

                Spacer(minLength: 8)
            }
            .padding(.horizontal, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

// MARK: - PresetChipGrid
struct PresetChipGrid: View {
    let presets: [MetricPreset]
    @Binding var selection: Set<MetricPreset>

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(presets) { preset in
                let isSelected = selection.contains(preset)
                Button {
                    if isSelected {
                        selection.remove(preset)
                    } else {
                        selection.insert(preset)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: preset.icon)
                            .font(.subheadline)
                        Text(preset.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                        Spacer(minLength: 0)
                    }
                    .foregroundColor(isSelected ? Color.currentBackground : Color.currentText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.currentPrimary : Color.currentSecondaryBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.currentPrimary : Color.currentSecondaryText.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
                .accessibilityHint("Double tap to select or deselect")
            }
        }
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

                ZStack {
                    Circle()
                        .fill(page.color.opacity(0.2))
                        .frame(width: usesCompactLayout ? 88 : 120, height: usesCompactLayout ? 88 : 120)

                    Image(systemName: page.icon)
                        .font(.system(size: usesCompactLayout ? 36 : 50, weight: .medium))
                        .foregroundColor(page.color)
                }

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
    enum Kind {
        case welcome
        case habitPresets
        case vicePresets
        case ready
    }

    let kind: Kind
    let title: String
    let description: String
    let icon: String
    let color: Color

    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            kind: .welcome,
            title: "Welcome to TrackBoth",
            description: "Build good habits and break bad ones — in one simple daily log. We track streaks for habits and clean days for vices.",
            icon: "arrow.triangle.2.circlepath",
            color: Color.currentPrimary
        ),
        OnboardingPage(
            kind: .habitPresets,
            title: "What do you want to build?",
            description: "Pick habits you want to do more often. Tap any that fit — you can customize names later.",
            icon: "checkmark.circle.fill",
            color: Color.currentSuccess
        ),
        OnboardingPage(
            kind: .vicePresets,
            title: "What do you want to break?",
            description: "Pick vices you want to avoid. We'll count clean days and help you stay accountable.",
            icon: "xmark.shield.fill",
            color: Color.currentError
        ),
        OnboardingPage(
            kind: .ready,
            title: "One tap a day",
            description: "Log each habit or vice with a single tap on Track. Review your progress anytime in History.",
            icon: "hand.tap.fill",
            color: Color.currentAccent
        )
    ]
}

#Preview {
    OnboardingView()
        .modelContainer(for: [Metric.self, MetricEntry.self, Goal.self], inMemory: true)
}
