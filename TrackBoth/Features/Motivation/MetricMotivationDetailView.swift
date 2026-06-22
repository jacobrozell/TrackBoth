import SwiftUI
import SwiftData

// MARK: - Metric Motivation Detail
/// Primary motivation plus all timestamped motivation notes for one habit or vice.
struct MetricMotivationDetailView: View {
    let metric: Metric

    @Query private var motivationEntries: [MetricEntry]
    @State private var showingEditWhy = false
    @State private var showingAddNote = false

    private var accentColor: Color {
        metric.habitType == .vice ? Color.currentWarning : Color.currentSuccess
    }

    private var trimmedPrimary: String? {
        guard let text = metric.primaryMotivation?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return nil }
        return text
    }

    private var loggedMotivations: [MetricEntry] {
        motivationEntries.filter { entry in
            !(entry.motivation?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        }
    }

    init(metric: Metric) {
        self.metric = metric
        let metricID = metric.id
        _motivationEntries = Query(
            filter: #Predicate<MetricEntry> { entry in
                entry.metricID == metricID && entry.motivation != nil
            },
            sort: \.date,
            order: .reverse
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                primarySection
                loggedSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .adaptiveScrollInset()
        }
        .themedBackground()
        .navigationTitle(metric.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddNote = true
                } label: {
                    Label("Log motivation", systemImage: "square.and.pencil")
                }
                .accessibilityIdentifier("motivation_log_note")
            }
        }
        .sheet(isPresented: $showingEditWhy) {
            EditWhySheet(metric: metric)
        }
        .sheet(isPresented: $showingAddNote) {
            AddMotivationView(metrics: [metric], preselectedMetric: metric)
        }
    }

    private var primarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Primary motivation", systemImage: "pin.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accentColor)

                Spacer(minLength: 0)

                Button("Edit") {
                    showingEditWhy = true
                }
                .font(.subheadline.weight(.medium))
                .accessibilityIdentifier("motivation_edit_primary")
            }

            Text(primaryFooterCopy)
                .font(.caption)
                .foregroundStyle(Color.currentSecondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Group {
                if let primary = trimmedPrimary {
                    Text(primary)
                        .font(.body)
                        .foregroundStyle(Color.currentText)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(emptyPrimaryCopy)
                        .font(.subheadline)
                        .foregroundStyle(Color.currentSecondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .accessibilityElement(children: .contain)
    }

    private var loggedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Logged motivations", systemImage: "text.quote")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.currentText)

            Text(loggedFooterCopy)
                .font(.caption)
                .foregroundStyle(Color.currentSecondaryText)
                .fixedSize(horizontal: false, vertical: true)

            if loggedMotivations.isEmpty {
                Text(emptyLoggedCopy)
                    .font(.subheadline)
                    .foregroundStyle(Color.currentSecondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(loggedMotivations.enumerated()), id: \.element.id) { index, entry in
                        MotivationNoteRow(entry: entry, habitType: metric.habitType)

                        if index < loggedMotivations.count - 1 {
                            Divider()
                                .padding(.leading, 4)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 4)
                .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var primaryFooterCopy: String {
        metric.habitType == .vice
            ? "Your main reason to stay clean — shown here and when you log on Track."
            : "Your main reason for this habit — always visible on this screen."
    }

    private var emptyPrimaryCopy: String {
        metric.habitType == .vice
            ? "Add the core reason you want to quit. This stays pinned while you collect day-to-day motivations below."
            : "Add why this habit matters. You can also log reflections as you go."
    }

    private var loggedFooterCopy: String {
        "Thoughts you capture over time — each saved with the date and time you logged it."
    }

    private var emptyLoggedCopy: String {
        metric.habitType == .vice
            ? "No logged motivations yet. Tap Log motivation when a craving hits or you want to remember what helped."
            : "No logged motivations yet. Tap Log motivation to jot down what made today easier or harder."
    }
}
