import SwiftUI
import AppKit

struct SettingsView: View {
    @EnvironmentObject private var keyboard: KeyboardLockManager

    @AppStorage("defaultDuration") private var defaultDuration: Int = 300
    @AppStorage("customDuration") private var customDuration: Int = 300
    @AppStorage("unlockShortcut") private var unlockShortcut: String = UnlockShortcut.controlOptionCommandL.rawValue
    @AppStorage("showCleaningOverlay") private var showCleaningOverlay: Bool = true
    @AppStorage("dimScreenDuringCleaning") private var dimScreenDuringCleaning: Bool = true
    @AppStorage("blockPointerClicks") private var blockPointerClicks: Bool = false
    @AppStorage("playLockSounds") private var playLockSounds: Bool = true

    private let githubURL = URL(string: "https://github.com/emmanuelquintana")!

    var body: some View {
        Form {
            Section("Permisos") {
                HStack {
                    Text("Accesibilidad")

                    Spacer()

                    Text(keyboard.hasAccessibilityPermission ? "Activo" : "Pendiente")
                        .foregroundStyle(keyboard.hasAccessibilityPermission ? Color.green : Color.orange)
                        .fontWeight(.semibold)
                }

                HStack {
                    Button("Solicitar permiso") {
                        keyboard.requestAccessibilityPermission()
                    }

                    Button("Abrir Configuración") {
                        keyboard.openAccessibilitySettings()
                    }

                    Button("Actualizar estado") {
                        keyboard.refreshPermissionStatus()
                    }
                }

                Text("CleanKeys necesita Accesibilidad para bloquear temporalmente el teclado mientras limpias tu Mac.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Tiempo de bloqueo") {
                Picker("Duración predeterminada", selection: $defaultDuration) {
                    Text("30 segundos").tag(30)
                    Text("1 minuto").tag(60)
                    Text("3 minutos").tag(180)
                    Text("5 minutos").tag(300)
                    Text("10 minutos").tag(600)
                    Text("15 minutos").tag(900)
                    Text("Personalizado").tag(customDuration)
                }

                Stepper(
                    "Tiempo personalizado: \(customDuration) segundos",
                    value: $customDuration,
                    in: 30...900,
                    step: 30
                )

                Text("Por seguridad, el bloqueo máximo es de 15 minutos.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Desbloqueo") {
                Picker("Atajo", selection: $unlockShortcut) {
                    ForEach(UnlockShortcut.allCases) { shortcut in
                        Text(shortcut.title).tag(shortcut.rawValue)
                    }
                }

                Text("El atajo actual se usa para desbloquear manualmente el teclado.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Modo limpieza") {
                Toggle("Mostrar pantalla de limpieza", isOn: $showCleaningOverlay)

                Toggle("Atenuar pantalla", isOn: $dimScreenDuringCleaning)

                Toggle("Bloquear clicks del mouse/trackpad", isOn: $blockPointerClicks)
                    .onChange(of: blockPointerClicks) {
                        keyboard.updateOverlayPointerBehavior()
                    }

                Toggle("Sonido al bloquear/desbloquear", isOn: $playLockSounds)

                Text("Recomendación: deja el mouse/trackpad activo para evitar quedarte sin control si algo falla.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Seguridad") {
                Text("CleanKeys siempre desbloquea automáticamente al terminar el contador. Esto evita que el teclado quede bloqueado indefinidamente.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("Desbloquear ahora") {
                    keyboard.stopLock()
                }
                .disabled(!keyboard.isLocked)
            }

            Section("Desarrollador") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CleanKeys")
                            .fontWeight(.semibold)

                        Text("Creado por Emmanuel Quintana")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                Link(destination: githubURL) {
                    Label("GitHub: emmanuelquintana", systemImage: "link")
                }

                Button("Abrir GitHub en navegador") {
                    NSWorkspace.shared.open(githubURL)
                }
            }
        }
        .padding(24)
        .frame(width: 540, height: 650)
        .onAppear {
            keyboard.refreshPermissionStatus()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(KeyboardLockManager.shared)
}
