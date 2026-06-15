import SwiftUI

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        NavigationStack {
            VStack {
                let minDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
                DatePicker("Select Date", selection: $selectedDate, in: minDate...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Spacer()
            }
            .background(Color.currentBackground)
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
