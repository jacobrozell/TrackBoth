import SwiftUI

struct CrisisResourcesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                ReadableColumn {
                    VStack(alignment: .leading, spacing: Spacing.l) {
                        Text("If you're in immediate danger, call 911 or your local emergency number.")
                            .font(.body)
                            .foregroundStyle(Color.tbTextPrimary)
                        Link("Call 911", destination: URL(string: "tel:911")!)
                        Text("988 Suicide & Crisis Lifeline (US). Call or text 988.")
                            .font(.body)
                            .foregroundStyle(Color.tbTextPrimary)
                        Link("Call 988", destination: URL(string: "tel:988")!)
                        Link("Text 988", destination: URL(string: "sms:988")!)
                        Text("SAMHSA National Helpline (US): 1-800-662-4357. Free, confidential, 24/7, English and Spanish.")
                            .font(.body)
                            .foregroundStyle(Color.tbTextPrimary)
                        Link("Call 1-800-662-4357", destination: URL(string: "tel:18006624357")!)
                        Text("Outside the US")
                            .font(.headline)
                            .foregroundStyle(Color.tbTextPrimary)
                        Link("findahelpline.com", destination: AppLinks.crisisFindAHelpline)
                    }
                    .padding(.vertical, Spacing.l)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .background(Color.tbBackground)
            .navigationTitle(RecoveryCopy.getHelpNow)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(RecoveryCopy.close) { dismiss() }
                }
            }
        }
    }
}
