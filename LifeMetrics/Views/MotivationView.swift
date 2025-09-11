import SwiftUI
import SwiftData

// MARK: - MotivationView
/// View for managing motivation content and browsing motivation feed
struct MotivationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var selectedMetric: Metric?
    @State private var showingAddMotivation = false
    @State private var showingAddMetric = false
    @State private var showingSettings = false

    private var viceMetrics: [Metric] {
        metrics.filter { $0.safeHabitType == .vice }
    }

    private var motivationEntries: [MetricEntry] {
        let filteredEntries = entries.filter { entry in
            entry.motivation != nil && !entry.motivation!.isEmpty
        }

        if let selectedMetric = selectedMetric {
            return filteredEntries.filter { $0.metricID == selectedMetric.id }
        }

        return filteredEntries
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if viceMetrics.isEmpty {
                        VStack(spacing: 24) {
                            // Icon with background
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "heart.text.square")
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 12) {
                                Text("No Vices to Motivate")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.primary)

                                Text("Add a vice to start building your motivation library")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(2)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 40)
                    } else if motivationEntries.isEmpty {
                        VStack(spacing: 24) {
                            // Icon with background
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "book.closed")
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 12) {
                                Text("No Motivation Yet")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.primary)

                                Text("Start avoiding your vices and add motivation to build your inspiration library")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(2)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 40)
                    } else {
                        VStack(spacing: 0) {
                            // Metric picker
                            if viceMetrics.count > 1 {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        Button("All Vices") {
                                            selectedMetric = nil
                                        }
                                        .buttonStyle(MetricChipStyle(isSelected: selectedMetric == nil))

                                        ForEach(viceMetrics) { metric in
                                            Button(metric.name) {
                                                selectedMetric = metric
                                            }
                                            .buttonStyle(MetricChipStyle(isSelected: selectedMetric?.id == metric.id))
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.vertical, 8)
                            }

                            // Motivation feed with better spacing
                            ScrollView {
                                LazyVStack(spacing: 20) {
                                    // Show primary motivations first with section header
                                    let primaryMotivations = viceMetrics.filter { 
                                        $0.primaryMotivation != nil && !$0.primaryMotivation!.isEmpty 
                                    }
                                    if !primaryMotivations.isEmpty {
                                        VStack(alignment: .leading, spacing: 16) {
                                            HStack {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                                    .font(.system(size: 16))
                                                Text("Primary Motivations")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.primary)
                                                Spacer()
                                            }
                                            .padding(.horizontal, 20)
                                            
                                            ForEach(primaryMotivations) { metric in
                                                PrimaryMotivationCardView(metric: metric)
                                            }
                                        }
                                    }

                                    // Then show daily motivations with section header
                                    let dailyMotivations = motivationEntries.filter { 
                                        $0.motivation != nil && !$0.motivation!.isEmpty 
                                    }.sorted { $0.date > $1.date }
                                    if !dailyMotivations.isEmpty {
                                        VStack(alignment: .leading, spacing: 16) {
                                            if !primaryMotivations.isEmpty {
                                                HStack {
                                                    Image(systemName: "clock")
                                                        .foregroundColor(.secondary)
                                                        .font(.system(size: 16))
                                                    Text("Daily Motivations")
                                                        .font(.system(size: 18, weight: .semibold))
                                                        .foregroundColor(.primary)
                                                    Spacer()
                                                }
                                                .padding(.horizontal, 20)
                                                .padding(.top, 8)
                                            }
                                            
                                            ForEach(dailyMotivations) { entry in
                                                MotivationCardView(entry: entry, metrics: metrics)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 20)
                            }
                        }
                    }
                }
                .navigationTitle("Motivation")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                .sheet(isPresented: $showingAddMotivation) {
                    AddMotivationView(metrics: viceMetrics)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
            }
        }
    }
}

struct MetricChipStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(isSelected ? 
                        LinearGradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [Color(.systemGray6), Color(.systemGray5)], startPoint: .top, endPoint: .bottom)
                    )
            )
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .shadow(
                color: isSelected ? Color.accentColor.opacity(0.3) : .clear, 
                radius: isSelected ? 8 : 0, 
                x: 0, 
                y: isSelected ? 4 : 0
            )
    }
}

struct PrimaryMotivationCardView: View {
    let metric: Metric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with better spacing
            HStack(alignment: .top, spacing: 12) {
                // Metric info with improved layout
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: metric.safeHabitType.icon)
                            .foregroundColor(.red)
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 20)
                        
                        Text(metric.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        // Star indicator for primary motivation
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                            .shadow(color: .yellow.opacity(0.3), radius: 2)
                    }
                    
                    Text("Primary Motivation")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.leading, 28) // Align with metric name
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Primary motivation text with better typography
            Text(metric.primaryMotivation ?? "")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            
            // Bottom accent with yellow for primary motivations
            Rectangle()
                .fill(Color.yellow.opacity(0.4))
                .frame(height: 4)
                .cornerRadius(2)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color.yellow.opacity(0.15), Color.yellow.opacity(0.05)], startPoint: .top, endPoint: .bottom))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.yellow.opacity(0.4), lineWidth: 2)
        )
        .shadow(
            color: .yellow.opacity(0.2), 
            radius: 12, 
            x: 0, 
            y: 4
        )
    }
}

struct MotivationCardView: View {
    let entry: MetricEntry
    let metrics: [Metric]
    
    private var metric: Metric? {
        metrics.first { $0.id == entry.metricID }
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: entry.date, relativeTo: Date())
    }
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: entry.date)
    }
    
    private var isSuccess: Bool {
        !entry.value // For vices, value=false means avoided (success)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with better spacing
            HStack(alignment: .top, spacing: 12) {
                // Metric info with improved layout
                VStack(alignment: .leading, spacing: 6) {
                    if let metric = metric {
                        HStack(spacing: 8) {
                            Image(systemName: metric.safeHabitType.icon)
                                .foregroundColor(.red)
                                .font(.system(size: 16, weight: .medium))
                                .frame(width: 20)
                            
                            Text(metric.name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Text("\(dayOfWeek) • \(timeAgo)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.leading, 28) // Align with metric name
                }
                
                Spacer()
                
                // Success indicator with better size
                Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isSuccess ? Color.green : Color.red)
                    .font(.system(size: 24))
                    .shadow(color: (isSuccess ? Color.green : Color.red).opacity(0.3), radius: 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Motivation text with better typography
            Text(entry.motivation ?? "")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            
            // Bottom accent with better visibility
            Rectangle()
                .fill(isSuccess ? Color.green.opacity(0.4) : Color.red.opacity(0.4))
                .frame(height: 4)
                .cornerRadius(2)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)], startPoint: .top, endPoint: .bottom))
        )
        .shadow(
            color: .black.opacity(0.08), 
            radius: 8, 
            x: 0, 
            y: 2
        )
    }
}

struct AddMotivationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var entries: [MetricEntry]
    let metrics: [Metric]
    
    @State private var selectedMetric: Metric?
    @State private var motivationText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add Motivation")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Write down your reasons for avoiding a vice. This will help you stay strong when you're struggling.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineSpacing(2)
                    }
                    .padding(.top, 8)
                    
                    // Metric picker with better design
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Vice")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Picker("Vice", selection: $selectedMetric) {
                            Text("Choose a vice to motivate against").tag(nil as Metric?)
                            ForEach(metrics) { metric in
                                HStack(spacing: 12) {
                                    Image(systemName: metric.safeHabitType.icon)
                                        .foregroundColor(.red)
                                        .font(.system(size: 16))
                                        .frame(width: 20)
                                    Text(metric.name)
                                        .font(.system(size: 16, weight: .medium))
                                }.tag(metric as Metric?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                    
                    // Motivation text input with better design
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Motivation")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $motivationText)
                            .frame(minHeight: 200)
                            .font(.system(size: 16, weight: .regular))
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .overlay(
                                // Placeholder text
                                Group {
                                    if motivationText.isEmpty {
                                        VStack {
                                            HStack {
                                                Text("Why do you want to avoid this vice?")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.secondary)
                                                    .padding(.leading, 20)
                                                    .padding(.top, 24)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            )
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Add Motivation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMotivation()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(selectedMetric == nil || motivationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveMotivation() {
        guard let metric = selectedMetric else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        MetricEntry.updateOrCreate(
            for: metric.id,
            date: today,
            value: false,
            motivation: motivationText.trimmingCharacters(in: .whitespacesAndNewlines),
            in: modelContext,
            entries: entries
        )
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    MotivationView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
