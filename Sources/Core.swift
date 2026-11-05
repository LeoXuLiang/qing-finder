import Foundation
import Darwin

enum ToolAction: String, CaseIterable {
    case txt, markdown, folder, copyPath, terminal
    var title: String {
        switch self {
        case .txt: return "新建 TXT 文本"
        case .markdown: return "新建 Markdown 文档"
        case .folder: return "新建文件夹"
        case .copyPath: return "复制路径"
        case .terminal: return "在终端打开"
        }
    }
    var symbol: String {
        switch self {
        case .txt: return "doc.badge.plus"
        case .markdown: return "text.document"
        case .folder: return "folder.badge.plus"
        case .copyPath: return "link"
        case .terminal: return "terminal"
        }
    }
}

struct ToolRequest {
    static let scheme = "liang-finder"
    let action: ToolAction
    let target: URL
    let items: [URL]
    let background: Bool

    var url: URL {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = "perform"
        components.queryItems = [
            URLQueryItem(name: "action", value: action.rawValue),
            URLQueryItem(name: "target", value: target.path),
            URLQueryItem(name: "background", value: background ? "1" : "0")
        ] + items.map { URLQueryItem(name: "item", value: $0.path) }
        return components.url!
    }

    init(action: ToolAction, target: URL, items: [URL] = [], background: Bool = true) {
        self.action = action
        self.target = target
        self.items = items
        self.background = background
    }

    init(url: URL) throws {
        guard let c = URLComponents(url: url, resolvingAgainstBaseURL: false),
              c.scheme == Self.scheme, c.host == "perform" else { throw ToolError.invalidRequest }
        let query = c.queryItems ?? []
        func one(_ name: String) -> String? {
            let matches = query.filter { $0.name == name }
            return matches.count == 1 ? matches.first?.value : nil
        }
        guard let value = one("action"), let action = ToolAction(rawValue: value),
              let target = one("target"), Self.validPath(target),
              let bg = one("background"), ["0", "1"].contains(bg) else { throw ToolError.invalidRequest }
        let paths = query.filter { $0.name == "item" }.compactMap(\.value)
        guard paths.count <= 1000, paths.allSatisfy(Self.validPath) else { throw ToolError.invalidRequest }
        self.init(action: action, target: URL(fileURLWithPath: target),
                  items: paths.map { URL(fileURLWithPath: $0) }, background: bg == "1")
    }

    private static func validPath(_ path: String) -> Bool {
        path.hasPrefix("/") && !path.contains("\0")
    }

    func destination() throws -> URL {
        let candidate = background ? target : (items.first ?? target)
        var directory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: candidate.path, isDirectory: &directory) else {
            throw ToolError.missingTarget
        }
        if background && !directory.boolValue { throw ToolError.missingTarget }
        return directory.boolValue ? candidate : candidate.deletingLastPathComponent()
    }

    var pathsToCopy: [String] { (background || items.isEmpty ? [target] : items).map(\.path) }
}

enum ToolError: LocalizedError {
    case invalidRequest, missingTarget, tooManyNames
    var errorDescription: String? {
        switch self {
        case .invalidRequest: return "操作请求无效，请从访达右键菜单重新选择。"
        case .missingTarget: return "目标文件夹不存在或无法访问，请在普通文件夹中重试。"
        case .tooManyNames: return "同名文件太多，请整理后重试。"
        }
    }
}

enum FileCreator {
    /// O_EXCL / mkdir makes creation atomic, including when another process creates a name concurrently.
    static func create(_ action: ToolAction, in directory: URL) throws -> URL {
        let base: String
        let suffix: String
        switch action {
        case .txt: (base, suffix) = ("新建文本", ".txt")
        case .markdown: (base, suffix) = ("新建文档", ".md")
        case .folder: (base, suffix) = ("新建文件夹", "")
        default: throw ToolError.invalidRequest
        }
        for number in 1...10000 {
            let name = base + (number == 1 ? "" : " \(number)") + suffix
            let result = directory.appendingPathComponent(name, isDirectory: action == .folder)
            let code: Int32
            if action == .folder {
                code = mkdir(result.path, 0o755)
            } else {
                let fd = Darwin.open(result.path, O_WRONLY | O_CREAT | O_EXCL, 0o644)
                if fd >= 0 { Darwin.close(fd); return result }
                code = -1
            }
            if code == 0 { return result }
            let error = errno
            if error != EEXIST { throw NSError(domain: NSPOSIXErrorDomain, code: Int(error)) }
        }
        throw ToolError.tooManyNames
    }
}
