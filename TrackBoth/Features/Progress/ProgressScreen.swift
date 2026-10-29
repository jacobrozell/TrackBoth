import SwiftData
import SwiftUI

struct ProgressScreen: View {
    @Query(sort: \Metric.sortOrder) private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @Query private var urges: [UrgeEvent]

    @Environment(\.modelContext) private var modelContext
    @State private var model = ProgressViewModel()
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let saved = model.summary.savedText {
                        StatTile(value: saved, label: RecoveryCopy.totalSaved, systemImage: "dollarsign.circle")
                    }
                    StatTile(value: "\(model.summary.urgesBeaten)", label: RecoveryCopy.urgesBeaten, systemImage: "wind")
                    StatTile(value: "\(model.summary.daysCheckedIn)", label: RecoveryCopy.daysCheckedIn, systemImage: "checkmark.circle")
                    Text(RecoveryCopy.urgesBeatenCount(model.summary.urgesBeaten))
                        .font(.headline)
                        .foregroundStyle(Color.tbTextPrimary)
                }
                Section {
                    ForEach(model.active) { card in
                        NavigationLink(value: card.id) {
                            cardRow(card)
                        }
                        .accessibilityIdentifier(AccessibilityIdentifiers.progressMetricCard(card.id))
                    }
                    .onMove { offsets, destination in
                        try? model.moveActive(from: offsets, to: destination, metrics: metrics, store: RecoveryStore(context: modelContext))
                    }
                }
                if !model.archived.isEmpty {
                    Section(RecoveryCopy.archived) {
                        ForEach(model.archived) { card in
                            NavigationLink(value: card.id) { cardRow(card) }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.tbBackground)
            .navigationTitle("Progress")
            .navigationDestination(for: UUID.self) { id in
                if let metric = metrics.first(where: { $0.id == id }) {
                    MetricDetailScreen(metric: metric)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(RecoveryCopy.addSomething)
                }
            }
            .sheet(isPresented: $showAdd) {
                MetricFormView(metric: nil)
            }
        }
        .onAppear { refresh() }
        .onChange(of: snapshot) { refresh() }
    }

    private func cardRow(_ card: ProgressCardModel) -> some View {
        HStack(spacing: Spacing.m) {
            IconBadge(systemImage: card.iconName, tint: .tbBrand)
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(card.name).font(.headline).foregroundStyle(Color.tbTextPrimary)
                Text(card.line).font(.subheadline).foregroundStyle(Color.tbTextSecondary)
            }
        }
        .frame(minHeight: 44)
    }

    private var snapshot: String {
        metrics.map { "\($0.id.uuidString):\($0.sortOrder):\($0.isArchived):\($0.name)" }.joined()
            + entries.map(\.statusRaw).joined()
            + urges.map(\.outcomeRaw).joined()
    }

    private func refresh() {
        model.update(metrics: metrics, entries: entries, urges: urges, now: Date())
    }
}
