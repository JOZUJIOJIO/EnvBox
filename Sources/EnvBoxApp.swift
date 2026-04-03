import SwiftUI
import AppKit

@main
struct AIVaultApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)

        popover = NSPopover()
        popover.contentSize = NSSize(width: 420, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "key.fill", accessibilityDescription: "AIVault")
            button.action = #selector(togglePopover)
            button.target = self
        }

        setupHotKey()
    }

    private func setupHotKey() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Ctrl+Shift+E to toggle
            if event.modifierFlags.contains([.control, .shift]) && event.keyCode == 14 { // 14 = E
                DispatchQueue.main.async {
                    self?.togglePopover()
                }
            }
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
