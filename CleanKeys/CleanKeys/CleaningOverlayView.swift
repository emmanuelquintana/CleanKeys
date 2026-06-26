import SwiftUI

struct CleaningOverlayView: View {
    @EnvironmentObject private var keyboard: KeyboardLockManager

    @AppStorage("dimScreenDuringCleaning") private var dimScreenDuringCleaning: Bool = true
    @AppStorage("blockPointerClicks") private var blockPointerClicks: Bool = false

    var body: some View {
        ZStack {
            Color.black
                .opacity(dimScreenDuringCleaning ? 0.42 : 0.10)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 118, height: 118)
                        .overlay {
                            Circle()
                                .stroke(.white.opacity(0.25), lineWidth: 1)
                        }

                    Image(systemName: "sparkles")
                        .font(.system(size: 46, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(spacing: 10) {
                    Text("Modo limpieza activo")
                        .font(.system(size: 48, weight: .bold, design: .rounded))

                    Text("Teclado bloqueado")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Text(keyboard.formattedRemainingTime())
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .monospacedDigit()

                VStack(spacing: 8) {
                    Text("Desbloqueo: \(keyboard.currentShortcut.shortTitle)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))

                    Text(blockPointerClicks ? "Clicks del mouse/trackpad bloqueados por la pantalla" : "Mouse/trackpad siguen activos")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(56)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 42, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 42, style: .continuous)
                    .stroke(.white.opacity(0.24), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.45), radius: 40, x: 0, y: 22)
        }
    }
}
