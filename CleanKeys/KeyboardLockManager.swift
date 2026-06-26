import Foundation
import Combine
import SwiftUI
import ApplicationServices
import CoreGraphics

final class KeyboardLockManager: ObservableObject {
    @Published var isLocked: Bool = false
    @Published var hasAccessibilityPermission: Bool = false
    @Published var remainingSeconds: Int = 300
    @Published var statusMessage: String = "Listo para limpiar tu Mac."

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var timer: Timer?

    private static let unlockKeyCode: Int64 = 37 // L

    init() {
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

    func startLock(duration: Int = 300) {
        refreshPermissionStatus()

        guard hasAccessibilityPermission else {
            requestAccessibilityPermission()
            return
        }

        guard !isLocked else { return }

        remainingSeconds = duration
        statusMessage = "Teclado bloqueado. Usa ⌃⌥⌘L para desbloquear."

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

            if manager.isUnlockShortcut(type: type, event: event) {
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
        isLocked = false
        statusMessage = message
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

    private func isUnlockShortcut(type: CGEventType, event: CGEvent) -> Bool {
        guard type == .keyDown else { return false }

        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags

        let hasRequiredModifiers =
            flags.contains(.maskControl) &&
            flags.contains(.maskAlternate) &&
            flags.contains(.maskCommand)

        return keyCode == Self.unlockKeyCode && hasRequiredModifiers
    }
}
