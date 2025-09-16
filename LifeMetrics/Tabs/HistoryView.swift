import SwiftUI
import SwiftData

// MARK: - HistoryView
/// View displaying historical habit tracking data with calendar and filtering
struct HistoryView: View {
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var viewModel = HistoryViewModel()
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    if metrics.isEmpty {
                        EmptyStateView(
                            icon: "calendar.badge.exclamationmark",
                            title: "No data yet",
                            subtitle: "Start tracking habits and vices to see your history"
                        )
                    } else {
                        if geometry.size.width > geometry.size.height {
                            landscapeLayout(geometry: geometry)
                        } else {
                            portraitLayout
                        }
                    }
                }
                .navigationTitle("History")
                .onAppear {
                    logger.info("HistoryView appeared", category: .ui)
                    logger.debug("History data - Metrics: \(metrics.count), Entries: \(entries.count), Filter: \(viewModel.selectedFilter)", category: .ui)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.showSettings()
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showingSettings) {
                    SettingsView()
                }
            }
        }
    }
    
    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            // Left side - Filters and Search
            VStack(spacing: 16) {
                searchBar
                landscapeFilterSection
                landscapeEntryTypeFilter
                Spacer()
            }
            .frame(width: min(280, geometry.size.width * 0.35))
            .padding(.horizontal, 16)
            .background(Color.currentSecondaryBackground.opacity(0.3))

            Divider()
                .frame(height: geometry.size.height)

            // Right side - Calendar
            ScrollView {
                CalendarGridView(
                    entries: viewModel.calendarEntries(entries, metrics: metrics),
                    selectedFilter: viewModel.selectedFilter,
                    selectedDate: $viewModel.selectedDate,
                    metrics: metrics
                )
                .padding()
            }
        }
    }
    
    private var portraitLayout: some View {
        ScrollView {
            VStack(spacing: 0) {
                searchBar
                    .padding(.horizontal)
                    .padding(.top)
                
                horizontalFilterSection
                horizontalEntryTypeFilter
                
                Divider()

                // Calendar view
                CalendarGridView(
                    entries: viewModel.calendarEntries(entries, metrics: metrics),
                    selectedFilter: viewModel.selectedFilter,
                    selectedDate: $viewModel.selectedDate,
                    metrics: metrics
                )

                Divider()

                // Entries list view
                EntriesListView(
                    selectedFilter: viewModel.selectedFilter,
                    entryTypeFilter: viewModel.entryTypeFilter,
                    entries: entries,
                    metrics: metrics
                )
            }
        }
    }
    
    // MARK: - View Components
    
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.currentSecondaryText)

            TextField("Search details...", text: $viewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.currentSecondaryText)
                }
            }
        }
        .padding()
        .background(Color.currentSecondaryBackground)
        .cornerRadius(10)
    }
    
    private var landscapeFilterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter by Metric")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.currentSecondaryText)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    FilterButton(filter: .all, isSelected: viewModel.selectedFilter == .all) {
                        viewModel.updateFilter(.all)
                    }
                    FilterButton(filter: .allHabits, isSelected: viewModel.selectedFilter == .allHabits) {
                        viewModel.updateFilter(.allHabits)
                    }
                    FilterButton(filter: .allVices, isSelected: viewModel.selectedFilter == .allVices) {
                        viewModel.updateFilter(.allVices)
                    }
                    ForEach(metrics) { metric in
                        FilterButton(filter: .specific(metric), isSelected: viewModel.selectedFilter == .specific(metric)) {
                            viewModel.updateFilter(.specific(metric))
                        }
                    }
                }
            }
        }
    }
    
    private var horizontalFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterButton(filter: .all, isSelected: viewModel.selectedFilter == .all) {
                    viewModel.updateFilter(.all)
                }
                FilterButton(filter: .allHabits, isSelected: viewModel.selectedFilter == .allHabits) {
                    viewModel.updateFilter(.allHabits)
                }
                FilterButton(filter: .allVices, isSelected: viewModel.selectedFilter == .allVices) {
                    viewModel.updateFilter(.allVices)
                }
                ForEach(metrics) { metric in
                    FilterButton(filter: .specific(metric), isSelected: viewModel.selectedFilter == .specific(metric)) {
                        viewModel.updateFilter(.specific(metric))
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private var landscapeEntryTypeFilter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Entry Type")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.currentSecondaryText)

            VStack(spacing: 8) {
                ForEach(EntryTypeFilter.allCases, id: \.self) { filter in
                    Button {
                        viewModel.updateEntryTypeFilter(filter)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: filter.icon)
                                .font(.caption)
                            Text(filter.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(viewModel.entryTypeFilter == filter ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(viewModel.entryTypeFilter == filter ? Color.currentPrimary : Color.currentSecondaryBackground)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var horizontalEntryTypeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(EntryTypeFilter.allCases, id: \.self) { filter in
                    Button {
                        viewModel.updateEntryTypeFilter(filter)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: filter.icon)
                                .font(.caption)
                            Text(filter.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(viewModel.entryTypeFilter == filter ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(viewModel.entryTypeFilter == filter ? Color.currentPrimary : Color.currentSecondaryBackground)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
