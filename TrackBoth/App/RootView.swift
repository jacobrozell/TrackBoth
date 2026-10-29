import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(filter: #Predicate<Metric> { !$0.isArchived }, sort: \Metric.sortOrder) private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @Query private var reasons: [Reason]
    @State private var onboarded = Preferences.hasCompletedOnboarding
    @State private var celebration: CelebrationRequest?

    var body: some View {
        @Bindable var router = router
        Group {
            if onboarded {
                MainTabView()
            } else {
                OnboardingPlaceholder {
                    Preferences.hasCompletedOnboarding = true
                    onboarded = true
                }
            }
        }
        .background(Color.tbBackground)
        .task {
            guard LaunchConfiguration.shouldSeedDemo else { return }
            try? DemoData.seedIfEmpty(context: modelContext)
            refreshCelebration()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            try? RecoveryStore(context: modelContext).resolveAbandonedUrges()
            if onboarded, let pending = router.pendingQuickAction {
                router.pendingQuickAction = nil
                router.present(pending)
            }
            refreshCelebration()
        }
        .onOpenURL { url in
            guard url.scheme == "trackboth" else { return }
            switch url.host {
            case "urge": router.present(.urge(nil))
            case "checkin": router.present(.checkIn)
            default: break
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .recoveryDataChanged)) { _ in
            refreshCelebration()
        }
        .fullScreenCover(item: urgeBinding) { flow in
            if case .urge(let id) = flow {
                UrgeFlowView(metrics: metrics, preferredID: id) { router.presented = nil }
            }
        }
        .sheet(item: rootSheet) { sheet in
            switch sheet.kind {
            case .checkIn:
                CheckInSheet(metrics: metrics, entries: entries)
            case .celebration(let request):
                CelebrationView(request: request) {
                    celebration = nil
                    refreshCelebration()
                }
            }
        }
        .safeAreaInset(edge: .top) {
            if BootstrapStoreRecovery.mode == .inMemoryFallback {
                StoreRecoveryBanner()
            }
        }
    }

    private var urgeBinding: Binding<PresentedFlow?> {
        Binding(
            get: {
                if case .urge = router.presented { return router.presented }
                return nil
            },
            set: { newValue in
                if newValue == nil, case .urge = router.presented { router.presented = nil }
            }
        )
    }

    private var rootSheet: Binding<RootSheet?> {
        Binding(
            get: {
                if case .checkIn = router.presented { return RootSheet(kind: .checkIn) }
                if case .urge = router.presented { return nil }
                if let celebration { return RootSheet(kind: .celebration(celebration)) }
                return nil
            },
            set: { newValue in
                guard newValue == nil else { return }
                if case .checkIn = router.presented { router.presented = nil }
                celebration = nil
            }
        )
    }

    private func refreshCelebration() {
        guard router.presented == nil else { return }
        celebration = MilestoneCenter.pending(
            metrics: metrics,
            entries: entries,
            reasons: reasons,
            now: Date(),
            calendar: .current
        ).first
    }
}

private struct RootSheet: Identifiable {
    enum Kind {
        case checkIn
        case celebration(CelebrationRequest)
    }

    var kind: Kind
    var id: String {
        switch kind {
        case .checkIn: "check-in"
        case .celebration(let request): "celebration-\(request.metricID.uuidString)"
        }
    }
}

private struct MainTabView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            TodayScreen()
                .tabItem { Label("Today", systemImage: "sun.max").accessibilityIdentifier(AccessibilityIdentifiers.tabToday) }
                .tag(AppTab.today)
            ProgressScreen()
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis").accessibilityIdentifier(AccessibilityIdentifiers.tabProgress) }
                .tag(AppTab.progress)
            SettingsScreen()
                .tabItem { Label("Settings", systemImage: "gearshape").accessibilityIdentifier(AccessibilityIdentifiers.tabSettings) }
                .tag(AppTab.settings)
        }
        .tint(Color.tbBrand)
    }
}

private struct OnboardingPlaceholder: View {
    var skip: () -> Void

    var body: some View {
        VStack(spacing: Spacing.l) {
            BrandMark(size: 72)
            Text("Onboarding coming soon")
                .font(.title2)
                .foregroundStyle(Color.tbTextPrimary)
            if ProductSurface.showsDebugTools {
                Button("Skip", action: skip)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.tbBrand)
                    .frame(minHeight: 44)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.tbBackground)
    }
}
