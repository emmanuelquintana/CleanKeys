import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var keyboard: KeyboardLockManager

    @AppStorage("defaultDuration") private var defaultDuration: Int = 300
    @AppStorage("customDuration") private var customDuration: Int = 300
    @AppStorage("showCleaningOverlay") private var showCleaningOverlay: Bool = true
    @AppStorage("dimScreenDuringCleaning") private var dimScreenDuringCleaning: Bool = true
    @AppStorage("blockPointerClicks") private var blockPointerClicks: Bool = false

    @State private var selectedDuration: Int = 300

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 24) {
                iconView

                VStack(spacing: 8) {
                    Text(keyboard.isLocked ? "Modo limpieza activo" : "CleanKeys")
                        .font(.system(size: 38, weight: .bold, design: .rounded))

                    Text(keyboard.statusMessage)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 430)
                }

                if keyboard.isLocked {
                    Text(keyboard.formattedRemainingTime())
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .padding(.top, 2)
                } else {
                    durationSelector
                }

                HStack(spacing: 14) {
                    Button {
                        if keyboard.isLocked {
                            keyboard.stopLock()
                        } else {
                            keyboard.startLock(duration: selectedDuration)
                        }
                    } label: {
                        Label(
                            keyboard.isLocked ? "Desbloquear" : "Bloquear teclado",
                            systemImage: keyboard.isLocked ? "lock.open.fill" : "lock.fill"
                        )
                        .frame(width: 180)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button {
                        keyboard.requestAccessibilityPermission()
                        keyboard.openAccessibilitySettings()
                    } label: {
                        Label("Permisos", systemImage: "hand.raised.fill")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                quickSettings

                Text("Atajo de desbloqueo: \(keyboard.currentShortcut.title)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            .padding(36)
            .frame(width: 560, height: 520)
            .glassCard()
        }
        .frame(width: 720, height: 620)
        .onAppear {
            keyboard.refreshPermissionStatus()
            selectedDuration = defaultDuration
        }
        .onChange(of: blockPointerClicks) {
            keyboard.updateOverlayPointerBehavior()
        }
    }

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 96, height: 96)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.25), lineWidth: 1)
                }

            Image(systemName: keyboard.isLocked ? "lock.fill" : "keyboard")
                .font(.system(size: 42, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
        }
    }

    private var durationSelector: some View {
        HStack(spacing: 10) {
            durationButton(title: "30 s", seconds: 30)
            durationButton(title: "1 min", seconds: 60)
            durationButton(title: "3 min", seconds: 180)
            durationButton(title: "5 min", seconds: 300)
            durationButton(title: "10 min", seconds: 600)
        }
    }

    private func durationButton(title: String, seconds: Int) -> some View {
        Button {
            selectedDuration = seconds
            defaultDuration = seconds
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .frame(width: 62)
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
        .opacity(selectedDuration == seconds ? 1.0 : 0.55)
    }

    private var quickSettings: some View {
        VStack(spacing: 10) {
            Toggle("Mostrar pantalla de limpieza", isOn: $showCleaningOverlay)
            Toggle("Atenuar pantalla durante limpieza", isOn: $dimScreenDuringCleaning)
            Toggle("Bloquear clicks del mouse/trackpad", isOn: $blockPointerClicks)
        }
        .toggleStyle(.switch)
        .font(.system(size: 13, weight: .medium, design: .rounded))
        .frame(maxWidth: 350)
        .padding(.top, 4)
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black.opacity(0.92),
                    Color(nsColor: .windowBackgroundColor),
                    Color.blue.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.blue.opacity(0.24))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: -230, y: -170)

            Circle()
                .fill(.purple.opacity(0.20))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: 240, y: 190)

            Circle()
                .fill(.cyan.opacity(0.12))
                .frame(width: 190, height: 190)
                .blur(radius: 55)
                .offset(x: 60, y: -250)
        }
        .ignoresSafeArea()
    }
}

private extension View {
    func glassCard() -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(.white.opacity(0.24), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.35), radius: 32, x: 0, y: 18)
    }
}

#Preview {
    ContentView()
        .environmentObject(KeyboardLockManager.shared)
}
