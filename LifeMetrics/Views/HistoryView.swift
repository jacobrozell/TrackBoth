import SwiftUI
import SwiftData

// MARK: - HistoryView
/// View displaying historical habit tracking data with calendar and filtering
struct HistoryView: View {
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var selectedFilter: MetricFilter = .all
    @State private var selectedDate = Date()
    @State private var searchText = ""
    @State private var showingAddMetric = false
    @State private var showingSettings = false
    @State private var entryTypeFilter: EntryTypeFilter = .all
    
    private var calendarEntries: [Date: [MetricEntry]] {
        let startTime = Date()
        let filteredEntries = entries.filter { entry in
            // Only show entries that have meaningful content
            guard entry.hasContent else { return false }
            
            // Apply search filter
            if !searchText.isEmpty {
                guard entry.details?.localizedCaseInsensitiveContains(searchText) == true else {
                    return false
                }
            }
            
            // Apply entry type filter
            switch entryTypeFilter {
            case .all:
                break
            case .boolean:
                guard !entry.hasQuantity else { return false }
            case .quantity:
                guard entry.hasQuantity else { return false }
            }
            
            // Apply metric filter
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
        
        let result = Dictionary(grouping: filteredEntries) { entry in
            CalendarHelper.startOfDay(for: entry.date)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Calendar entries calculation", duration: duration)
        logger.debug("Calendar entries calculated - Filtered: \(filteredEntries.count), Grouped: \(result.count) days", category: .performance)
        
        return result
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if metrics.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No data yet")
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            Text("Start tracking habits and vices to see your history")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                // Search bar
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.secondary)
                                    
                                    TextField("Search details...", text: $searchText)
                                        .textFieldStyle(PlainTextFieldStyle())
                                    
                                    if !searchText.isEmpty {
                                        Button {
                                            searchText = ""
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.top)
                                
                                // Filter picker
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        // All filter
                                        FilterButton(
                                            filter: .all,
                                            isSelected: selectedFilter == .all
                                        ) {
                                            selectedFilter = .all
                                        }
                                        
                                        // All Habits filter
                                        FilterButton(
                                            filter: .allHabits,
                                            isSelected: selectedFilter == .allHabits
                                        ) {
                                            selectedFilter = .allHabits
                                        }
                                        
                                        // All Vices filter
                                        FilterButton(
                                            filter: .allVices,
                                            isSelected: selectedFilter == .allVices
                                        ) {
                                            selectedFilter = .allVices
                                        }
                                        
                                        // Individual metrics
                                        ForEach(metrics) { metric in
                                            FilterButton(
                                                filter: .specific(metric),
                                                isSelected: selectedFilter == .specific(metric)
                                            ) {
                                                selectedFilter = .specific(metric)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.vertical)
                                
                                // Entry type filter
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(EntryTypeFilter.allCases, id: \.self) { filter in
                                            Button {
                                                entryTypeFilter = filter
                                            } label: {
                                                HStack(spacing: 6) {
                                                    Image(systemName: filter.icon)
                                                        .font(.caption)
                                                    Text(filter.displayName)
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                }
                                                .foregroundColor(entryTypeFilter == filter ? .white : .primary)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(entryTypeFilter == filter ? Color.blue : Color(.systemGray5))
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                
                                Divider()
                                
                                // Calendar view
                                CalendarGridView(
                                    entries: calendarEntries,
                                    selectedFilter: selectedFilter,
                                    selectedDate: $selectedDate,
                                    metrics: metrics
                                )
                                
                                Divider()
                                
                                // Entries list view
                                EntriesListView(
                                    selectedFilter: selectedFilter,
                                    entryTypeFilter: entryTypeFilter,
                                    entries: entries,
                                    metrics: metrics
                                )
                            }
                        }
                    }
                }
                .navigationTitle("History")
                .onAppear {
                    logger.info("HistoryView appeared", category: .ui)
                    logger.debug("History data - Metrics: \(metrics.count), Entries: \(entries.count), Filter: \(selectedFilter)", category: .ui)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
            }
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}