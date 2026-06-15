import SwiftUI
import Charts

// MARK: - QuantityChartView Component
struct QuantityChartView: View {
    let filter: MetricFilter
    let entries: [MetricEntry]
    let metrics: [Metric]
    
    @State private var selectedTimeframe: Timeframe = .month
    
    private var quantityData: [QuantityDataPoint] {
        let filteredEntries = entries.filter { entry in
            guard entry.hasQuantity, TrackingSemantics.isLoggedForDay(entry: entry) else { return false }
            
            switch filter {
            case .all:
                return true
            case .allHabits:
                return metrics.first { $0.id == entry.metricID }?.habitType == .positive
            case .allVices:
                return metrics.first { $0.id == entry.metricID }?.habitType == .vice
            case .specific(let metric):
                return entry.metricID == metric.id
            }
        }
        
        return filteredEntries.compactMap { entry in
            guard let quantity = entry.quantity, quantity > 0,
                  let metric = metrics.first(where: { $0.id == entry.metricID }) else {
                return nil
            }
            
            return QuantityDataPoint(
                date: entry.date,
                quantity: quantity,
                unit: entry.unit,
                metricName: metric.name,
                habitType: metric.habitType
            )
        }.sorted { $0.date < $1.date }
    }
    
    private var weeklyQuantityData: [WeeklyQuantityData] {
        let calendar = Calendar.current
        let groupedByWeek = Dictionary(grouping: quantityData) { dataPoint in
            calendar.dateInterval(of: .weekOfYear, for: dataPoint.date)?.start ?? dataPoint.date
        }
        
        return groupedByWeek.compactMap { (weekStart, dataPoints) in
            guard !dataPoints.isEmpty else { return nil }
            
            let totalQuantity = dataPoints.reduce(0) { $0 + $1.quantity }
            let averageQuantity = Double(totalQuantity) / Double(dataPoints.count)
            let unit = dataPoints.first?.unit
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            let weekString = formatter.string(from: weekStart)
            
            return WeeklyQuantityData(
                week: weekString,
                totalQuantity: totalQuantity,
                averageQuantity: averageQuantity,
                unit: unit
            )
        }.sorted { $0.week < $1.week }
    }
    
    private var hasQuantityData: Bool {
        !quantityData.isEmpty
    }
    
    private var chartTitle: String {
        switch filter {
        case .all:
            return "Quantity Trends"
        case .allHabits:
            return "Positive Habits Quantity"
        case .allVices:
            return "Vice Quantities Logged"
        case .specific(let metric):
            return "\(metric.name) Quantity"
        }
    }
    
    private var chartSubtitle: String {
        if hasQuantityData {
            let totalEntries = quantityData.count
            let totalQuantity = quantityData.reduce(0) { $0 + $1.quantity }
            let averageQuantity = Double(totalQuantity) / Double(totalEntries)
            
            return "\(totalEntries) entries • Avg: \(String(format: "%.1f", averageQuantity))"
        } else {
            return "No quantity data available"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(chartTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.currentText)
                
                Text(chartSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.currentSecondaryText)
            }
            
            if hasQuantityData {
                // Timeframe selector
                Picker("Timeframe", selection: $selectedTimeframe) {
                    Text("Daily").tag(Timeframe.day)
                    Text("Weekly").tag(Timeframe.week)
                    Text("Monthly").tag(Timeframe.month)
                }
                .pickerStyle(.segmented)
                
                // Chart
                if selectedTimeframe == .week {
                    weeklyQuantityChart
                } else {
                    dailyQuantityChart
                }
                
                // Summary stats
                quantitySummaryStats
            } else {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.system(size: 48))
                        .foregroundColor(.currentSecondaryText)
                    
                    Text("No Quantity Data")
                        .font(.headline)
                        .foregroundColor(.currentSecondaryText)
                    
                    Text("Start logging quantities to see trends here")
                        .font(.subheadline)
                        .foregroundColor(.currentSecondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
        .padding()
        .background(Color.currentBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Daily Quantity Chart
    private var dailyQuantityChart: some View {
        Chart(quantityData) { dataPoint in
            LineMark(
                x: .value("Date", dataPoint.date),
                y: .value("Quantity", dataPoint.quantity)
            )
            .foregroundStyle(dataPoint.habitType == .positive ? Color.currentPrimary : Color.currentWarning)
            .lineStyle(StrokeStyle(lineWidth: 2))
            
            PointMark(
                x: .value("Date", dataPoint.date),
                y: .value("Quantity", dataPoint.quantity)
            )
            .foregroundStyle(dataPoint.habitType == .positive ? Color.currentPrimary : Color.currentWarning)
            .symbolSize(50)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .frame(height: 200)
    }
    
    // MARK: - Weekly Quantity Chart
    private var weeklyQuantityChart: some View {
        Chart(weeklyQuantityData) { data in
            BarMark(
                x: .value("Week", data.week),
                y: .value("Average Quantity", data.averageQuantity)
            )
            .foregroundStyle(Color.currentPrimary.gradient)
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .frame(height: 200)
    }
    
    // MARK: - Summary Stats
    private var quantitySummaryStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.currentText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(
                    title: "Total Entries",
                    value: "\(quantityData.count)",
                    icon: "calendar",
                    color: .currentPrimary
                )
                
                StatCard(
                    title: "Total Quantity",
                    value: "\(quantityData.reduce(0) { $0 + $1.quantity })",
                    icon: "number",
                    color: .currentSuccess
                )
                
                StatCard(
                    title: "Average",
                    value: String(format: "%.1f", Double(quantityData.reduce(0) { $0 + $1.quantity }) / Double(quantityData.count)),
                    icon: "chart.bar",
                    color: .currentWarning
                )
                
                StatCard(
                    title: "Max Daily",
                    value: "\(quantityData.map { $0.quantity }.max() ?? 0)",
                    icon: "arrow.up",
                    color: .currentError
                )
            }
        }
    }
}

// MARK: - Timeframe Enum
enum Timeframe: String, CaseIterable {
    case day = "day"
    case week = "week"
    case month = "month"
    
    var displayName: String {
        rawValue.capitalized
    }
}

#Preview {
    QuantityChartView(
        filter: .all,
        entries: [],
        metrics: []
    )
}
