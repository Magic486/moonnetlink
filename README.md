# MoonNetlink

MoonBit 原生 Netlink 协议与 Linux 网络状态观察库。查询网卡、地址、路由和邻居，记录内核变更报文，并用相同 MoonBit 核心在 Linux、JavaScript、WASM-GC 上重放。

[![CI](https://github.com/Magic486/moonnetlink/actions/workflows/ci.yml/badge.svg)](https://github.com/Magic486/moonnetlink/actions/workflows/ci.yml)

这是经过生态调研后选定的 Linux 基础能力项目。业务查询直接使用 `NETLINK_ROUTE`，不是解析 `ip` 命令输出；`iproute2` 只用于独立测试。当前版本为 0.1.0，源码仓库为 [Magic486/moonnetlink](https://github.com/Magic486/moonnetlink)，发布进度与验收证据见 [交付说明](docs/release.md)。

## 快速运行

需要 MoonBit 2026-10-12 工具链或更新的兼容版本；Linux 原生构建需要 C 编译器和 Linux UAPI 头文件。没有第三方 Mooncakes 依赖。JavaScript 运行需要 Node.js。

在项目根目录运行，Windows 也能跑以下两种离线示例：

```sh
moon run examples/kernel_replay --target wasm-gc
moon run examples/replay --target wasm-gc
moon run examples/kernel_replay --target js
```

`kernel_replay` 重放随项目提供的 32 条真实隔离网络命名空间报文；`replay` 是明确标注为 `synthetic-demo` 的故障场景，最后显示 `stale: true`。

Linux 实机查询不需要 root：

```sh
moon run cmd/moonnet --target native -- snapshot
moon run cmd/moonnet --target native -- snapshot --record snapshot.jsonl
moon run cmd/moonnet --target native -- replay snapshot.jsonl
moon run cmd/moonnet --target native -- watch 5 changes.jsonl
moon run cmd/moonnet --target native -- demo
```

`watch` 时长为 1–60 秒。它先输出 `ready`，然后输出真实 typed event，最后给出状态摘要。日志是版本化 JSONL，记录原始字节与端序。错误输出到 stderr，进程退出码为 1。可选字段为 None 时，typed JSON 省略该字段。

## 能力与模块

| 包 | 能力 |
|---|---|
| `wire` | 报文头、四字节对齐、原生端序、TLV/嵌套属性、未知字节保留 |
| `route` | IPv4/IPv6 link/address/route/neighbor、ACK/扩展错误、DONE |
| `tracker` | seq 相关 dump 事务、部分结果拒绝、事件状态与失效原因 |
| `journal` | JSONL v1、显式端序、十六进制报文与 loss 记录 |
| `native` | Linux socket/poll/recvmsg、完整 datagram、内核发送者检查、关闭与自动 finalizer |
| `scenarios` / `fixtures` | 自编合成场景 / 本项目录制的真实 Linux 测试数据 |

API 签名见各包 `pkg.generated.mbti` 和 [API 说明](docs/api.md)。下例的导入写在调用方 `moon.pkg`：

```text
import {
  "Magic486/moonnetlink/native",
  "Magic486/moonnetlink/route",
}
```

```mbt
fn main raise {
  let socket = @native.Socket::open()
  defer socket.close()
  let capture = socket.dump(@route.Links)
  for event in capture.events { println(event.to_json().stringify()) }
}
```

独立项目可从 Mooncakes 安装模块，然后导入需要的子包：

```sh
moon add Magic486/moonnetlink
```

当前 API 版本为 0.1.0，模块包含 `wire`、`route`、`tracker`、`journal` 和 Linux 原生 `native`。从源码运行示例不需要另装本模块。

## 一致性边界

每类查询必须收到匹配 seq 的成功 DONE，才返回完整结果；负 errno、中断标记、接收溢出或截断不会被当作成功快照。四类对象分别查询，因此 `atomic_across_kinds` 始终为 false。

事件缓存始终 `starts_partial: true`，只描述已观察到的对象，不代表完整当前内核状态。`stale: false` 表示还没有检测到丢失，不代表从订阅之前开始的数据已完整。失效后必须重新查询，不能用后续几个正常事件清除失效标记。路由缓存按完整可观察身份维护，不实现所有内核路由替换/通配删除语义；复杂更新需重新 dump。TLV 原始内容保留，可由调用方继续解释。

原生传输只有 Linux；Windows/macOS 上原生打开 socket 返回不支持。完整 Generic Netlink、网络修改便捷 API、tc/nftables、异步调度集成和无竞态 snapshot+subscribe 初始化属于后续路线。

## 验证

```sh
moon check --target wasm-gc --deny-warn
moon test --target wasm-gc --deny-warn
moon test --target js --deny-warn
moon fmt --check
python scripts/verify-portable.py
```

Linux 再执行：

```sh
moon check --target native --deny-warn
moon test --target native --deny-warn
moon build cmd/moonnet --target native
python3 scripts/linux_integration.py
```

实机集成测试只在 `sudo -n unshare -n` 新建的临时网络命名空间内修改测试网络，退出后由内核回收。无命名空间权限时会明确报告跳过；普通查询与离线测试仍可运行。测试使用 Python 标准库、iproute2，不安装依赖。主机网络不断变化时，按先后时间读取的独立差分可能报告真实变化，应在稳定环境复测。

当前结果见 [验证报告](docs/validation.md)，演示见 [三分钟演示](docs/demo.md)，来源见 [THIRD_PARTY](THIRD_PARTY.md)。[GitHub Actions](https://github.com/Magic486/moonnetlink/actions) 对公开源码执行检查、构建、测试和独立集成验证。

## 选题与维护

- [Mooncakes 生态调研](mooncake-ecosystem-analysis.md)
- [GitHub 生态调研](github-ecosystem-analysis.md)
- [候选评分与撞车排除](project-competition-analysis.md)
- [项目方案与架构](project-proposal.md)
- [设计与协议边界](docs/architecture.md)
- [开发复盘与后续路线](docs/development.md)

MIT License。欢迎以后围绕 Generic Netlink family discovery、路由多路径类型化与 async transport 适配贡献扩展；先保持独立 protocol core 和可重放测试契约。
