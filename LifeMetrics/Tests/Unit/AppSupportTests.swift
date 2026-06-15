import XCTest
@testable import TrackBoth

final class AppSupportTests: XCTestCase {
    func testFeedbackEmailUsesPersonalAddress() {
        XCTAssertEqual(AppSupport.feedbackEmail, "jacob.rozell83@gmail.com")
    }

    func testFeedbackMailtoURLUsesMailtoScheme() {
        let url = AppSupport.feedbackMailtoURL
        XCTAssertEqual(url.scheme, "mailto")
        XCTAssertTrue(url.absoluteString.contains(AppSupport.feedbackEmail))
    }

    func testVersionLabelIncludesAppName() {
        XCTAssertTrue(AppSupport.versionLabel.contains("TrackBoth"))
        XCTAssertTrue(AppSupport.versionLabel.contains(AppSupport.installedVersion))
    }
}
