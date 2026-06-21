import SwiftUI

// MARK: - Device layout
/// Explicit layout variants for purpose-built iPhone and iPad UI.
enum DeviceLayout: Equatable {
    case phonePortrait
    case phoneLandscape
    case padPortrait
    case padLandscape

    var isPad: Bool {
        switch self {
        case .padPortrait, .padLandscape: return true
        case .phonePortrait, .phoneLandscape: return false
        }
    }

    var isLandscape: Bool {
        switch self {
        case .phoneLandscape, .padLandscape: return true
        case .phonePortrait, .padPortrait: return false
        }
    }

    static func resolve(
        horizontal: UserInterfaceSizeClass?,
        vertical: UserInterfaceSizeClass?,
        size: CGSize
    ) -> DeviceLayout {
        let isPad = horizontal == .regular && vertical == .regular
        let isLandscape = size.width > size.height
            || vertical == .compact
            || (isPad && InterfaceLayout.isLandscape)

        if isPad {
            return isLandscape ? .padLandscape : .padPortrait
        }
        return isLandscape ? .phoneLandscape : .phonePortrait
    }
}

private struct DeviceLayoutKey: EnvironmentKey {
    static let defaultValue: DeviceLayout = .phonePortrait
}

extension EnvironmentValues {
    var deviceLayout: DeviceLayout {
        get { self[DeviceLayoutKey.self] }
        set { self[DeviceLayoutKey.self] = newValue }
    }
}

extension View {
    func publishDeviceLayout(
        horizontal: UserInterfaceSizeClass?,
        vertical: UserInterfaceSizeClass?,
        size: CGSize
    ) -> some View {
        let layout = DeviceLayout.resolve(horizontal: horizontal, vertical: vertical, size: size)
        return environment(\.deviceLayout, layout)
            .publishAdaptiveLayoutMode(horizontal: horizontal, vertical: vertical, size: size)
    }
}

extension DeviceLayout {
    var tabBarScrollBottomInset: CGFloat {
        switch self {
        case .phonePortrait:
            return TabBarLayout.portraitScrollBottomInset
        case .phoneLandscape:
            return TabBarLayout.landscapeScrollBottomInset
        case .padPortrait:
            return TabBarLayout.portraitScrollBottomInset
        case .padLandscape:
            return TabBarLayout.sidebarScrollBottomInset
        }
    }

    func scrollBottomInset(dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        let base = tabBarScrollBottomInset
        guard dynamicTypeSize.usesExpandedChrome else { return base }
        return base + (isLandscape ? 24 : 32)
    }
}
