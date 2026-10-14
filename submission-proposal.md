# 2026 MoonBit 黑客松项目申报书

**项目：MoonNetlink ｜ 软件版本：0.2.0 ｜ 申报账号：Magic486（GitHub） ｜ 材料日期：2026-10-15**
源码：https://github.com/Magic486/moonnetlink ｜ 包：Magic486/moonnetlink

## 项目概述
一个为 MoonBit 生态提供 Linux 内核网络对象查询、事件观察与可验证重放能力的原创开源项目。面向网络诊断、容器/VPN 状态工具与跨平台测试，降低内核协议接入和故障复现成本。

## 生态价值与创新
开发前检查 Mooncakes 2,996 条模块元数据及 GitHub 官方/社区项目，调研未检索到直接 MoonBit Netlink 实现，并排除已有 AI/MCP/工作流/沙箱等重复方向。本项目独立实现协议，不移植现成语言库、不解析 ip 命令文本；以协议、事务与重放的组合补充 Linux 基础能力。

## 架构与已交付能力
MoonBit 实现 wire/route/tracker/journal/genl/replay；native 中少量 C 只承担系统调用与 I/O。支持 IPv4/IPv6 四类网络对象、加权多路径下一跳、seq 与 ACK/DONE 完成判定、丢失失效、属性隔离、增量 JSONL 重放和 Generic Netlink family/operation/group 发现；提供 CLI 与三种跨后端示例。

## 验证与工程质量
WASM-GC、JavaScript 各 87 项测试，Linux native 96 项测试通过；32 条隔离环境真实事件重放一致，nlctrl 元数据与 ACK 实机录制验证通过，并以 iproute2 独立比较查询结果。CI 另从实际打包归档构建消费模块，验证公开 API 与原生 C 桥。手写 MoonBit 源码约 4.1k 行（含测试），生成 fixture 另计。

## 开发记录与开源合规
仓库已形成 16 条以上真实提交，覆盖错误状态、多路径解码与清理、Generic 协议与实机查询、重放 SDK、数组隔离、录制示例、包消费 CI 和可执行文档；未用空提交或补造日期充数。MIT 许可，独立实现与参考来源、录制数据、AI 辅助开发过程均已披露；不分发凭据、主机快照、原始抓取或构建文件。

## 展示与长期维护
三分钟展示：前 30 秒说明生态缺口，随后展示 Linux 查询和 family 发现，最后跨后端重放真实记录并展示丢失后的 stale。后续围绕 Generic policy/multicast、官方 async 适配及一致性初始化扩展，维持独立协议核心与录制回归契约。

## 验收材料入口与边界
公开源码、README、API、来源、测试、CI、演示与报告位于仓库；安装命令为 moon add Magic486/moonnetlink@0.2.0。完整核对见 docs/acceptance-review.md 与 docs/release.md。
观察缓存部分覆盖，跨类别快照非原子，复杂路由语义需重新 dump；软件交付证据不替代赛事报名、入群及官方审核。
