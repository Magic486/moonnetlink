# 项目竞争分析

依据：2026-10-14 的 Mooncakes 全量索引、逐词搜索、GitHub 调研和官方 API。两个调研文档已完成，之后才进行本表和选题。

所有分数为 0–5 的架构判断，**不是统计概率或官方评审评分**。已有竞争与实现难度越高越不利；缺口、展示效果、获奖潜力越高越有利。获奖潜力仅表示在本轮候选中的相对竞争力。

| 项目 | 已有竞争 | MoonBit缺口 | 实现难度 | 展示效果 | 获奖概率（潜力分） | 处理 |
|---|---:|---:|---:|---:|---:|---|
| Agent / RAG / Prompt Framework | 5 | 1 | 4 | 4 | 1 | 否决：已有成熟直接竞争 |
| MCP SDK / Inspector | 5 | 0 | 3 | 4 | 1 | 否决：多个 SDK 与 CLI 已存在 |
| 可恢复工作流引擎 | 5 | 1 | 4 | 4 | 1 | 否决：官方 workflow 与社区引擎 |
| AI Evaluation Framework | 4 | 2 | 4 | 4 | 2 | 不选：agentcheck 和官方 eval 已覆盖主要用途 |
| 图像处理 / 可视化通用库 | 5 | 1 | 4 | 5 | 1 | 否决：pixelforge、图表和布局已存在 |
| 浏览器 / 前端 WASM 框架 | 5 | 1 | 5 | 5 | 1 | 否决：rabbita、luna、proton 等 |
| Linux 最小权限沙箱 | 5 | 0 | 5 | 5 | 1 | 否决：matrix486/moonjail 已发布 |
| Linux io_uring 类型化运行时 | 1 | 5 | 5 | 3 | 4 | 保留为未来方向，本期不选 |
| Linux Netlink 观察与重放基础设施 | 1 | 5 | 4 | 5 | 4 | **唯一选中** |

## 五问逐项回答

| 候选 | Mooncakes 是否有类似项目 | GitHub 是否有类似项目 | 如已有，独立存在理由 | 是否生态新增能力 | 赛事宗旨 |
|---|---|---|---|---|---|
| Agent/RAG/Prompt | weopqrst/agent、colmugx/posoco 等 | OpenSeek、MoonBit LangChain 核心 | 本提议无充分新增贡献，故否决 | 泛化重做不是 | 只有实质新增才符合 |
| MCP | marianoguerra/mcp、colmugx/mcp 等 | mcp-mb、moonbit_mcp | 无充分理由，故否决 | 不是 | 重复建设不符合 |
| Workflow | moonbitlang/workflow、bobzhang/workflow | 官方 workflow、workgraph | 无充分理由，故否决 | 泛化重做不是 | 重复建设不符合 |
| AI Eval | moonagentcheck、moondeteval | 官方 openseek/eval | 需证明新指标/真实宿主能力，本期未选 | 可有细分新增 | 需实测才能成立 |
| 图像/可视化 | pixelforge、mooncharts 等 | 对应仓库均存在 | 基础滤镜/绘图没有理由重造 | 不是 | 重复建设不符合 |
| WASM 前端 | rabbita、luna、框架绑定 | 官方与社区框架 | 缺乏具体差异，否决 | 不是 | 重复建设不符合 |
| Linux sandbox | matrix486/moonjail、内存 sandbox | moonjail、sandbox.mbt | 直接重做被禁止 | 不是 | 重复建设不符合 |
| io_uring | 本轮精确元数据未发现 | 本轮未找到直接实现；部分 API 限流 | 官方 async 是相邻能力；可贡献 completion runtime | 可能是 | 符合，但实现与展示风险高 |
| Netlink | 2,996 条精确检索无直接项目 | 仓库搜索 netlink/rtnetlink moonbit 为 0；公开 socket API 无对应接口 | async、libbpf 是相邻能力；本项目补充 kernel control/event plane | **本轮证据支持新增** | 协议库、CLI、可复用系统组件符合 |

## 最终决策

选择 **MoonNetlink**，Linux 优先。优先级严格为生态缺口 > 创新性 > Demo效果 > 开发难度。不是因为写一个 CLI 容易，而是 MoonBit 尚缺一层可复用的 Linux 内核网络对象协议和可验证状态能力。

实现不是 `ip` 命令输出包装，不移植现成语言库。MoonBit 负责协议、类型化对象、事务、一致性状态和重放；少量 C 仅承担系统调用。Demo 将提供真实内核快照与 iproute2 独立差分、隔离网络命名空间内链路变更的真实事件，以及跨平台离线重放。

如后续发现正在维护且 API 成熟的同功能 MoonBit 项目，须转为“基于已有项目扩展，而非重复建设”，贡献一致性状态/可移植重放层；本次调研未找到这样的直接上游，不声称永久排他。
