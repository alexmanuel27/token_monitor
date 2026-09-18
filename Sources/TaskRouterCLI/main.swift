import Foundation
import UsageBarCore

@MainActor
@main
struct TaskRouterCLI {
    static func main() async {
        let args = Array(CommandLine.arguments.dropFirst())
        guard let action = args.first, action == "choose" || action == "run" else {
            fputs("Uso: token-route choose | token-route run 'tarea'\n", stderr)
            exit(2)
        }
        let store = UsageStore(defaults: UserDefaults(suiteName: UsageStore.defaultsSuite)!)
        let statuses = await store.statusesForRouting()
        guard let provider = TaskRouting.choose(statuses) else {
            fputs("No hay datos recientes de cuota para Codex, Claude o Antigravity.\n", stderr)
            exit(1)
        }
        if action == "choose" {
            print(provider.rawValue)
            return
        }
        let task = args.dropFirst().joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !task.isEmpty else {
            fputs("Escribe la actividad que debe realizar la IA.\n", stderr)
            exit(2)
        }
        guard let executable = ExecutableLocator.locate(provider.executableName) else {
            fputs("No se encontró \(provider.executableName).\n", stderr)
            exit(1)
        }
        fputs("Asignada a \(provider.displayName).\n", stderr)
        let process = Process()
        process.executableURL = executable
        switch provider {
        case .claude: process.arguments = ["-p", task]
        case .codex: process.arguments = ["exec", "--skip-git-repo-check", task]
        case .antigravity: process.arguments = ["--model", "gemini-3.1-pro-low", "--print", task]
        }
        process.environment = ProcessInfo.processInfo.environment.merging(["TOKEN_MONITOR_ROUTED": "1"]) { _, new in new }
        process.standardInput = FileHandle.standardInput
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError
        do {
            try process.run()
            process.waitUntilExit()
            exit(process.terminationStatus)
        } catch {
            fputs("No se pudo iniciar \(provider.displayName): \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    }
}
