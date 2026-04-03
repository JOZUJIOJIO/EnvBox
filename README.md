# EnvBox

一个轻量的 macOS 菜单栏应用，帮你管理散落在 `.zshrc` 里的 API Key 和环境变量。

再也不用翻 `.zshrc` 找密钥了。打开就能看到所有环境变量，点几下就能添加、修改、删除。

## 功能

- **一键查看** — 点击菜单栏图标，所有环境变量一目了然
- **智能遮罩** — API Key 默认隐藏（`sk-••••••••de58`），鼠标悬停显示完整值；URL 和路径直接显示
- **快速添加** — 填写 Key 名称 + Key 值 + Base URL（选填），自动写入 `~/.zshrc`
- **编辑删除** — 修改或移除任意变量，保存后立即生效
- **搜索过滤** — 按变量名快速查找
- **一键复制** — 点击即可复制完整值到剪贴板
- **Skills 浏览** — 查看本机所有已安装的 Claude Code 技能
- **快捷键** — `Ctrl+Shift+E` 随时呼出

## 安装

需要 Xcode / Swift 6.0+，macOS 13+。

```bash
git clone https://github.com/JOZUJIOJIO/EnvBox.git
cd EnvBox
make install
```

运行后 `EnvBox.app` 会被安装到 `/Applications/`，菜单栏出现钥匙图标即可使用。

### 开发模式

```bash
swift build
.build/debug/EnvBox
```

## 工作原理

EnvBox 解析 `~/.zshrc` 中的 `export KEY="VALUE"` 行，读取所有环境变量并展示。添加或修改变量时，直接写回 `~/.zshrc` 并自动 source 生效。

- 跳过注释行（`# export ...`）
- 跳过 PATH 等系统变量
- 支持双引号、单引号、无引号三种格式
- 添加 API Key 时填写 Base URL，会自动创建对应的 `_BASE_URL` 变量（如 `OPENAI_API_KEY` + Base URL → 自动添加 `OPENAI_BASE_URL`）

Skills 浏览功能会扫描 `~/.claude/skills/`、`superpowers` 插件目录和 `~/SKILLS/`，读取每个 skill 的名称和描述。

## 技术栈

- Swift + SwiftUI + AppKit
- 零依赖
- ~500KB 应用体积
- 仅菜单栏驻留，无 Dock 图标

## 开源协议

MIT
