import Foundation

enum AppLinks {
    static let support = URL(string: "https://jacobrozell.github.io/TrackBoth/support.html")!
    static let privacy = URL(string: "https://jacobrozell.github.io/TrackBoth/privacy.html")!
    static let accessibility = URL(string: "https://jacobrozell.github.io/TrackBoth/accessibility.html")!

    static let appStoreAppID: String = "6752591094"

    static var appStoreReview: URL {
        URL(string: "https://apps.apple.com/app/id\(appStoreAppID)?action=write-review")!
    }
}
