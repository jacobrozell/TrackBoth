import SwiftUI
import Charts

// MARK: - ChartsEmptyStateView Component
struct ChartsEmptyStateView: View {
    @State private var animateChart = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue.gradient)
                        .scaleEffect(animateChart ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateChart)
                    
                    Text("Your Journey Starts Here")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Track your habits and watch your progress unfold")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Sample Charts Preview
                VStack(spacing: 20) {
                    Text("See wThe rarely / sometimes / buttons are not selectablehat's possible")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // Sample Line Chart
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("30-Day Progress")
                                .font(.headline)
                            Spacer()
                            Text("Sample Data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        
                        Chart(sampleLineData) { dataPoint in
                            LineMark(
                                x: .value("Day", dataPoint.day),
                                y: .value("Habits", dataPoint.habits)
                            )
                            .foregroundStyle(.blue)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            
                            AreaMark(
                                x: .value("Day", dataPoint.day),
                                y: .value("Habits", dataPoint.habits)
                            )
                            .foregroundStyle(.blue.opacity(0.2))
                        }
                        .frame(height: 150)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Sample Heatmap
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Consistency Heatmap")
                                .font(.headline)
                            Spacer()
                            Text("Sample Data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 13), spacing: 3) {
                            ForEach(sampleHeatmapData) { data in
                                Rectangle()
                                    .fill(data.completed ? Color.green : Color.gray.opacity(0.3))
                                    .frame(height: 15)
                                    .cornerRadius(3)
                            }
                        }
                        .frame(height: 120)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Motivational Section
                VStack(spacing: 16) {
                    Text("Every expert was once a beginner")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 12) {
                        FeatureRow(icon: "chart.bar.fill", title: "Track Progress", description: "Visualize your daily habits and see patterns emerge")
                        FeatureRow(icon: "flame.fill", title: "Build Streaks", description: "Maintain consistency and watch your streaks grow")
                        FeatureRow(icon: "target", title: "Achieve Goals", description: "Set targets and celebrate milestones along the way")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Call to Action
                VStack(spacing: 12) {
                    Text("Ready to start your journey?")
                        .font(.headline)
                    
                    Text("Add your first habit or vice to begin tracking")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
        .onAppear {
            animateChart = true
        }
    }
    
    // Sample data for preview
    private let sampleLineData: [SampleDataPoint] = [
        SampleDataPoint(day: 1, habits: 2),
        SampleDataPoint(day: 3, habits: 3),
        SampleDataPoint(day: 5, habits: 4),
        SampleDataPoint(day: 7, habits: 5),
        SampleDataPoint(day: 10, habits: 6),
        SampleDataPoint(day: 12, habits: 7),
        SampleDataPoint(day: 15, habits: 8),
        SampleDataPoint(day: 18, habits: 9),
        SampleDataPoint(day: 20, habits: 10),
        SampleDataPoint(day: 22, habits: 11),
        SampleDataPoint(day: 25, habits: 12),
        SampleDataPoint(day: 28, habits: 13),
        SampleDataPoint(day: 30, habits: 14)
    ]
    
    private let sampleHeatmapData: [SampleHeatmapData] = (1...90).map { day in
        SampleHeatmapData(
            id: day,
            completed: day > 10 && day % 3 == 0 // Simplified pattern
        )
    }
}

// MARK: - Supporting Views
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue.gradient)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Sample Data Models
struct SampleDataPoint: Identifiable {
    let id = UUID()
    let day: Int
    let habits: Int
}

struct SampleHeatmapData: Identifiable {
    let id: Int
    let completed: Bool
}

#Preview {
    ChartsEmptyStateView()
}
