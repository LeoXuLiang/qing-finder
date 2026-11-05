# 分发与兼容性

## 首发版本

- 版本：0.1.0，公开测试版。
- 架构：arm64（Apple Silicon），不包含 Intel 二进制。
- 编译最低目标：macOS 14；仅在 macOS 27.0.1 完成实际访达界面验收。
- 下载包：`QingFinder-0.1.0-arm64.zip`；同一 Release 的 `SHA256SUMS.txt` 提供校验值。
- 签名：ad-hoc 本机签名，未使用 Developer ID、未公证、未上架 Mac App Store。GitHub 发布不等于 Apple 审核通过。

其他 Mac 下载后可能被 Gatekeeper 拦截，不能承诺解压即用。当前可选择下载源码并运行 `python3 scripts/build.py` 在本机构建；本机编译也不代表获得 Apple 审核或公证。安全机制说明见 [Apple 官方文档](https://support.apple.com/zh-cn/102445)。后续公证版需要有效的 Developer ID 签名，见 [Apple 公证说明](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)。

## 文件与隐私

- 不创建账号、不发起网络请求，不包含分析统计或广告 SDK。
- Finder Sync 扩展注册根目录 `/` 以提供菜单覆盖，不递归扫描、不读取文件内容、不设置徽标。
- 扩展保留 App Sandbox；通过本地 URL 协议把用户所选的操作和路径传给主程序。
- 主程序未启用 App Sandbox，按用户菜单操作创建空白文档/目录、复制路径或打开终端，遵循系统权限和隐私授权。
- 不申请完全磁盘访问或辅助功能权限。受保护目录、只读目录、“最近使用”、搜索结果、废纸篓等场景不保证可用。
- 新建使用排他创建，遇到已有文件或符号链接会换用编号名称，不覆盖内容。
- 多选复制按行输出；多选新建及终端操作只取第一项。第一项是目录时进入目录内部，否则取其父目录。

## 实测范围

核心测试 13 项通过：自动编号、已有内容保持、空白文档、特殊字符路径往返、选中目录/文件的目标定位、多选路径顺序、已有符号链接保护和无效请求拒绝等。

本机真实访达验收覆盖空白处菜单、新建 TXT/Markdown/文件夹、右键目录内创建、重复创建、工具栏入口和复制路径；在文本编辑实际粘贴核对多选结果，终端新 shell 的 cwd 与目标文件夹相符。最终菜单布局为五项第一层入口。

尚未完成跨设备、其他 macOS 版本、Intel、云盘、外置盘及首次下载隔离状态的安装测试。首页“选择文件夹试用…”只验证过原生面板打开，创建行为已由右键菜单验收。

## 实现依据

使用 Apple 公共 AppKit / Finder Sync API，不注入 Finder。Apple 将 Finder Sync 主要定位于同步应用的访达交互，故本项目不承诺 Mac App Store 审核适用性，见 [Finder Sync 指南](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Finder.html)。
