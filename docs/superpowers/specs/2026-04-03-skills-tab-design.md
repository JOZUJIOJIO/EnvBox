# EnvBox Skills Tab — 设计文档

## 概述

在现有 EnvBox 菜单栏应用中新增「Skills」Tab，展示本机所有已安装的 Claude Code skill。与 API Keys tab 通过顶部标签页切换。

## 需求

1. **顶部 Tab** — 「API Keys」和「Skills」两个标签页，点击切换
2. **Skill 列表** — 显示 skill 名称 + 一句话描述
3. **搜索** — 按 skill 名称过滤
4. **数据来源** — 扫描三个目录下的 SKILL.md 文件，解析 YAML frontmatter 中的 `name` 和 `description`

## 数据来源

三个 skill 目录：

| 目录 | 内容 |
|------|------|
| `~/.claude/skills/` | 用户安装的 skill（社区 + 自建） |
| `~/.claude/plugins/cache/claude-plugins-official/superpowers/*/skills/` | 官方 superpowers skill |
| `~/SKILLS/` | 个人自定义 skill |

每个 skill 是一个文件夹，包含 `SKILL.md`，文件开头是 YAML frontmatter：

```yaml
---
name: skill-name
description: "一句话描述"
---
```

## 技术方案

### 新增文件

- `Sources/Models/Skill.swift` — Skill 数据模型（name, description, source）
- `Sources/Services/SkillService.swift` — 扫描目录、解析 YAML frontmatter
- `Sources/Views/SkillListView.swift` — Skill 列表界面

### 修改文件

- `Sources/Views/ContentView.swift` — 在顶层加 Tab 切换（API Keys / Skills），Tab 之下再接各自的 list/add/edit 导航

### Skill 数据模型

```
Skill
├── name: String          // 从 frontmatter 的 name 字段读取
├── description: String   // 从 frontmatter 的 description 字段读取
└── source: String        // 来源标识："user" / "superpowers" / "custom"
```

### YAML Frontmatter 解析

简单的字符串解析：
1. 找到第一个 `---` 和第二个 `---` 之间的内容
2. 逐行匹配 `name:` 和 `description:` 前缀
3. 去掉引号和多余空格

不引入 YAML 解析库，手写即可（frontmatter 结构简单固定）。

### SkillListView 界面

- 顶部：搜索框 + skill 数量
- 列表：每行显示 skill 名称（加粗）+ 描述（灰色副文本）
- 底部：显示数据来源路径
- 支持按名称搜索过滤

### ContentView 导航结构变化

```
ContentView
├── Tab: API Keys
│   ├── EnvListView (列表)
│   ├── AddEnvView (添加)
│   └── EditEnvView (编辑)
└── Tab: Skills
    └── SkillListView (只读列表)
```

Tab 选择用 `@State` enum（`.apiKeys` / `.skills`）控制。Tab 切换时保持各自的状态。

## 不做的事

- 不编辑/删除 skill（只读浏览）
- 不展示 SKILL.md 的完整内容
- 不解析 `allowed-tools`、`version` 等可选字段
- 不递归扫描嵌套 skill（只看一级子目录）

## 边界情况

- SKILL.md 不存在或 frontmatter 格式异常：跳过该 skill
- 目录不存在：跳过该数据源
- 重名 skill（不同来源同名）：都显示，用 source 标识区分
- description 字段使用 `>` 或 `|` 多行语法：取第一行
