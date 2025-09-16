import SwiftUI
import SwiftData

struct EntriesListView: View {
    let selectedFilter: MetricFilter
    let entryTypeFilter: EntryTypeFilter
    let entries: [MetricEntry]
    let metrics: [Metric]
    
    private var filteredEntries: [MetricEntry] {
        let filtered = entries.filter { entry in
            // Only show entries that have meaningful content
            guard entry.hasContent else { return false }
            
            // Apply entry type filter
            switch entryTypeFilter {
            case .all:
                break
            case .boolean:
                guard !entry.hasQuantity else { return false }
            case .quantity:
                guard entry.hasQuantity else { return false }
            }
            
            switch selectedFilter {
            case .all:
                return true
            case .allHabits:
                return metrics.first { $0.id == entry.metricID }?.safeHabitType == .positive
            case .allVices:
                return metrics.first { $0.id == entry.metricID }?.safeHabitType == .vice
            case .specific(let metric):
                return entry.metricID == metric.id
            }
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Entries")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.currentText)
                
                Spacer()
                
                Text("\(filteredEntries.count) entries")
                    .font(.caption)
                    .foregroundColor(.currentSecondaryText)
            }
            .padding(.horizontal)
            .padding(.top)
            
            if filteredEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 40))
                        .foregroundColor(.currentSecondaryText)
                    
                    Text("No entries found")
                        .font(.subheadline)
                        .foregroundColor(.currentSecondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(filteredEntries) { entry in
                        EditableEntryCell(
                            entry: entry,
                            metrics: metrics
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
