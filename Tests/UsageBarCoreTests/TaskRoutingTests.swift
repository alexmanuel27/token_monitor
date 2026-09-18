import Foundation
import Testing
@testable import UsageBarCore

@Test func choosesTheProviderWithMoreRoomInItsTightestWindow() {
    func status(_ kind: ProviderKind, _ short: Double, _ long: Double) -> ProviderStatus {
        ProviderStatus(kind: kind, outcome: .report(ProviderReport(plan: nil, windows: [
            UsageWindow(id: "short", windowMinutes: 300, usedPercent: short, resetsAt: nil),
            UsageWindow(id: "long", windowMinutes: 10080, usedPercent: long, resetsAt: nil),
        ])))
    }
    let claude = status(.claude, 10, 95)
    let codex = status(.codex, 70, 20)
    #expect(TaskRouting.choose([claude, codex]) == .codex)
    #expect(TaskRouting.choose([status(.claude, 10, 10), status(.codex, 90, 90)]) == .claude)
    #expect(TaskRouting.choose([claude]) == .claude)
    #expect(TaskRouting.choose([claude, codex, status(.antigravity, 5, 10)]) == .antigravity)
    #expect(TaskRouting.choose([]) == nil)
}
