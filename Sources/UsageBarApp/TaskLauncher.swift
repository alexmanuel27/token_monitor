import AppKit
import UsageBarCore

enum TaskLauncher {
    static func open(_ task: String, in directory: URL, with provider: ProviderKind) throws {
        guard !task.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw LaunchError("Escribe una tarea antes de enviarla.")
        }
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDirectory),
            isDirectory.boolValue, let executable = ExecutableLocator.locate(provider.executableName) else {
            throw LaunchError("No se encontró el proyecto o la aplicación seleccionada.")
        }

        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("token-monitor-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700])
        let prompt = folder.appendingPathComponent("task.txt")
        let script = folder.appendingPathComponent("run.command")
        try task.write(to: prompt, atomically: true, encoding: .utf8)
        let command = """
            #!/bin/zsh
            cd -- \(quote(directory.path)) || exit 1
            task="$(cat -- \(quote(prompt.path)))"
            rm -f -- \(quote(prompt.path)) \(quote(script.path))
            export TOKEN_MONITOR_ROUTED=1
            exec \(quote(executable.path)) "$task"
            """
        try command.write(to: script, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: script.path)

        let open = Process()
        open.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        open.arguments = ["-a", "Terminal", script.path]
        try open.run()
        open.waitUntilExit()
        guard open.terminationStatus == 0 else { throw LaunchError("No se pudo abrir Terminal.") }
    }

    private static func quote(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    struct LaunchError: LocalizedError {
        let message: String
        init(_ message: String) { self.message = message }
        var errorDescription: String? { message }
    }
}
