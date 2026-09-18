import Foundation

public enum TaskRouting {
    /// The most depleted account-wide window is the effective limit for a new task.
    public static func headroom(_ status: ProviderStatus) -> Double? {
        guard status.stale == nil, let windows = status.report?.accountWindows, !windows.isEmpty else { return nil }
        return windows.map { max(0, min(100, 100 - $0.usedPercent)) }.min()
    }

    public static func choose(_ statuses: [ProviderStatus]) -> ProviderKind? {
        statuses.compactMap { status -> (ProviderKind, Double)? in
            guard let remaining = headroom(status) else { return nil }
            return (status.kind, remaining)
        }.max { $0.1 < $1.1 }?.0
    }
}
