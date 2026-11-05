import AppKit
import FinderSync
import OSLog

@objc(FinderExtension)
final class FinderExtension: FIFinderSync {
    private var requests: [Int: URL] = [:]
    private var nextTag = 0
    private let logger = Logger(subsystem: "local.qingfinder", category: "menu")
    override init() {
        super.init()
        // Registers menu coverage only. No recursive scan, badges, or file-content monitoring.
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/", isDirectory: true)]
    }

    override var toolbarItemName: String { "轻右键" }
    override var toolbarItemToolTip: String { "新建文档、复制路径、在终端打开" }
    override var toolbarItemImage: NSImage {
        NSImage(systemSymbolName: "cursorarrow.click.2", accessibilityDescription: "轻右键")!
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        let controller = FIFinderSyncController.default()
        guard let target = controller.targetedURL(), target.isFileURL else { return nil }
        let selected = controller.selectedItemURLs() ?? []
        let background = menuKind == .contextualMenuForContainer || menuKind == .toolbarItemMenu
        let menu = NSMenu(title: "轻右键")
        for action in ToolAction.allCases {
            menu.addItem(item(action, target: target, selected: selected, background: background))
        }
        return menu
    }

    private func item(_ action: ToolAction, target: URL, selected: [URL], background: Bool) -> NSMenuItem {
        let title = action.title + " · 轻右键"
        let item = NSMenuItem(title: title, action: #selector(performTool(_:)), keyEquivalent: "")
        item.target = self
        item.image = NSImage(systemSymbolName: action.symbol, accessibilityDescription: nil)
        // Finder transfers tags across the extension boundary; arbitrary represented objects may be dropped.
        nextTag += 1
        item.tag = nextTag
        requests[nextTag] = ToolRequest(action: action, target: target, items: selected, background: background).url
        requests.removeValue(forKey: nextTag - 200)
        return item
    }

    @objc private func performTool(_ item: NSMenuItem) {
        guard let url = requests[item.tag] else {
            logger.error("Menu command has no matching request")
            return
        }
        // File changes happen in the containing app; this extension stays sandboxed.
        let sent = NSWorkspace.shared.open(url)
        logger.notice("Menu request dispatched: \(sent)")
    }
}
