import Foundation

enum AppSupport {
    static let feedbackEmail = "jacob.rozell83@gmail.com"

    static var installedVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    static var versionLabel: String {
        "TrackBoth · Version \(installedVersion)"
    }

    static var feedbackMailtoURL: URL {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = feedbackEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: "TrackBoth Feedback"),
            URLQueryItem(
                name: "body",
                value: "\n\n---\nTrackBoth \(installedVersion)"
            )
        ]
        return components.url ?? URL(string: "mailto:\(feedbackEmail)")!
    }
}
