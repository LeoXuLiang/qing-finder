import Foundation

let fm = FileManager.default
let root = fm.temporaryDirectory.appendingPathComponent("qingfinder-tests-\(UUID().uuidString)", isDirectory: true)
try fm.createDirectory(at: root, withIntermediateDirectories: true)
defer { try? fm.removeItem(at: root) }
var passed = 0
func check(_ condition: @autoclosure () throws -> Bool, _ name: String) throws {
    guard try condition() else { fatalError("FAIL: \(name)") }
    passed += 1
    print("PASS: \(name)")
}

let first = try FileCreator.create(.txt, in: root)
try Data("已有内容".utf8).write(to: first)
let second = try FileCreator.create(.txt, in: root)
try check(first.lastPathComponent == "新建文本.txt" && second.lastPathComponent == "新建文本 2.txt", "同名自动编号")
try check(String(contentsOf: first, encoding: .utf8) == "已有内容", "已有内容保持原样")
try check(Data(contentsOf: second).isEmpty, "TXT 是空白文件")
let markdown = try FileCreator.create(.markdown, in: root)
try check(markdown.pathExtension == "md" && Data(contentsOf: markdown).isEmpty, "Markdown 是真实空白文件")
let folder = try FileCreator.create(.folder, in: root)
let folder2 = try FileCreator.create(.folder, in: root)
try check(folder2.lastPathComponent == "新建文件夹 2", "文件夹自动编号")
let unusual = root.appendingPathComponent("中文 空格 & ? # % ' \" $(echo never)", isDirectory: true)
try fm.createDirectory(at: unusual, withIntermediateDirectories: false)
let request = ToolRequest(action: .txt, target: unusual)
let roundtrip = try ToolRequest(url: request.url)
try check(roundtrip.target.path == unusual.path, "特殊字符路径 URL 往返，无 Shell 插值")
try check(try roundtrip.destination() == unusual, "空白处创建定位当前文件夹")
let selected = ToolRequest(action: .txt, target: root, items: [folder], background: false)
try check(try selected.destination() == folder, "右键文件夹在其内部创建")
let fileSelected = ToolRequest(action: .txt, target: root, items: [first], background: false)
try check(try fileSelected.destination() == root, "右键文件在其同级创建")
let multiple = ToolRequest(action: .copyPath, target: root, items: [first, second], background: false)
try check(multiple.pathsToCopy == [first.path, second.path], "多选复制路径保持顺序")
let link = root.appendingPathComponent("新建文档 2.md")
try fm.createSymbolicLink(at: link, withDestinationURL: first)
let afterLink = try FileCreator.create(.markdown, in: root)
try check(afterLink.lastPathComponent == "新建文档 3.md", "已有符号链接不被覆盖")
var rejected = 0
for raw in ["liang-finder://perform?action=delete&target=/tmp&background=1",
            "liang-finder://perform?action=txt&target=relative&background=1",
            "liang-finder://perform?action=txt&action=folder&target=/tmp&background=1",
            "https://perform?action=txt&target=/tmp&background=1"] {
    do { _ = try ToolRequest(url: URL(string: raw)! ) } catch { rejected += 1 }
}
try check(rejected == 4, "拒绝未知操作、相对路径、重复参数、外部协议")
do {
    _ = try FileCreator.create(.txt, in: root.appendingPathComponent("missing"))
    fatalError("missing parent should fail")
} catch { passed += 1; print("PASS: 无效目录返回错误") }
print("\(passed) checks passed")
