import AppKit
import SwiftUI
import UsageBarCore

struct TaskLaunchView: View {
    let store: UsageStore
    @State private var task = ""
    @State private var project = UserDefaults.standard.string(forKey: "taskProject")
        ?? "/Users/alex/Nube /repos/token_monitor"
    @State private var result = ""
    @State private var isLaunching = false

    var body: some View {
        DisclosureGroup("Nueva tarea") {
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $task)
                    .frame(height: 72)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(.secondary.opacity(0.3)))
                HStack {
                    Text(URL(fileURLWithPath: project).lastPathComponent)
                        .lineLimit(1)
                    Button("Cambiar…", action: chooseProject)
                    Spacer()
                    Button(isLaunching ? "Consultando…" : "Asignar") {
                        Task { await assign() }
                    }
                    .disabled(isLaunching || task.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                if !result.isEmpty {
                    Text(result).font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(.top, 8)
        }
    }

    private func chooseProject() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(fileURLWithPath: project)
        if panel.runModal() == .OK, let url = panel.url {
            project = url.path
            UserDefaults.standard.set(project, forKey: "taskProject")
        }
    }

    private func assign() async {
        isLaunching = true
        defer { isLaunching = false }
        let statuses = await store.statusesForRouting()
        guard let chosen = TaskRouting.choose(statuses) else {
            result = "No hay cifras recientes para asignar la tarea. Actualiza las sesiones."
            return
        }
        do {
            try TaskLauncher.open(task, in: URL(fileURLWithPath: project, isDirectory: true), with: chosen)
            let free = statuses.first { $0.kind == chosen }.flatMap(TaskRouting.headroom) ?? 0
            result = "Asignada a \(chosen.displayName): \(Int(free.rounded())) % de cuota libre."
            task = ""
        } catch {
            result = error.localizedDescription
        }
    }
}
