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
    
    private var calendarEntries: [Date: [MetricEntry]] {
        let filteredEntries = entries.filter { entry in
            // Only show entries that have meaningful content
            guard entry.hasContent else { return false }
            
            // Apply search filter
            if !searchText.isEmpty {
                guard entry.details?.localizedCaseInsensitiveContains(searchText) == true else {
                    return false
                }
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
        
        return Dictionary(grouping: filteredEntries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
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
                                
                                Divider()
                                
                                // Calendar view
                                CalendarGridView(
                                    entries: calendarEntries,
                                    selectedFilter: selectedFilter,
                                    selectedDate: $selectedDate
                                )
                                
                                Divider()
                                
                                // Entries list view
                                EntriesListView(
                                    selectedFilter: selectedFilter,
                                    entries: entries,
                                    metrics: metrics
                                )
                            }
                        }
                    }
                }
                .navigationTitle("History")
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


struct CalendarGridView: View {
    let entries: [Date: [MetricEntry]]
    let selectedFilter: MetricFilter
    @Binding var selectedDate: Date
    
    private let calendar = CalendarHelper.calendar
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()
    
    private var currentMonth: Date {
        calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
    }
    
    private var monthDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        
        let startOfMonth = monthInterval.start
        let endOfMonth = monthInterval.end
        
        // Get the calendar start date using CalendarHelper
        let startOfCalendar = CalendarHelper.calendarStartForMonth(for: currentMonth)
        
        var days: [Date] = []
        var currentDay = startOfCalendar
        
        while currentDay < endOfMonth || days.count < 42 { // 6 weeks max
            days.append(currentDay)
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? currentDay
            
            if days.count >= 42 { break }
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Month header
            HStack {
                Button {
                    withAnimation {
                        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    withAnimation {
                        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            // Weekday headers
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(monthDays, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        entries: entries[date] ?? [],
                        selectedFilter: selectedFilter,
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let entries: [MetricEntry]
    let selectedFilter: MetricFilter
    let isCurrentMonth: Bool
    
    private var dayNumber: String {
        Calendar.current.component(.day, from: date).description
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var hasEntry: Bool {
        switch selectedFilter {
        case .all:
            return entries.contains { $0.value }
        case .allHabits, .allVices:
            return entries.contains { $0.value }
        case .specific(let metric):
            return entries.contains { $0.metricID == metric.id && $0.value }
        }
    }
    
    private var entryWithDetails: MetricEntry? {
        switch selectedFilter {
        case .all:
            return entries.first { $0.value && $0.details != nil && !$0.details!.isEmpty }
        case .allHabits, .allVices:
            return entries.first { $0.value && $0.details != nil && !$0.details!.isEmpty }
        case .specific(let metric):
            return entries.first { $0.metricID == metric.id && $0.value && $0.details != nil && !$0.details!.isEmpty }
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(dayNumber)
                .font(.caption)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isCurrentMonth ? .primary : .secondary)
            
            if hasEntry {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
            } else if !entries.isEmpty {
                Circle()
                    .fill(Color.red)
                    .frame(width: 6, height: 6)
            }
            
            // Show details or quantity if available
            if let entry = entryWithDetails {
                if let details = entry.details, !details.isEmpty {
                    Text(details)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 2)
                } else if let quantityString = entry.quantityString {
                    Text(quantityString)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 2)
                }
            }
        }
        .frame(minHeight: 40)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isToday ? Color.accentColor.opacity(0.2) : Color.clear)
        )
    }
}

struct EntriesListView: View {
    let selectedFilter: MetricFilter
    let entries: [MetricEntry]
    let metrics: [Metric]
    
    private var filteredEntries: [MetricEntry] {
        let filtered = entries.filter { entry in
            // Only show entries that have meaningful content
            guard entry.hasContent else { return false }
            
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
                
                Spacer()
                
                Text("\(filteredEntries.count) entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top)
            
            if filteredEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No entries found")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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

struct EditableEntryCell: View {
    @Environment(\.modelContext) private var modelContext
    let entry: MetricEntry
    let metrics: [Metric]
    
    @State private var isEditing = false
    @State private var editingDetails = ""
    @State private var editingMotivation = ""
    @State private var editingValue = false
    @State private var editingQuantity = 1
    @State private var editingUnit = ""
    
    private var metric: Metric? {
        metrics.first { $0.id == entry.metricID }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private var isVice: Bool {
        metric?.safeHabitType == .vice
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Date and status
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateFormatter.string(from: entry.date))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 4) {
                        Image(systemName: entry.value ? (isVice ? "xmark.circle.fill" : "checkmark.circle.fill") : (isVice ? "checkmark.circle.fill" : "xmark.circle.fill"))
                            .foregroundColor(entry.value ? (isVice ? .red : .green) : (isVice ? .green : .red))
                            .font(.caption)
                        
                        Text(entry.value ? (isVice ? "Did it" : "Done") : (isVice ? "Avoided" : "Skipped"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Metric name and quantity - small and unobtrusive
                    if let metric = metric {
                        HStack(spacing: 4) {
                            Text(metric.name)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .opacity(0.7)
                            
                            if let quantityString = entry.quantityString {
                                Text(quantityString)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(metric.safeHabitType == .positive ? .blue : .orange)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill((metric.safeHabitType == .positive ? Color.blue : Color.orange).opacity(0.2))
                                    )
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Edit button
                Button {
                    editingDetails = entry.details ?? ""
                    editingMotivation = entry.motivation ?? ""
                    editingValue = entry.value
                    editingQuantity = entry.quantity ?? 1
                    editingUnit = entry.unit ?? ""
                    isEditing = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            
            // Details
            if let details = entry.details, !details.isEmpty {
                Text(details)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.vertical, 4)
            }
            
            // Motivation (for vices)
            if let motivation = entry.motivation, !motivation.isEmpty {
                Text(motivation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.vertical, 2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $isEditing) {
            EditEntryView(
                entry: entry,
                metric: metric,
                editingDetails: $editingDetails,
                editingMotivation: $editingMotivation,
                editingValue: $editingValue,
                isPresented: $isEditing,
                editingQuantity: $editingQuantity,
                editingUnit: $editingUnit
            )
        }
    }
}

struct EditEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let entry: MetricEntry
    let metric: Metric?
    
    @Binding var editingDetails: String
    @Binding var editingMotivation: String
    @Binding var editingValue: Bool
    @Binding var isPresented: Bool
    @Binding var editingQuantity: Int
    @Binding var editingUnit: String
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }
    
    private var isVice: Bool {
        metric?.safeHabitType == .vice
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Edit Entry")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(dateFormatter.string(from: entry.date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let metric = metric {
                        Text(metric.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                
                // Value toggle
                VStack(alignment: .leading, spacing: 8) {
                    Text(isVice ? "Did you avoid this vice?" : "Did you do this habit?")
                        .font(.headline)
                    
                    Toggle(isOn: $editingValue) {
                        Text(editingValue ? (isVice ? "Avoided" : "Done") : (isVice ? "Did it" : "Skipped"))
                            .font(.body)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: isVice ? .red : .green))
                }
                
                // Quantity section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quantity (Optional)")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        // Quantity stepper
                        HStack(spacing: 8) {
                            Button {
                                if editingQuantity > 0 {
                                    editingQuantity -= 1
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(editingQuantity > 0 ? .blue : .gray)
                            }
                            .disabled(editingQuantity <= 0)
                            
                            Text("\(editingQuantity)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .frame(minWidth: 40)
                            
                            Button {
                                editingQuantity += 1
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer()
                        
                        // Unit picker
                        TextField("Unit", text: $editingUnit)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                // Details (for positive habits)
                if !isVice {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Details (Optional)")
                            .font(.headline)
                        
                        TextField("What did you do?", text: $editingDetails, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                }
                
                // Motivation (for vices)
                if isVice {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Motivation (Optional)")
                            .font(.headline)
                        
                        TextField("Why did you avoid this?", text: $editingMotivation, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        entry.value = editingValue
        entry.details = editingDetails.isEmpty ? nil : editingDetails
        entry.motivation = editingMotivation.isEmpty ? nil : editingMotivation
        entry.quantity = editingQuantity > 0 ? editingQuantity : nil
        entry.unit = editingUnit.isEmpty ? nil : editingUnit
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
