# AIVault

一个轻量的 macOS 菜单栏应用，管理你的 AI 核心资产：API Key 和 Skills。

再也不用翻 `.zshrc` 找密钥了。打开就能看到所有环境变量和已安装的技能，点几下就能添加、修改、删除。

## 功能

### API Keys
- **一键查看** — 点击菜单栏图标，所有环境变量一目了然
- **智能遮罩** — API Key 默认隐藏（`sk-••••••••de58`），鼠标悬停显示完整值；URL 和路径直接显示
- **快速添加** — 填写 Key 名称 + Key 值 + Base URL（选填），自动写入 `~/.zshrc`
- **编辑删除** — 修改或移除任意变量，保存后立即生效
- **搜索过滤** — 按变量名快速查找
- **一键复制** — 点击即可复制完整值到剪贴板

### Skills
- **技能浏览** — 查看本机所有已安装的 Claude Code 技能，中文描述
- **快速预览** — 双击任意技能，直接打开 SKILL.md 文档
- **多来源扫描** — 自动扫描 `~/.claude/skills/`、superpowers 插件目录和 `~/SKILLS/`

### 通用
- **快捷键** — `Ctrl+Shift+E` 随时呼出
- **Tab 切换** — 顶部标签页在 API Keys 和 Skills 之间切换

## 安装

### 直接下载（推荐）

前往 [Releases](https://github.com/JOZUJIOJIO/EnvBox/releases) 下载最新版 `AIVault.app`，解压后拖到「应用程序」文件夹即可。

> 首次打开如果提示「无法验证开发者」，右键点击 app → 选择「打开」即可。

### 从源码编译

需要 Xcode / Swift 6.0+，macOS 13+。

```bash
git clone https://github.com/JOZUJIOJIO/EnvBox.git
cd EnvBox
make install
```

## 工作原理

**API Keys** — 解析 `~/.zshrc` 中的 `export KEY="VALUE"` 行。添加或修改变量时，直接写回 `~/.zshrc` 并自动 source 生效。

**Skills** — 扫描本地 skill 目录，读取每个 SKILL.md 的 YAML frontmatter（name + description），内置中文翻译。

## 技术栈

- Swift + SwiftUI + AppKit
- 零依赖，纯本地，不联网
- ~500KB 应用体积
- 仅菜单栏驻留，无 Dock 图标
- 支持 Intel 和 Apple Silicon

## 开源协议

MIT
