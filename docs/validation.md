# 本地验证报告

验证日期：2026-10-14。以下为 Windows 开发环境与 SSH Linux 测试环境的实测结果。公开发布后的 CI 与安装验证另见 [交付说明](release.md)。

## 本地 MVP 基线检查

| 检查 | 结果 |
|---|---|
| Windows MoonBit 2026-09-15，WASM-GC check / test，deny-warn | 54 / 54 通过 |
| 同一 Windows 工具链，JavaScript test，deny-warn | 54 / 54 通过 |
| Windows native check，deny-warn | 通过；不宣称 Windows 支持 Linux socket |
| Linux MoonBit 2026-09-20，native check / test，deny-warn | 59 / 59 通过 |
| Windows / Linux moon fmt --check | 通过 |
| Linux native CLI build | 通过 |
| 合成示例 WASM-GC / JS 逐步 JSON 比较 | 7 步全部相同，显式 loss 后 stale=true |
| 真实 capture WASM-GC / JS / Linux native 逐步 JSON 比较 | 32 步全部相同，最后 applied_events=32、对象清空、stale=false |
| README 中 native snapshot --record 与 replay 命令 | 实际执行成功 |

测试覆盖独立大小端 golden bytes、5120 次确定性报文变异、所有短头、长度溢出、未知/嵌套属性、无效 UTF-8、扩展 ACK、DONE/seq、中断、部分状态拒绝、sticky loss、link 级联删除、邻居更新、JSONL 错误、真实 IPv6 事件、native 超时和重复关闭。59 项包含 54 项协议/核心测试与 5 项原生测试。

## Linux 独立差分与真实事件

内核 `7.0.0-38-generic`。实际 NETLINK_ROUTE 结果与 `iproute2` JSON 比较，记录见 [原始汇总](test-evidence/linux-integration-report.json)：

| 对象 | 比较字段 | 本次匹配数量 |
|---|---|---:|
| Link | index/name/MTU/hardware address | 13 |
| Address | interface/family/prefix/local | 21 |
| Route | family/table/prefix/gateway/interface/metric | 68 |
| Neighbor | family/interface/IP | 69 |
| 非空 Neighbor hardware address | 实际内核硬件地址 | 67 |

其余 2 条邻居记录的 NDA_LLADDR 缺失或为空，仅跳过硬件地址比较，身份仍全部比较。两个 TUN 条目的属性为空，但 ip 输出 08；iproute2 的 [ll_addr_n2a 实现](https://github.com/iproute2/iproute2/blob/main/lib/ll_addr.c) 对零长度也读取首字节，解释了它不适合作为空属性的独立真值。本项目保留内核原始空值。主机邻居动态变化，以上是该轮观察数量，不是固定主机清单。

隔离实验使用 `sudo -n unshare -n`，创建临时 dummy 接口、IPv4/IPv6 文档地址、路由与邻居，再逐项删除。采集 32 条报文，覆盖四类增删；在线状态与离线重放一致，结束对象为 0，主机网络不改动。[隔离结果](test-evidence/namespace-report.json) 与 [原始测试 fixture](../fixtures/namespace-events.jsonl) 提供证据。公开 fixture 来自独立隔离命名空间，不包含实机网络快照。

CLI 未知命令、非法 watch 时长、缺失日志、错误日志版本均以非零码和 JSON stderr 拒绝。普通读取不需要 root；修改场景只在临时 namespace 内运行。

## 重现与证据

按 README 执行各后端测试、`scripts/verify-portable.py` 和 Linux `scripts/linux_integration.py`。测试生成 `demo-output`；随项目保留的报告为本轮结果。跨平台证据：[便携比较](test-evidence/portable-report.json)、[WASM-GC 真实重放](test-evidence/kernel_replay-wasm-gc.jsonl)、[Linux native 真实重放](test-evidence/kernel-replay-native.jsonl)。

首次发布前已迁移到 2026-10-12 的整数类型名、默认参数语法与 Json 转换。迁移后 Linux 再次通过 WASM-GC/JS 各 54 项、native 59 项；公开 CI 结果见 release.md。上面的 September 工具链记录属于迁移前基线，不是当前最低版本承诺。

协议全解析并不代表所有内核语义已实现。缓存始终部分覆盖，跨对象快照不原子，复杂路由替换/通配删除需重新 dump；现场事件接收也不能证明未来绝无丢包。当前结果足以证明已列出的 MVP 契约，不是正式赛事审核或获奖判断。
