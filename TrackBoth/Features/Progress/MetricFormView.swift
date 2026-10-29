import SwiftData
import SwiftUI

struct MetricFormView: View {
    var metric: Metric?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var model: MetricFormViewModel?
    @State private var confirmDelete = false

    var body: some View {
        NavigationStack {
            Form {
                if let model {
                    TextField(RecoveryCopy.nameField, text: Bindable(model).name)
                    if let error = model.nameError, !model.name.isEmpty || !model.isNew {
                        Text(error).font(.footnote).foregroundStyle(Color.tbSlip)
                    }
                    if model.showsTypePicker {
                        Picker("Type", selection: Bindable(model).habitType) {
                            Text(RecoveryCopy.quitting).tag(HabitType.vice)
                            Text(RecoveryCopy.building).tag(HabitType.positive)
                        }
                    }
                    if model.showsQuitDate {
                        DatePicker(RecoveryCopy.quitDate, selection: Bindable(model).startedAt, in: ...Date(), displayedComponents: .date)
                    }
                    if model.showsCost {
                        TextField(RecoveryCopy.costPerDay, text: Bindable(model).costText)
                            .keyboardType(.decimalPad)
                    }
                    iconPicker(model)
                    if !model.isNew {
                        Toggle(RecoveryCopy.archive, isOn: Bindable(model).isArchived)
                        Button(RecoveryCopy.delete, role: .destructive) { confirmDelete = true }
                    }
                }
            }
            .navigationTitle(model?.isNew == true ? RecoveryCopy.addSomething : RecoveryCopy.edit)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(RecoveryCopy.close) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(RecoveryCopy.save) { save() }
                        .disabled(model?.canSave != true)
                }
            }
            .confirmationDialog(RecoveryCopy.deleteConfirm(metric?.name ?? ""), isPresented: $confirmDelete, titleVisibility: .visible) {
                Button(RecoveryCopy.delete, role: .destructive) { deleteMetric() }
                Button(RecoveryCopy.close, role: .cancel) {}
            }
        }
        .onAppear {
            if model == nil { model = MetricFormViewModel(metric: metric) }
        }
    }

    private func iconPicker(_ model: MetricFormViewModel) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: Spacing.s) {
            ForEach(model.icons, id: \.self) { icon in
                Button {
                    model.iconName = icon
                } label: {
                    Image(systemName: icon)
                        .frame(minWidth: 44, minHeight: 44)
                        .foregroundStyle(model.iconName == icon ? Color.tbOnBrand : Color.tbTextPrimary)
                        .background(model.iconName == icon ? Color.tbBrand : Color.tbSurfaceMuted, in: RoundedRectangle(cornerRadius: Radius.control))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(icon)
            }
        }
    }

    private func save() {
        guard let model else { return }
        _ = try? model.save(metric: metric, store: RecoveryStore(context: modelContext), now: Date())
        if model.canSave { dismiss() }
    }

    private func deleteMetric() {
        guard let model, let metric else { return }
        try? model.delete(metric, store: RecoveryStore(context: modelContext))
        dismiss()
    }
}
