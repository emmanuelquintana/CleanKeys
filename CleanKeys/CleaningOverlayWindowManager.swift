import SwiftUI
import AppKit

final class CleaningOverlayWindowManager {
    static let shared = CleaningOverlayWindowManager()

    private var windows: [NSWindow] = []

    private init() {}

    func show(manager: KeyboardLockManager) {
        hide()

        for screen in NSScreen.screens {
            let window = NSPanel(
                contentRect: screen.frame,
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )

            window.level = .screenSaver
            window.collectionBehavior = [
                .canJoinAllSpaces,
                .fullScreenAuxiliary,
                .stationary
            ]

            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.isReleasedWhenClosed = false

            let rootView = CleaningOverlayView()
                .environmentObject(manager)

            window.contentView = NSHostingView(rootView: rootView)
            window.ignoresMouseEvents = !UserDefaults.standard.bool(forKey: "blockPointerClicks")
            window.orderFrontRegardless()

            windows.append(window)
        }
    }

    func updatePointerBehavior() {
        let shouldBlockPointerClicks = UserDefaults.standard.bool(forKey: "blockPointerClicks")

        for window in windows {
            window.ignoresMouseEvents = !shouldBlockPointerClicks
        }
    }

    func hide() {
        for window in windows {
            window.orderOut(nil)
            window.close()
        }

        windows.removeAll()
    }
}
