// Sources/Services/SkillTranslations.swift
import Foundation

/// Built-in Chinese translations for known skill descriptions.
/// Falls back to original description if no translation exists.
enum SkillTranslations {
    static let zhCN: [String: String] = [
        // User-installed skills
        "bazaar": "GitHub 原生 AI 技能市场，发现、安装、混编和发布 Claude Code 技能",
        "benchmark": "性能回归检测，建立页面加载时间和 Core Web Vitals 基线，PR 前后对比",
        "browse": "快速无头浏览器，用于 QA 测试和网站体验验证，支持截图、表单测试、响应式检查",
        "canary": "部署后金丝雀监控，监控线上应用的控制台错误、性能回退和页面故障",
        "careful": "危险命令安全护栏，在执行 rm -rf、DROP TABLE、force-push 等操作前发出警告",
        "codex": "OpenAI Codex CLI 封装，支持代码审查、对抗模式和咨询三种模式",
        "design-consultation": "设计咨询，研究产品领域并提出完整的设计系统方案（美学、排版、配色、布局）",
        "design-review": "设计审查 QA，发现视觉不一致、间距问题、层级问题并自动修复",
        "doc-coauthoring": "结构化文档协作工作流，适用于撰写文档、提案、技术规格等",
        "document-release": "发布后文档更新，自动对照 diff 更新 README/CHANGELOG 等文档",
        "dreamina-cli": "通过 dreamina CLI 调用即梦进行 AI 图像或视频生成",
        "freeze": "限制文件编辑范围到指定目录，防止意外修改其他代码",
        "gstack": "快速无头浏览器，用于 QA 测试和网站体验验证",
        "gstack-upgrade": "升级 gstack 到最新版本",
        "guard": "完整安全模式：危险命令警告 + 目录范围编辑锁定",
        "internal-comms": "内部沟通模板，帮助撰写状态报告、领导层更新、公司通讯等",
        "investigate": "系统化调试，四个阶段：调查、分析、假设、实施。铁律：找到根因才能修复",
        "land-and-deploy": "合并部署工作流，合并 PR 后等待 CI 和部署，验证生产环境健康",
        "notion-knowledge-capture": "将对话和决策捕获为结构化 Notion 页面",
        "office-hours": "YC 办公时间模式，通过六个核心问题暴露需求真相",
        "plan-ceo-review": "CEO 视角方案评审，重新思考问题，寻找十星产品",
        "plan-design-review": "设计师视角方案评审，为每个设计维度打分 0-10 并给出改进建议",
        "plan-eng-review": "工程经理视角方案评审，锁定架构、数据流、边界情况和测试覆盖",
        "qa": "系统化 QA 测试 Web 应用并自动修复发现的 Bug",
        "qa-only": "仅报告模式的 QA 测试，生成结构化报告但不修复任何问题",
        "retro": "每周工程复盘，分析提交历史、工作模式和代码质量指标",
        "review": "PR 预合并审查，分析 diff 中的 SQL 安全、LLM 信任边界等问题",
        "screenshot": "截取桌面或窗口截图",
        "setup-browser-cookies": "从真实浏览器导入 Cookie 到无头浏览器会话",
        "setup-deploy": "配置部署设置，检测部署平台和生产 URL",
        "ship": "发布工作流：合并基础分支、运行测试、审查 diff、更新版本号、创建 PR",
        "tech-product-launch": "赛博奢华风格的科技产品发布幻灯片设计",
        "theme-factory": "主题样式工具包，为幻灯片、文档、网页等应用预设或自定义主题",
        "transcribe": "音频转文字，支持说话人分离和已知说话人提示",
        "unfreeze": "解除 /freeze 设置的编辑范围限制",
        // Superpowers skills
        "brainstorming": "创意头脑风暴，在动手写代码前探索用户意图、需求和设计方案",
        "dispatching-parallel-agents": "并行代理调度，用于处理两个以上互不依赖的任务",
        "executing-plans": "按步骤执行实现计划，带审查检查点",
        "finishing-a-development-branch": "开发分支收尾，引导选择合并、PR 或清理方式",
        "receiving-code-review": "接收代码审查反馈，在实施建议前进行技术验证",
        "requesting-code-review": "请求代码审查，在完成任务或合并前验证工作质量",
        "subagent-driven-development": "子代理驱动开发，为每个任务派遣独立代理执行",
        "systematic-debugging": "系统化调试，在提出修复方案前先定位根因",
        "test-driven-development": "测试驱动开发（TDD），在写实现代码前先写测试",
        "using-git-worktrees": "使用 Git Worktree 创建隔离的工作空间",
        "using-superpowers": "技能系统入口，确保在任何操作前检查可用技能",
        "verification-before-completion": "完成前验证，在声明工作完成前运行验证命令确认",
        "writing-plans": "编写实现计划，将需求拆解为分步骤的详细任务",
        "writing-skills": "创建或编辑技能文件，并在部署前验证",
    ]

    /// Return Chinese translation if available, otherwise return original description.
    static func translate(name: String, original: String) -> String {
        if let translated = zhCN[name], !translated.isEmpty {
            return translated
        }
        return original
    }
}
