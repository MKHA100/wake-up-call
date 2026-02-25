import SwiftUI
import WakeUpDomain
import WakeUpFeatures
import WakeUpServices

public struct AlarmDashboardView: View {
    @ObservedObject private var alarmsViewModel: AlarmListViewModel
    @ObservedObject private var ledgerViewModel: PenaltyLedgerViewModel
    private let createEditor: () -> AlarmEditorViewModel
    private let onStartWakeSession: (AlarmRule) -> Void

    @State private var showingEditor = false

    public init(
        alarmsViewModel: AlarmListViewModel,
        ledgerViewModel: PenaltyLedgerViewModel,
        createEditor: @escaping () -> AlarmEditorViewModel,
        onStartWakeSession: @escaping (AlarmRule) -> Void
    ) {
        self.alarmsViewModel = alarmsViewModel
        self.ledgerViewModel = ledgerViewModel
        self.createEditor = createEditor
        self.onStartWakeSession = onStartWakeSession
    }

    public var body: some View {
        ZStack {
            DynamicSkyBackgroundView()

            ScrollView {
                VStack(spacing: 20) {
                    dashboardHeader

                    VStack(spacing: 12) {
                        ForEach(alarmsViewModel.alarms, id: \.id) { alarm in
                            AlarmRow(alarm: alarm) {
                                onStartWakeSession(alarm)
                            }
                        }
                    }

                    penaltySection
                }
                .padding(20)
            }
        }
        .task {
            await alarmsViewModel.refresh()
            await ledgerViewModel.refresh()
        }
        .sheet(isPresented: $showingEditor) {
            AlarmEditorSheetView(viewModel: createEditor()) {
                Task {
                    await alarmsViewModel.refresh()
                }
            }
        }
    }

    private var dashboardHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Good Night")
                    .font(WakeUpDesign.titleFont())
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    showingEditor = true
                } label: {
                    Label("New Alarm", systemImage: "plus.circle.fill")
                        .foregroundStyle(.yellow)
                        .font(.custom("AvenirNext-Bold", size: 16))
                }
            }

            Text("Set an alarm, attach a penalty, and beat snooze.")
                .font(WakeUpDesign.subtitleFont())
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var penaltySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Penalty Ledger")
                .font(.custom("AvenirNext-Bold", size: 20))
                .foregroundStyle(.white)

            if ledgerViewModel.events.isEmpty {
                Text("No penalties recorded yet.")
                    .foregroundStyle(.white.opacity(0.8))
            } else {
                ForEach(ledgerViewModel.events, id: \.id) { event in
                    HStack {
                        Text(event.reason.rawValue.capitalized)
                        Spacer()
                        Text("\(event.amount.description) \(event.status.rawValue)")
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct AlarmRow: View {
    let alarm: AlarmRule
    let onSimulateRing: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(alarm.label)
                    .font(.custom("AvenirNext-DemiBold", size: 20))
                Spacer()
                Button("Ring") { onSimulateRing() }
                    .buttonStyle(.borderedProminent)
            }

            Text(String(format: "%02d:%02d", alarm.timeOfDay.hour, alarm.timeOfDay.minute))
                .font(.custom("AvenirNext-Bold", size: 32))

            Text("Penalty: \(alarm.penaltyAmount.description) \(alarm.currency)")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .foregroundStyle(.white)
    }
}
