import Foundation

// MARK: - Entry Type Filter Enum
enum EntryTypeFilter: String, CaseIterable {
    case all = "all"
    case boolean = "boolean"
    case quantity = "quantity"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .boolean: return "Boolean"
        case .quantity: return "Quantity"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .boolean: return "target"
        case .quantity: return "chart.bar.fill"
        }
    }
}
