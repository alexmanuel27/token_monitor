import Foundation

public enum AntigravityProbe {
    public static func probe() async -> ProviderStatus {
        do {
            let report = try await offMainActor { try readReport() }
            return ProviderStatus(kind: .antigravity, outcome: .report(report))
        } catch {
            return ProviderStatus(kind: .antigravity, outcome: .unavailable(
                (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            ))
        }
    }

    private static func readReport() throws -> ProviderReport {
        guard let executable = ExecutableLocator.locate("agy") else {
            throw ShellError.executableNotFound("agy")
        }
        let result = try Shell.run(executable: executable, arguments: ["--print", "/usage"], timeout: 30)
        guard result.exitCode == 0 else {
            throw ShellError.failed(command: "agy --print /usage", exitCode: result.exitCode,
                stderr: result.stderr.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return try parse(result.stdout)
    }

    static func parse(_ output: String) throws -> ProviderReport {
        var windows: [UsageWindow] = []
        for line in output.split(whereSeparator: \.isNewline) {
            let fields = line.split(separator: "\t", omittingEmptySubsequences: false)
            guard fields.count == 4, fields[0] == "Gemini Models" else { continue }
            let minutes: Int
            let id: String
            switch fields[1] {
            case "Weekly Limit Remaining": (minutes, id) = (10080, "seven_day")
            case "Five Hour Limit Remaining": (minutes, id) = (300, "five_hour")
            default: continue
            }
            guard let remaining = Double(fields[2].dropLast()), fields[2].last == "%",
                (0...100).contains(remaining), let reset = ISO8601.date(from: String(fields[3]))
            else { continue }
            windows.append(UsageWindow(id: id, windowMinutes: minutes,
                usedPercent: 100 - remaining, resetsAt: reset))
        }
        guard windows.count == 2, Set(windows.map(\.id)) == ["five_hour", "seven_day"] else {
            throw AntigravityParseError()
        }
        return ProviderReport(plan: nil, windows: windows.sorted { ($0.windowMinutes ?? 0) < ($1.windowMinutes ?? 0) })
    }
}

struct AntigravityParseError: LocalizedError {
    var errorDescription: String? { "Antigravity did not return both Gemini quotas." }
}
