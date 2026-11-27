import Cocoa
import IOKit.pwr_mgt

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private var displayAssertion: IOPMAssertionID = 0
    private var systemAssertion: IOPMAssertionID = 0
    private var active = false
    private var timer: Timer?
    private var endDate: Date?
    private var tickTimer: Timer?

    private let toggleItem = NSMenuItem(title: "Activate", action: #selector(toggle), keyEquivalent: "")
    private let statusLine = NSMenuItem(title: "Mac can sleep", action: nil, keyEquivalent: "")
    private let durations: [(String, TimeInterval?)] = [
        ("Indefinitely", nil), ("15 minutes", 900), ("30 minutes", 1800),
        ("1 hour", 3600), ("2 hours", 7200), ("4 hours", 14400), ("8 hours", 28800),
    ]
    private var selectedDuration: TimeInterval? = nil

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Start near the right edge; otherwise macOS can park a new icon under the notch where it is hidden.
        let posKey = "NSStatusItem Preferred Position NoSleepStatusItem"
        if UserDefaults.standard.object(forKey: posKey) == nil { UserDefaults.standard.set(120.0, forKey: posKey) }
        statusItem.autosaveName = "NoSleepStatusItem"
        statusItem.isVisible = true
        let menu = NSMenu()
        statusLine.isEnabled = false
        menu.addItem(statusLine)
        menu.addItem(.separator())
        toggleItem.target = self
        menu.addItem(toggleItem)
        menu.addItem(.separator())

        let header = NSMenuItem(title: "Duration", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        for (i, d) in durations.enumerated() {
            let item = NSMenuItem(title: d.0, action: #selector(pickDuration(_:)), keyEquivalent: "")
            item.target = self
            item.tag = i
            item.state = i == 0 ? .on : .off
            menu.addItem(item)
        }
        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit NoSleep", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quit)
        statusItem.menu = menu
        updateUI()

        // Left click toggles would conflict with the menu; keep it menu-based.
        // Activate immediately on launch so opening the app = caffeinated.
        start()
    }

    func applicationWillTerminate(_ notification: Notification) { stop() }

    @objc private func toggle() { active ? stop() : start() }

    @objc private func pickDuration(_ sender: NSMenuItem) {
        selectedDuration = durations[sender.tag].1
        sender.menu?.items.forEach { if $0.action == #selector(pickDuration(_:)) { $0.state = $0.tag == sender.tag ? .on : .off } }
        if active { stop(); start() }
    }

    private func start() {
        let reason = "NoSleep: user requested no sleep" as CFString
        IOPMAssertionCreateWithName(kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
                                    IOPMAssertionLevel(kIOPMAssertionLevelOn), reason, &displayAssertion)
        IOPMAssertionCreateWithName(kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
                                    IOPMAssertionLevel(kIOPMAssertionLevelOn), reason, &systemAssertion)
        active = true
        if let d = selectedDuration {
            endDate = Date().addingTimeInterval(d)
            timer = Timer.scheduledTimer(withTimeInterval: d, repeats: false) { [weak self] _ in self?.stop() }
            tickTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in self?.updateUI() }
        } else {
            endDate = nil
        }
        updateUI()
    }

    private func stop() {
        if displayAssertion != 0 { IOPMAssertionRelease(displayAssertion); displayAssertion = 0 }
        if systemAssertion != 0 { IOPMAssertionRelease(systemAssertion); systemAssertion = 0 }
        timer?.invalidate(); timer = nil
        tickTimer?.invalidate(); tickTimer = nil
        endDate = nil
        active = false
        updateUI()
    }

    private func updateUI() {
        statusItem.button?.image = active ? Icons.awake : Icons.asleep
        toggleItem.title = active ? "Deactivate" : "Activate"
        if active {
            if let end = endDate {
                let mins = max(1, Int(ceil(end.timeIntervalSinceNow / 60)))
                statusLine.title = "Awake — \(mins) min remaining"
            } else {
                statusLine.title = "Awake — until deactivated"
            }
        } else {
            statusLine.title = "Mac can sleep"
        }
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)   // menu bar only, no Dock icon
let delegate = AppDelegate()
app.delegate = delegate
app.run()
