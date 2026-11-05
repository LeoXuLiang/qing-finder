# 轻右键 · QingFinder

一个免费、开源的 Mac 访达右键小工具。常用操作直接放在右键菜单第一层，无账号、无订阅，应用不发起网络请求。

## 五个简单功能

| 功能 | 用途 |
| --- | --- |
| 新建 TXT | 在当前文件夹创建空白文本 |
| 新建 Markdown | 创建空白 `.md` 文档 |
| 新建文件夹 | 同名时自动编号，保留已有项目 |
| 复制路径 | 复制文件或文件夹路径；多选时每行一条 |
| 在终端打开 | 打开终端并进入目标文件夹 |

新建文档也会自动编号；创建后在访达选中，按 **Return** 即可改名。右键文件夹时在该文件夹内部创建，右键文件时在其所在目录创建；多选新建/终端操作以第一项为准。

## 下载与安装

**[下载 Mac 测试版](https://github.com/LeoXuLiang/qing-finder/releases/tag/v0.1.0)** · [直接下载 Apple Silicon 安装包](https://github.com/LeoXuLiang/qing-finder/releases/download/v0.1.0/QingFinder-0.1.0-arm64.zip)

1. 下载并解压，将“轻右键.app”拖入“应用程序”。
2. 打开轻右键，点“启用访达扩展…”，在系统设置中启用“轻右键”。
3. 在普通文件夹的空白处右键即可使用。首页关闭后仍可使用右键功能。

首发为 **Apple Silicon / macOS 14+ 测试版**，目前仅在 macOS 27.0.1 实测。Intel、其他系统版本、云盘和外置盘尚未验证。

**当前下载包采用 ad-hoc 签名，未做 Apple Developer ID 签名和公证，其他 Mac 可能被系统阻止打开。** 如遇安装阻拦，可按下方说明在本机从源码构建。安装情况与已知限制见 [分发说明](docs/DISTRIBUTION.md)。

## 从源码构建

安装 Apple Command Line Tools 后，在 Apple Silicon Mac 上运行：

```sh
python3 scripts/build.py
zsh scripts/test.sh
```

生成 `build/轻右键.app` 和 `build/QingFinder-0.1.0-arm64.zip`。编译只使用系统 AppKit、FinderSync 和 Foundation，无第三方库。构建脚本使用本机签名。

## 卸载

在系统设置中关闭“轻右键”访达扩展，退出应用，将“轻右键.app”移到废纸篓。已经创建的文档会保留。

## 开源

[MIT License](LICENSE)，允许使用、修改和再分发，详见许可证。问题或建议可提交 [Issue](https://github.com/LeoXuLiang/qing-finder/issues)。
