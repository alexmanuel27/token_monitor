import Testing
@testable import UsageBarCore

@Test func readsOnlyGeminiQuotaFromAntigravity() throws {
    let output = """
        Gemini Models\tWeekly Limit Remaining\t78%\t2026-09-25T11:33:33Z
        Gemini Models\tFive Hour Limit Remaining\t55%\t2026-09-18T16:33:33Z
        Claude and GPT models\tWeekly Limit Remaining\t100%\t2026-09-25T11:34:21Z
        """
    let windows = try AntigravityProbe.parse(output).windows
    #expect(windows.map(\.usedPercent) == [45, 22])
    #expect(windows.map(\.windowMinutes) == [300, 10080])
    #expect(throws: AntigravityParseError.self) {
        try AntigravityProbe.parse("Gemini Models\tWeekly Limit Remaining\t80%\t2026-09-25T11:33:33Z")
    }
}
