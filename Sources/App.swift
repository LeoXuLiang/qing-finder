import AppKit
import FinderSync

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?
    private var status: NSTextField?
    private var receivedRequest = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async { [self] in
            if !receivedRequest { showWindow() }
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        receivedRequest = true
        for url in urls {
            do { try perform(ToolRequest(url: url)) }
            catch { showError(error) }
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) { refreshStatus() }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showWindow()
        return true
    }

    private func perform(_ request: ToolRequest) throws {
        switch request.action {
        case .txt, .markdown, .folder:
            let created = try FileCreator.create(request.action, in: request.destination())
            NSWorkspace.shared.activateFileViewerSelecting([created])
        case .copyPath:
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(request.pathsToCopy.joined(separator: "\n"), forType: .string)
        case .terminal:
            let directory = try request.destination()
            guard let terminal = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal") else {
                throw NSError(domain: "轻右键", code: 1, userInfo: [NSLocalizedDescriptionKey: "没有找到系统终端 App。"])
            }
            NSWorkspace.shared.open([directory], withApplicationAt: terminal,
                                    configuration: NSWorkspace.OpenConfiguration()) { _, error in
                if let error { DispatchQueue.main.async { self.showError(error) } }
            }
        }
    }

    private func showWindow() {
        if let window { window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true); return }
        NSApp.setActivationPolicy(.regular)
        let appMenu = NSMenu()
        let top = NSMenuItem()
        appMenu.addItem(top)
        top.submenu = NSMenu()
        top.submenu?.addItem(withTitle: "退出轻右键", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        NSApp.mainMenu = appMenu

        let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 560, height: 500),
                           styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        win.title = "轻右键"
        win.isReleasedWhenClosed = false
        win.center()
        let root = NSStackView()
        root.orientation = .vertical
        root.alignment = .leading
        root.spacing = 18
        root.edgeInsets = NSEdgeInsets(top: 28, left: 32, bottom: 28, right: 32)
        root.translatesAutoresizingMaskIntoConstraints = false
        win.contentView?.addSubview(root)
        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: win.contentView!.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: win.contentView!.trailingAnchor),
            root.topAnchor.constraint(equalTo: win.contentView!.topAnchor),
            root.bottomAnchor.constraint(equalTo: win.contentView!.bottomAnchor)
        ])
        root.addArrangedSubview(label("轻右键", size: 30, weight: .bold))
        root.addArrangedSubview(label("你的文件夹，顺手一点。", size: 16, color: .secondaryLabelColor))
        let state = label("", size: 14, weight: .medium)
        status = state
        root.addArrangedSubview(state)
        let details = label("新建 TXT 文本 / Markdown 文档\n新建文件夹 · 自动编号，保留已有文件\n复制路径 · 多选时每行一条\n在终端打开 · 直接进入目标文件夹", size: 15)
        details.maximumNumberOfLines = 0
        root.addArrangedSubview(details)
        let tip = label("第一次使用：启用访达扩展，然后在文件夹空白处右键。\n右键文件夹时，新文档会建在该文件夹内。\n创建后已选中新文件，按 Return 可改名。", size: 13, color: .secondaryLabelColor)
        tip.maximumNumberOfLines = 0
        root.addArrangedSubview(tip)
        let buttons = NSStackView()
        buttons.spacing = 12
        let enable = NSButton(title: "启用访达扩展…", target: self, action: #selector(openSettings))
        enable.bezelStyle = .rounded
        enable.keyEquivalent = "\r"
        let demo = NSButton(title: "选择文件夹试用…", target: self, action: #selector(tryFolder))
        demo.bezelStyle = .rounded
        buttons.addArrangedSubview(enable)
        buttons.addArrangedSubview(demo)
        root.addArrangedSubview(buttons)
        root.addArrangedSubview(label("免费 · 本机运行 · 无账号 · 无网络请求", size: 12, color: .tertiaryLabelColor))
        self.window = win
        refreshStatus()
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func label(_ text: String, size: CGFloat, weight: NSFont.Weight = .regular,
                       color: NSColor = .labelColor) -> NSTextField {
        let field = NSTextField(wrappingLabelWithString: text)
        field.font = .systemFont(ofSize: size, weight: weight)
        field.textColor = color
        return field
    }

    private func refreshStatus() {
        let enabled = FIFinderSyncController.isExtensionEnabled
        status?.stringValue = enabled ? "● 访达扩展已启用" : "○ 访达扩展尚未启用"
        status?.textColor = enabled ? .systemGreen : .secondaryLabelColor
    }

    @objc private func openSettings() { FIFinderSyncController.showExtensionManagementInterface() }

    @objc private func tryFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "新建 TXT 测试文件"
        panel.message = "在所选文件夹创建一个空白 TXT，不覆盖已有文件。"
        guard panel.runModal() == .OK, let folder = panel.url else { return }
        do { try perform(ToolRequest(action: .txt, target: folder)) }
        catch { showError(error) }
    }

    private func showError(_ error: Error) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "轻右键未能完成操作"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.runModal()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.setActivationPolicy(.accessory)
app.delegate = delegate
app.run()
