import SwiftUI
import SwiftData

// MARK: - Watch Metric Row View
/// Individual metric row component for Apple Watch
struct WatchMetricRowView: View {
    let metric: Metric
    let entry: MetricEntry?
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    @State private var isPressed = false
    
    private var isCompleted: Bool {
        entry?.value ?? false
    }
    
    private var quantity: Int? {
        entry?.quantity
    }
    
    private var unit: String? {
        entry?.unit
    }
    
    private var quantityText: String? {
        guard let quantity = quantity, quantity > 0 else { return nil }
        let unitText = unit ?? "times"
        return "\(quantity) \(unitText)"
    }
    
    private var icon: String {
        switch metric.habitType {
        case .positive:
            return isCompleted ? "checkmark.circle.fill" : "circle"
        case .vice:
            return isCompleted ? "xmark.circle.fill" : "circle"
        }
    }
    
    private var iconColor: Color {
        switch metric.habitType {
        case .positive:
            return isCompleted ? Color.currentSuccess : Color.currentSecondaryText
        case .vice:
            return isCompleted ? Color.currentError : Color.currentSecondaryText
        }
    }
    
    private var backgroundColor: Color {
        if isPressed {
            return Color.currentSecondaryBackground.opacity(0.5)
        } else if isCompleted {
            return metric.habitType == .positive ? 
                Color.currentSuccess.opacity(0.1) : Color.currentError.opacity(0.1)
        } else {
            return Color.clear
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: 20, height: 20)
                
                // Metric name
                Text(metric.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.currentText)
                    .lineLimit(1)
                
                Spacer()
                
                // Quantity (if available)
                if let quantityText = quantityText {
                    Text(quantityText)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.currentSecondaryText)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0.5) {
            onLongPress()
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        WatchMetricRowView(
            metric: Metric(name: "Exercise", habitType: .positive),
            entry: MetricEntry(metricID: UUID(), date: Date(), value: true, quantity: 30, unit: "min"),
            onTap: {},
            onLongPress: {}
        )
        
        WatchMetricRowView(
            metric: Metric(name: "Read", habitType: .positive),
            entry: MetricEntry(metricID: UUID(), date: Date(), value: false),
            onTap: {},
            onLongPress: {}
        )
        
        WatchMetricRowView(
            metric: Metric(name: "Social Media", habitType: .vice),
            entry: MetricEntry(metricID: UUID(), date: Date(), value: true),
            onTap: {},
            onLongPress: {}
        )
    }
    .padding()
}
