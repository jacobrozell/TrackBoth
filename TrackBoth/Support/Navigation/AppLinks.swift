import Foundation

enum AppLinks {
    static let support = URL(string: "https://jacobrozell.github.io/TrackBoth/support.html")!
    static let privacy = URL(string: "https://jacobrozell.github.io/TrackBoth/privacy.html")!
    static let accessibility = URL(string: "https://jacobrozell.github.io/TrackBoth/accessibility.html")!

    /// Set when the App Store listing is live.
    static let appStoreAppID: String? = nil

    static var appStoreReview: URL? {
        guard let appStoreAppID else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(appStoreAppID)?action=write-review")
    }

    static let buyDeveloperCoffee: URL? = URL(string: "https://buymeacoffee.com/jacobrozelq")
}
