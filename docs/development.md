# 开发复盘与维护路线

2026-10-14 先完成 registry、GitHub、竞品和比赛来源调查，再选择唯一项目、启用 goal 并开发。选题由生态缺口优先决定：Agent/MCP/workflow/image/WASM frontend 已有项目，Linux sandbox 也有 moonjail；没有换到 Linux 就重新建设 sandbox。最终选择没有检索到直接同类的 Netlink 基础库，调查范围和无法证明绝对不存在的边界写在研究报告。

AI agent 负责调查、架构、MoonBit 实现、C 系统调用桥、测试和说明文档。结果通过实际工具链和 SSH Linux 环境验证，未用生成文本替代执行证据。测试过程中修复过不可变 Bytes 写入、UTF-16 长度与字符计数混用、旧工具链公开 derive 接口、多消息解析部分应用和 CLI 事件标签解析等问题。

真实系统差分发现两个 TUN 邻居条目的 NDA_LLADDR 为零长度，而 ip 输出为 08。项目保留内核空值，比较所有邻居身份，仅对这两项跳过 MAC 比较，明确记录限制。没有为了“全部相等”伪造内核数据。

第一阶段交付包含四种 rtnetlink 对象、IPv4/IPv6、控制消息、事务完整性、状态失效、JSONL 原始记录、CLI、跨后端重放、Linux 独立差分与隔离实验。后续按新增生态贡献推进：先增加 Generic Netlink family discovery 和多路径类型化，再适配官方 async 传输，最后完善 snapshot+subscribe 初始化和内核路由替换语义。每项需要独立真实 capture 和回归契约。

初始版本在本地完成后，按用户指令准备公开仓库与包发布。公开历史从首次导入开始，不能据此声称此前开发已经公开进行，也不会通过空提交补造过程。后续维护使用实际问题、变更与 CI 记录。最新发布证据见 release.md；正式报名、进群和赛事审核属于独立流程。
