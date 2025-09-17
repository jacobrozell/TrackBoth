import SwiftUI
import SwiftData

// MARK: - HomeView2
/// Redesigned Home view per homePageRedesign TODO/spec
struct HomeView2: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]

    // Reuse existing VM for business logic and state
    @State private var viewModel = HomeViewModel()

    // UI State
    @State private var showingLoggingSheetForMetric: Metric? = nil
    @State private var showingRowOptions: Bool = false

    // MARK: - Derived values
    private var weekDays: [Date] {
        // Show last 7 days ending today (no future dates)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -6 + offset, to: today)
        }
    }

    private var habits: [Metric] { metrics.filter { $0.safeHabitType == .positive } }
    private var vices: [Metric] { metrics.filter { $0.safeHabitType == .vice } }

    private func completedCount(for metrics: [Metric]) -> Int {
        viewModel.todayCompleted(from: metrics, entries: entries)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if metrics.isEmpty {
                    EmptyStateView(
                        icon: "plus.circle.fill",
                        title: "No Habits Yet",
                        subtitle: "Start tracking your habits and vices to build a better you",
                        actionTitle: "Add Your First Habit",
                        action: { viewModel.showAddMetric() }
                    )
                    .background(Color.currentBackground)
                } else if geometry.size.width > geometry.size.height {
                    // Landscape: Left (stats + week), Right (list)
                    HStack(spacing: 0) {
                        leftPanel
                            .background(Color.currentSecondaryBackground)

                        Divider()

                        rightPanel
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay(alignment: .bottomTrailing) {
                                FloatingActionButton { viewModel.showAddMetric() }
                            }
                    }
                } else {
                    // Portrait: Header (stats + week), then list + FAB
                    VStack(spacing: 0) {
                        VStack(spacing: 12) {
                            quickStatsRow
                            weekMiniCalendar
                            HStack {
                                Button(showingRowOptions ? "Done" : "Edit") {
                                    showingRowOptions.toggle()
                                }
                                .font(.caption)
                                .foregroundColor(Color.currentPrimary)
                                
                                Spacer()

                                if !viewModel.isToday {
                                    Button("Today") { viewModel.goToToday() }
                                        .font(.caption)
                                        .foregroundColor(Color.currentPrimary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.currentSecondaryBackground)

                        sectionsList
                            .overlay(alignment: .bottomTrailing) {
                                FloatingActionButton { viewModel.showAddMetric() }
                            }
                    }
                }
            }
            .navigationTitle("TrackBoth")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showSettings()
                    } label: { Image(systemName: "gear") }
                }
            }
            .onAppear {
                // Clamp selectedDate to today if in the future
                let today = Calendar.current.startOfDay(for: Date())
                if viewModel.selectedDate > today {
                    viewModel.selectedDate = today
                }
            }
            .sheet(item: $viewModel.metricToEdit) { metric in
                EditMetricView(metric: metric)
            }
            .sheet(isPresented: $viewModel.showingAddMetric) {
                AddMetricView()
            }
            .sheet(item: $showingLoggingSheetForMetric) { metric in
                LoggingSheet(metric: metric, selectedDate: viewModel.selectedDate)
            }
        }
    }

    // MARK: - Panels
    private var leftPanel: some View {
        VStack(spacing: 12) {
            quickStatsRow
                .padding(.horizontal)
                .padding(.top, 8)

            Spacer(minLength: 0)

            weekMiniCalendar
        }
        .padding()
    }

    private var rightPanel: some View {
        VStack(spacing: 0) {
            // Simple header mirroring week context
            HStack {
                Text(weekHeaderTitle)
                    .font(.headline)
                    .foregroundColor(Color.currentText)
                Spacer()
                Button(showingRowOptions ? "Done" : "Edit") {
                    showingRowOptions.toggle()
                }
                .font(.caption)
                .foregroundColor(Color.currentPrimary)
                if !viewModel.isToday {
                    Button("Today") { viewModel.goToToday() }
                        .font(.caption)
                        .foregroundColor(Color.currentPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            sectionsList
        }
    }

    // MARK: - Components
    private var quickStatsRow: some View {
        let totalHabits = viewModel.totalHabits(from: metrics)
        let totalVices = viewModel.totalVices(from: metrics)
        let activeStreaks = viewModel.activeStreaks(from: metrics, entries: entries)
        let todayCompleted = viewModel.todayCompleted(from: metrics, entries: entries)

        return HStack(spacing: 12) {
            if totalHabits > 0 {
                StatCard(title: "Habits", value: "\(totalHabits)", icon: "checkmark.circle.fill", color: Color.currentSuccess)
            }
            if totalVices > 0 {
                StatCard(title: "Vices", value: "\(totalVices)", icon: "xmark.circle.fill", color: Color.currentError)
            }
            if activeStreaks > 0 {
                StatCard(title: "Streaks", value: "\(activeStreaks)", icon: "flame.fill", color: Color.currentWarning)
            }
            StatCard(title: "Today", value: "\(todayCompleted)/\(metrics.count)", icon: "calendar", color: Color.currentPrimary)
        }
    }

    private var weekMiniCalendar: some View {
        HStack(spacing: 8) {
            ForEach(weekDays, id: \.self) { day in
                let isSelected = Calendar.current.isDate(day, inSameDayAs: viewModel.selectedDate)
                let isToday = Calendar.current.isDateInToday(day)
                VStack(spacing: 4) {
                    Text(shortWeekday(for: day))
                        .font(.caption2)
                        .foregroundColor(Color.currentSecondaryText)
                        .frame(height: 12)
                    Text(dayOfMonth(for: day))
                        .font(.subheadline)
                        .monospacedDigit()
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? Color.currentBackground : Color.currentText)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.currentPrimary : (isToday ? Color.currentPrimary.opacity(0.12) : Color.clear))
                        )
                }
                .frame(width: 36)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.selectedDate = day
                }
            }
        }
    }

    private var sectionsList: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                Section(header: sectionHeader(title: "Habits", items: habits)) {
                    ForEach(habits) { metric in
                        CompactMetricRow(metric: metric, selectedDate: viewModel.selectedDate, showOptions: showingRowOptions) {
                            // primary toggle
                            viewModel.toggleMetricCompletion(metric, in: modelContext, entries: entries)
                        } onLog: {
                            showingLoggingSheetForMetric = metric
                        } onEdit: {
                            viewModel.showEditMetric(metric)
                        } onDelete: {
                            viewModel.metricToDelete = metric
                            viewModel.showingDeleteConfirmation = true
                        }
                    }
                }

                Section(header: sectionHeader(title: "Vices", items: vices)) {
                    ForEach(vices) { metric in
                        CompactMetricRow(metric: metric, selectedDate: viewModel.selectedDate, showOptions: showingRowOptions) {
                            viewModel.toggleMetricCompletion(metric, in: modelContext, entries: entries)
                        } onLog: {
                            showingLoggingSheetForMetric = metric
                        } onEdit: {
                            viewModel.showEditMetric(metric)
                        } onDelete: {
                            viewModel.metricToDelete = metric
                            viewModel.showingDeleteConfirmation = true
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .alert("Delete Habit", isPresented: $viewModel.showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { viewModel.metricToDelete = nil }
            Button("Delete", role: .destructive) { viewModel.deleteMetric(in: modelContext, entries: entries) }
        } message: {
            if let metric = viewModel.metricToDelete {
                Text("Are you sure you want to delete '\(metric.name)'? This will also delete all associated entries and cannot be undone.")
            }
        }
    }

    private func sectionHeader(title: String, items: [Metric]) -> some View {
        let completed = completedCount(for: items)
        return HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.currentText)
            Spacer()
            Text("\(completed)/\(items.count) today")
                .font(.caption)
                .foregroundColor(Color.currentSecondaryText)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .background(Color.currentSecondaryBackground)
    }

    // MARK: - Helpers
    private var weekHeaderTitle: String {
        let df = DateFormatter()
        df.dateFormat = "EEE, MMM d"
        return df.string(from: viewModel.selectedDate)
    }

    private func shortWeekday(for date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "E"
        return df.string(from: date)
    }

    private func dayOfMonth(for date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df.string(from: date)
    }
}

// MARK: - CompactMetricRow
private struct CompactMetricRow: View {
    let metric: Metric
    let selectedDate: Date
    let showOptions: Bool
    let onToggle: () -> Void
    let onLog: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @Query private var entries: [MetricEntry]

    private var selectedDateEntry: MetricEntry? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        return entries.first { $0.metricID == metric.id && calendar.isDate($0.date, inSameDayAs: startOfDay) }
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
            Image(systemName: metric.safeHabitType.icon)
                .foregroundColor(metric.safeHabitType == .positive ? Color.currentSuccess : Color.currentError)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(metric.name)
                    .font(.headline)
                    .foregroundColor(Color.currentText)

                HStack(spacing: 10) {
                    let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: selectedDate)
                    if streak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill").foregroundColor(Color.currentWarning).font(.caption)
                            Text(metric.safeHabitType == .positive ? "\(streak) day streak" : "\(streak) days clean")
                                .font(.caption)
                                .foregroundColor(Color.currentSecondaryText)
                        }
                    }

                    if let goal = metric.booleanGoals.first {
                        let progress = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: selectedDate)
                        HStack(spacing: 4) {
                            Image(systemName: "target").foregroundColor(Color.currentPrimary).font(.caption)
                            Text("\(Int(progress.current))/\(Int(progress.target))")
                                .font(.caption)
                                .foregroundColor(Color.currentSecondaryText)
                        }
                    }
                }
            }

            Spacer()

            // Quick toggle
            Button(action: onToggle) {
                let isCompleted = selectedDateEntry?.value == true
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompleted ? Color.currentSuccess : Color.currentSecondaryText)
            }
            }

            if showOptions {
                HStack(spacing: 12) {
                    Button(action: onLog) { Label("Log", systemImage: "square.and.pencil") }
                        .buttonStyle(.bordered)
                    Button(action: onEdit) { Label("Edit Habit", systemImage: "pencil") }
                        .buttonStyle(.bordered)
                    Button(role: .destructive, action: onDelete) { Label("Delete", systemImage: "trash") }
                        .buttonStyle(.bordered)
                    Spacer()
                }
            }
        }
        .padding(12)
        .background(Color.currentSecondaryBackground)
        .cornerRadius(12)
        .contextMenu {
            Button(action: onLog) { Label("Log", systemImage: "square.and.pencil") }
            Button(action: onEdit) { Label("Edit Habit", systemImage: "pencil") }
            Button(role: .destructive, action: onDelete) { Label("Delete", systemImage: "trash") }
        }
        .onTapGesture { onLog() }
    }
}

// MARK: - LoggingSheet (skeleton)
private struct LoggingSheet: View, Identifiable {
    let id = UUID()
    let metric: Metric
    let selectedDate: Date

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [MetricEntry]

    @State private var value: Bool = false
    @State private var details: String = ""
    @State private var motivation: String = ""
    @State private var showingQuantitySheet: Bool = false

    private var existingEntry: MetricEntry? {
        let start = Calendar.current.startOfDay(for: selectedDate)
        return entries.first { $0.metricID == metric.id && Calendar.current.isDate($0.date, inSameDayAs: start) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Status")) {
                    Toggle(isOn: $value) {
                        Text(metric.safeHabitType == .positive ? "Did it" : "Avoided")
                    }
                }

                Section(header: Text("Details")) {
                    TextField("Optional details", text: $details, axis: .vertical)
                }

                Section(header: Text("Motivation")) {
                    TextField("Why?", text: $motivation, axis: .vertical)
                }

                Section(header: Text("Quantity")) {
                    HStack {
                        Text(existingEntry?.quantityString ?? "Not set")
                            .foregroundColor(.currentSecondaryText)
                        Spacer()
                        Button("Set Quantity") { showingQuantitySheet = true }
                            .foregroundColor(.currentPrimary)
                    }
                }
            }
            .navigationTitle(metric.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndClose() }
                }
            }
            .onAppear { seedDefaults() }
            .sheet(isPresented: $showingQuantitySheet) {
                QuantityInputSheet(metric: metric, selectedDate: selectedDate)
            }
        }
    }

    private func seedDefaults() {
        if let entry = existingEntry {
            value = entry.value
            details = entry.details ?? ""
            motivation = entry.motivation ?? ""
        } else {
            // Defaults per spec: habits not done; vices avoided
            value = metric.safeHabitType == .positive ? false : false // vices avoided means no true entry; keep false
        }
    }

    private func saveAndClose() {
        // Persist via HomeViewModel-like helpers
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)

        if let entry = existingEntry {
            entry.value = value
            entry.details = details.isEmpty ? nil : details
            entry.motivation = motivation.isEmpty ? nil : motivation
        } else {
            let newEntry = MetricEntry(metricID: metric.id, date: startOfDay, value: value)
            newEntry.details = details.isEmpty ? nil : details
            newEntry.motivation = motivation.isEmpty ? nil : motivation
            modelContext.insert(newEntry)
        }

        try? modelContext.save()
        dismiss()
    }

    // Quantity is handled by QuantityInputSheet which persists directly
}

#Preview {
    HomeView2()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}


