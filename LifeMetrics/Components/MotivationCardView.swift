import SwiftUI
import SwiftData

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
