import SwiftUI
import WakeUpDomain
import WakeUpFeatures

public struct AlarmEditorSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel: AlarmEditorViewModel
    private let onSaved: () -> Void

    @State private var recipients: [Recipient] = []
    @State private var showingWarning = false

    public init(viewModel: AlarmEditorViewModel, onSaved: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onSaved = onSaved
    }

    public var body: some View {
        NavigationView {
            Form {
                Section("Alarm") {
                    TextField("Label", text: $viewModel.alarmLabel)
                    wakeTimePicker
                    Picker("Repeat", selection: Binding(get: {
                        viewModel.repeatDays.first ?? .monday
                    }, set: { day in
                        if viewModel.repeatDays.contains(day) {
                            viewModel.repeatDays.remove(day)
                        } else {
                            viewModel.repeatDays.insert(day)
                        }
                    })) {
                        ForEach(RepeatDay.allCases, id: \.self) { day in
                            Text(String(describing: day).capitalized).tag(day)
                        }
                    }
                }

                Section("Penalty") {
                    Picker("Recipient", selection: $viewModel.selectedRecipientId) {
                        Text("Select").tag(Optional<UUID>.none)
                        ForEach(recipients, id: \.id) { recipient in
                            Text(recipient.label).tag(Optional(recipient.id))
                        }
                    }

                    TextField("Amount", value: $viewModel.penaltyAmount, format: .number)
                    TextField("Currency", text: $viewModel.currency)
                }

                Section {
                    Button("Check Sleep Warning") {
                        viewModel.refreshSleepWarning()
                        showingWarning = viewModel.sleepWarning != nil
                    }
                }

                Section {
                    Button("Save Alarm") {
                        Task {
                            _ = try? await viewModel.createAlarm()
                            onSaved()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("New Alarm")
            .task {
                recipients = await viewModel.loadRecipients()
            }
            .alert("Low Sleep Time", isPresented: $showingWarning) {
                Button("Continue", role: .cancel) {}
            } message: {
                if let warning = viewModel.sleepWarning {
                    Text("Hey you have only \(warning.remainingHours, specifier: "%.1f") hours before wake-up. Are you sure?")
                }
            }
        }
    }

    @ViewBuilder
    private var wakeTimePicker: some View {
        #if os(iOS)
        DatePicker("Wake Time", selection: $viewModel.selectedDate, displayedComponents: .hourAndMinute)
            .datePickerStyle(.wheel)
        #else
        DatePicker("Wake Time", selection: $viewModel.selectedDate, displayedComponents: .hourAndMinute)
        #endif
    }
}
