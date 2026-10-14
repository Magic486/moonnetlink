# MoonNetlink 项目说明

- 代码仓库：https://github.com/Magic486/moonnetlink
- 项目：MoonBit 原生 Linux Netlink 网络对象观察与可验证重放基础库。
- 方向：协议库、Linux 基础组件、开发者工具；原创独立实现，非其他语言库移植。
- 需求：网络诊断、容器/VPN 状态工具需要类型化内核对象和事件，TCP/HTTP API 无法替代这层能力。
- 调研：检查 Mooncakes 2,996 条模块元数据与 GitHub；未检索到直接 MoonBit Netlink 实现，排除了已有 Agent/MCP/workflow/沙箱等重复方向。
- 核心：Netlink/TLV、IPv4/IPv6 link/address/route/neighbor、ACK/DONE/seq、丢失失效、原始报文 JSONL 与离线重放。
- 架构：MoonBit 实现协议/事务/缓存/记录；小型 C 桥仅实现 Linux socket/poll/recvmsg 与文件 I/O。
- 交付：MIT 源码、CLI、两个示例、API/架构文档、三分钟演示、CI 配置与实测报告。
- 验证：WASM-GC/JS 各 54 项测试，Linux native 59 项；iproute2 独立差分与隔离 namespace 32 条真实事件；三个后端逐步重放一致。
- 边界：观察缓存部分覆盖，跨类别快照非原子，复杂路由更新需重新 dump；Generic Netlink 与 async 适配为后续方向。
- AI：参与调查、实现和测试；开发复盘与可解释设计说明随仓库提供。
- 公开过程：先本地完成 MVP，再首次公开发布；历史如实记录，不补造提交。
- 发布/验收证据：docs/release.md；正式赛事报名与审核由参赛者按流程完成。
