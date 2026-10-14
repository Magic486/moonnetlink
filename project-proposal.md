# MoonNetlink

> 一个为 MoonBit 生态提供 Linux 内核网络对象查询、事件观察与可验证重放能力的开源项目。

## 为什么现在需要它

MoonBit 已有 TCP/UDP、HTTP、Agent、MCP、工作流、图像与前端框架；不能继续依靠领域名字制造“空白”。网络诊断器、容器网络工具、VPN 状态面板、服务发现器需要的不仅是发请求，还要知道网卡、IP 地址、路由和邻居何时改变。

当前被调查的官方 `async/socket` 接口没有 Netlink。通过 shell 调用 ip 适合人工排查，但不能提供类型化协议、事务相关、未知属性保留、数据丢失标记及同一核心的离线重放。MoonNetlink 把这些组合成可复用基础设施。

证据范围与限制见 [Mooncakes调研](mooncake-ecosystem-analysis.md)、[GitHub调研](github-ecosystem-analysis.md)、[竞争分析](project-competition-analysis.md)。未发现直接竞争不等于证明生态中没有任何未检索项目。

## 与已有项目区别

```makefile
已有项目:
  moonbitlang/async: TCP、UDP、文件和进程等异步宿主能力
  hevienz/moonbit_libbpf: eBPF 绑定
  matrix486/moonjail: Linux 权限沙箱
  iproute2: 成熟 C 系统工具，用作独立行为参考
本项目:
  MoonBit 原生 Netlink/TLV 编解码与未知字段保留
  类型化 link/address/route/neighbor 观察 API
  dump 请求相关、DONE/ERROR、丢失和中断处理
  事件应用、状态失效标记、原始报文录制与离线重放
```

不复制上游 C/Rust/Go 库。参考 Linux 官方协议及 UAPI 定义，独立实现。项目许可证 MIT；开发工具/测试参考来源列入 THIRD_PARTY.md。

## 技术架构

### Architecture Diagram

```mermaid
flowchart LR
  K[Linux NETLINK_ROUTE] <--> C[C系统调用桥]
  C <--> N[native Socket]
  N <--> T[Dump事务/订阅]
  T <--> W[MoonBit wire codec]
  W --> R[类型化 rtnetlink]
  R --> S[状态缓存/失效标记]
  W --> L[版本化原始报文日志]
  L --> P[离线重放]
  P --> R
  S --> CLI[CLI JSON/演示报告]
```

### Modules

| 模块 | 职责 | 后端 |
|---|---|---|
| wire | nlmsghdr、四字节对齐、属性、嵌套属性、编码、严格边界 | wasm-gc/js/native |
| route | link/address/route/neighbor typed 解码；保留未知 TLV | wasm-gc/js/native |
| tracker | dump 事务相关、终态、缓存更新和 stale 标记 | wasm-gc/js/native |
| journal | 版本化报文录制、十六进制编解码、离线校验重放 | wasm-gc/js/native |
| native | Linux socket、poll、recvmsg、内核发送者检查、资源关闭 | Linux native |
| cmd/moonnet | snapshot、watch/record、replay、demo | Linux native |
| examples/replay | 固定故障场景、状态失效展示，无网络依赖 | wasm-gc/js/native |

### Data Flow

查询由 MoonBit 构造 RTM_GET* 请求 → C 发送 bytes → 接收完整 datagram → MoonBit 校验 header/TLV → 按 seq 关联 dump → 完整 DONE 后交付类型化结果。DUMP_INTR、OVERRUN、ENOBUFS、MSG_TRUNC 都不能被误报为完整状态。

订阅使用独立 socket，避免通知与请求响应混淆。每个 datagram 可录制为版本化 JSONL 的原始 bytes；replay 使用相同 decode/apply API。Snapshot 四类对象分别查询，**不宣称跨类别原子快照**。订阅和快照合并的无竞态初始化不在本期范围，观察模式明确从未知/局部状态开始。

### API Design

```mbt nocheck
// 拟定 API，最终签名以各包生成的 pkg.generated.mbti 为准。
let messages = @wire.decode(datagram)
let attrs = @wire.decode_attributes(payload)
let event = @route.decode(message)
let transaction = @tracker.Dump::new(sequence, @route.Links)
transaction.accept(message)
let state = @tracker.State::new()
state.apply(event)
state.mark_stale("receive buffer overflow")
let socket = @native.Socket::open(groups=0)
let links = socket.dump(@route.Links)
socket.close()
```

公共类型归属于公开模块；错误显式返回/抛出，未知属性保留 bytes，不按未知字段崩溃。支持端序显式配置的 wire 层；实机 native 探测宿主端序。

## MVP 范围与验收

第一阶段必须完成以下全部工作后才标记开发 goal 完成：

1. 核心：通用 Netlink 编解码、嵌套 TLV、link/address/route/neighbor、dump 事务、未知字段、state reducer、丢失/中断失效标记。
2. Linux：真实 NETLINK_ROUTE socket，不调用 ip 获取业务数据；bounded poll、完整 datagram 校验、自动/显式资源关闭；无 root 运行 snapshot。
3. Demo：真实快照、原始 bytes 录制/重放、合成故障场景；若隔离命名空间可用，再进行真实 link/address/route 变更事件测试，不修改 SSH 所用主机网络。
4. Tests：编解码 round-trip、所有截断位置、长度溢出、未知/嵌套属性、负 errno、ACK/DONE、seq mismatch、DUMP_INTR、损失状态、状态替换/删除、跨后端一致输出、Linux 与 ip JSON 差分。
5. Documentation：README、API、协议/架构、限制、3分钟演示、来源许可证、开发复盘、复现脚本和本地测试报告；CI 配置只写本地，不发布。

不实现网络修改 API、完整 Generic Netlink、nftables、tc、路由策略规则及异步框架集成。它们是长期路线，不应出现在完成声明里。

## Hackathon 三分钟展示

| 时间 | 内容 |
|---|---|
| 0–30秒 | 展示“网卡/路由变化时，TCP/HTTP API 不会告诉你发生了什么”；说明生态调研排除了 Agent/MCP/沙箱重做 |
| 30–120秒 | 运行 snapshot 并查看真实 typed JSON；展示十余行 API；在隔离命名空间中新建 demo 网卡，观察 link/address/route 通知并录制；若无命名空间权限，运行已录制真实报文与明确标注的合成故障演示 |
| 120–180秒 | replay 在 wasm-gc 上运行；演示损失后 stale=true，不能把过时缓存当真；展示 iproute2 差分与测试报告、包分层、后续 Generic Netlink 路线 |

## 赛事与交付边界

当前十月赛事官网为 [Hackathon2026](https://moonbitlang.github.io/Hackathon2026/)，页面内容显示报名与验收截至 **2026-10-31**，关注真实需求、工程边界、测试、开源合规和维护价值。不能拿早期 OSC 或 SCC 的时间和百分比当成本期规则。获奖由实际评审决定。

最初依用户要求先本地开发，之后按新指令准备 [Magic486/moonnetlink](https://github.com/Magic486/moonnetlink) 公开仓库与 Mooncakes 发布。发布证据见 docs/release.md。公开历史从真实首次导入开始，不补造此前公开提交。报名、入群和官方验收仍需按赛事流程完成，技术验证不等同正式审核通过。

## 0.2.0 已完成的后续扩展

在原 MVP 之上完成加权多路径解析和依赖清理、Generic controller 元数据/ACK 事务与 Linux family 录制查询、增量 replay SDK、缓存属性隔离、可执行 API 文档及独立包消费 CI。Generic 范围为 discovery，并未扩大为完整协议操作框架。三后端最终测试为 WASM-GC/JS 各 87、Linux native 96；0.2.0 已发布至 Magic486 的 Mooncakes 模块，详情见 docs/release.md。

本期展示现在可直接查询 `nlctrl` 的 operation/group，并跨后端重放其真实记录；Route 演示仍使用 32 条隔离环境事件和明确标注的合成失效场景。一页正式申报材料见 submission-proposal.md 与 output/pdf/MoonNetlink-proposal-0.2.0.pdf。
