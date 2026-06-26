import SwiftUI

struct ContentView: View {
    @StateObject private var keyboard = KeyboardLockManager()
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
                        .frame(maxWidth: 380)
                }

                if keyboard.isLocked {
                    Text(formatTime(keyboard.remainingSeconds))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
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
                        .frame(width: 170)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button {
                        keyboard.requestAccessibilityPermission()
                    } label: {
                        Label("Permisos", systemImage: "hand.raised.fill")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Text("Atajo de desbloqueo: Control + Option + Command + L")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .padding(36)
            .frame(width: 520, height: 430)
            .glassCard()
        }
        .frame(width: 680, height: 520)
        .onAppear {
            keyboard.refreshPermissionStatus()
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
            durationButton(title: "1 min", seconds: 60)
            durationButton(title: "5 min", seconds: 300)
            durationButton(title: "10 min", seconds: 600)
        }
    }

    private func durationButton(title: String, seconds: Int) -> some View {
        Button {
            selectedDuration = seconds
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .frame(width: 68)
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
        .opacity(selectedDuration == seconds ? 1.0 : 0.55)
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
                .offset(x: -210, y: -150)

            Circle()
                .fill(.purple.opacity(0.20))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 220, y: 160)

            Circle()
                .fill(.cyan.opacity(0.12))
                .frame(width: 180, height: 180)
                .blur(radius: 55)
                .offset(x: 40, y: -210)
        }
        .ignoresSafeArea()
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = max(seconds, 0) / 60
        let secs = max(seconds, 0) % 60
        return String(format: "%02d:%02d", minutes, secs)
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
}
