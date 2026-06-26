import Foundation
import Combine
import SwiftUI
import AppKit
import ApplicationServices
import CoreGraphics

enum UnlockShortcut: String, CaseIterable, Identifiable {
    case controlOptionCommandL = "controlOptionCommandL"
    case controlOptionCommandK = "controlOptionCommandK"
    case controlOptionCommandSpace = "controlOptionCommandSpace"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .controlOptionCommandL:
            return "Control + Option + Command + L"
        case .controlOptionCommandK:
            return "Control + Option + Command + K"
        case .controlOptionCommandSpace:
            return "Control + Option + Command + Espacio"
        }
    }

    var shortTitle: String {
        switch self {
        case .controlOptionCommandL:
            return "⌃⌥⌘L"
        case .controlOptionCommandK:
            return "⌃⌥⌘K"
        case .controlOptionCommandSpace:
            return "⌃⌥⌘Space"
        }
    }

    var keyCode: Int64 {
        switch self {
        case .controlOptionCommandL:
            return 37
        case .controlOptionCommandK:
            return 40
        case .controlOptionCommandSpace:
            return 49
        }
    }

    func matches(type: CGEventType, event: CGEvent) -> Bool {
        guard type == .keyDown else { return false }

        let pressedKeyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags

        let hasRequiredModifiers =
            flags.contains(.maskControl) &&
            flags.contains(.maskAlternate) &&
            flags.contains(.maskCommand)

        return pressedKeyCode == keyCode && hasRequiredModifiers
    }
}

final class KeyboardLockManager: ObservableObject {
    static let shared = KeyboardLockManager()

    @Published var isLocked: Bool = false
    @Published var hasAccessibilityPermission: Bool = false
    @Published var remainingSeconds: Int = 300
    @Published var statusMessage: String = "Listo para limpiar tu Mac."

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var timer: Timer?

    private let maxDuration = 900
    private let minDuration = 30

    private init() {
        UserDefaults.standard.register(defaults: [
            "defaultDuration": 300,
            "customDuration": 300,
            "unlockShortcut": UnlockShortcut.controlOptionCommandL.rawValue,
            "showCleaningOverlay": true,
            "dimScreenDuringCleaning": true,
            "blockPointerClicks": false,
            "playLockSounds": true
        ])

        refreshPermissionStatus()
    }

    func refreshPermissionStatus() {
        hasAccessibilityPermission = AXIsProcessTrusted()
    }

    func requestAccessibilityPermission() {
        let options = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ] as CFDictionary

        hasAccessibilityPermission = AXIsProcessTrustedWithOptions(options)

        if !hasAccessibilityPermission {
            statusMessage = "Activa Accesibilidad para CleanKeys en Configuración del Sistema."
        }
    }

    func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    func startLock(duration: Int? = nil) {
        refreshPermissionStatus()

        guard hasAccessibilityPermission else {
            requestAccessibilityPermission()
            return
        }

        guard !isLocked else { return }

        let preferredDuration = duration ?? UserDefaults.standard.integer(forKey: "defaultDuration")
        let safeDuration = min(max(preferredDuration, minDuration), maxDuration)

        remainingSeconds = safeDuration
        statusMessage = "Teclado bloqueado. Usa \(currentShortcut.shortTitle) para desbloquear."

        let eventMask =
            CGEventMask(1 << CGEventType.keyDown.rawValue) |
            CGEventMask(1 << CGEventType.keyUp.rawValue) |
            CGEventMask(1 << CGEventType.flagsChanged.rawValue)

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon else {
                return Unmanaged.passUnretained(event)
            }

            let manager = Unmanaged<KeyboardLockManager>
                .fromOpaque(refcon)
                .takeUnretainedValue()

            if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                if let eventTap = manager.eventTap {
                    CGEvent.tapEnable(tap: eventTap, enable: true)
                }
                return Unmanaged.passUnretained(event)
            }

            if manager.currentShortcut.matches(type: type, event: event) {
                DispatchQueue.main.async {
                    manager.stopLock(message: "Teclado desbloqueado.")
                }
                return nil
            }

            if type == .keyDown || type == .keyUp || type == .flagsChanged {
                return nil
            }

            return Unmanaged.passUnretained(event)
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            statusMessage = "No se pudo bloquear. Revisa permisos de Accesibilidad."
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        CGEvent.tapEnable(tap: tap, enable: true)

        isLocked = true

        if UserDefaults.standard.bool(forKey: "playLockSounds") {
            NSSound.beep()
        }

        if UserDefaults.standard.bool(forKey: "showCleaningOverlay") {
            CleaningOverlayWindowManager.shared.show(manager: self)
        }

        startTimer()
    }

    func stopLock(message: String = "Teclado desbloqueado.") {
        timer?.invalidate()
        timer = nil

        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
        }

        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil

        CleaningOverlayWindowManager.shared.hide()

        isLocked = false
        statusMessage = message

        if UserDefaults.standard.bool(forKey: "playLockSounds") {
            NSSound.beep()
        }
    }

    func updateOverlayPointerBehavior() {
        CleaningOverlayWindowManager.shared.updatePointerBehavior()
    }

    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }

            DispatchQueue.main.async {
                self.remainingSeconds -= 1

                if self.remainingSeconds <= 0 {
                    self.stopLock(message: "Tiempo terminado. Teclado desbloqueado.")
                }
            }
        }
    }

    var currentShortcut: UnlockShortcut {
        let rawValue = UserDefaults.standard.string(forKey: "unlockShortcut")
            ?? UnlockShortcut.controlOptionCommandL.rawValue

        return UnlockShortcut(rawValue: rawValue) ?? .controlOptionCommandL
    }

    func formattedRemainingTime() -> String {
        let safeSeconds = max(remainingSeconds, 0)
        let minutes = safeSeconds / 60
        let seconds = safeSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
