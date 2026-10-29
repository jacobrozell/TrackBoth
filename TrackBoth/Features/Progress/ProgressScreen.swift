import SwiftData
import SwiftUI

struct ProgressScreen: View {
    @Query(sort: \Metric.sortOrder) private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @Query private var urges: [UrgeEvent]

    @Environment(\.modelContext) private var modelContext
    @State private var model = ProgressViewModel()
    @State private var showAdd = false
    @State private var path = NavigationPath()
    @State private var didOpenDetail = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        if let saved = model.summary.savedText {
                            summaryLine(saved, systemImage: "dollarsign.circle")
                        }
                        summaryLine(RecoveryCopy.urgesBeatenCount(model.summary.urgesBeaten), systemImage: "wind")
                        summaryLine("\(model.summary.daysCheckedIn) \(RecoveryCopy.daysCheckedIn.lowercased())", systemImage: "checkmark.circle")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, Spacing.s)
                    .listRowBackground(Color.tbSurface)
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
        .onAppear {
            refresh()
            openFirstDetailIfNeeded()
        }
        .onChange(of: snapshot) {
            refresh()
            openFirstDetailIfNeeded()
        }
    }

    private func summaryLine(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.body.weight(.semibold))
            .foregroundStyle(Color.tbTextPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, Spacing.xs)
            .accessibilityLabel(text)
    }

    private func cardRow(_ card: ProgressCardModel) -> some View {
        HStack(spacing: Spacing.m) {
            IconBadge(systemImage: card.iconName, tint: card.habitType == .vice ? .tbBrand : .tbHabit)
            VStack(alignment: .leading, spacing: Spacing.s) {
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

    private func openFirstDetailIfNeeded() {
        guard LaunchConfiguration.opensFirstDetail, !didOpenDetail, let id = model.active.first?.id else { return }
        didOpenDetail = true
        path.append(id)
    }
}
