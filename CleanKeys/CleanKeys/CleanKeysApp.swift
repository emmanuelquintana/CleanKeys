import SwiftUI
import AppKit

@main
struct CleanKeysApp: App {
    @StateObject private var keyboard = KeyboardLockManager.shared

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environmentObject(keyboard)
        } label: {
            Label(
                keyboard.isLocked ? "CleanKeys activo" : "CleanKeys",
                systemImage: keyboard.isLocked ? "lock.fill" : "keyboard"
            )
        }
        .menuBarExtraStyle(.menu)

        WindowGroup("CleanKeys", id: "main-window") {
            ContentView()
                .environmentObject(keyboard)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environmentObject(keyboard)
        }
    }
}

struct MenuBarContentView: View {
    @EnvironmentObject private var keyboard: KeyboardLockManager
    @Environment(\.openWindow) private var openWindow

    private let githubURL = URL(string: "https://github.com/emmanuelquintana")!

    var body: some View {
        if keyboard.isLocked {
            Button("Desbloquear ahora") {
                keyboard.stopLock()
            }

            Text("Tiempo restante: \(keyboard.formattedRemainingTime())")

            Divider()
        } else {
            Button("Bloquear 30 segundos") {
                keyboard.startLock(duration: 30)
            }

            Button("Bloquear 1 minuto") {
                keyboard.startLock(duration: 60)
            }

            Button("Bloquear 5 minutos") {
                keyboard.startLock(duration: 300)
            }

            Button("Bloquear 10 minutos") {
                keyboard.startLock(duration: 600)
            }

            Button("Bloquear 15 minutos") {
                keyboard.startLock(duration: 900)
            }

            Divider()
        }

        Button("Abrir CleanKeys") {
            openWindow(id: "main-window")
        }

        SettingsLink {
            Text("Ajustes")
        }

        Divider()

        Button("GitHub del desarrollador") {
            NSWorkspace.shared.open(githubURL)
        }

        Button("Permisos de Accesibilidad") {
            keyboard.requestAccessibilityPermission()
            keyboard.openAccessibilitySettings()
        }

        Divider()

        Button("Salir") {
            NSApplication.shared.terminate(nil)
        }
    }
}
