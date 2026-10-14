# 第三方来源与许可证

本项目为独立实现，不是已有语言库的代码移植。没有复制 libnl、Rust rtnetlink、Go Netlink 或 iproute2 的实现，也没有第三方 Mooncakes 依赖。

| 来源 | 使用范围 | 许可证/处理 |
|---|---|---|
| [Linux Netlink 官方文档](https://docs.kernel.org/userspace-api/netlink/intro.html) | 报文布局、对齐、ACK、dump 中断、接收行为的定义参考 | 文档链接引用；未复制长段落 |
| Linux 安装环境的 `linux/netlink.h`、`rtnetlink.h` 等 UAPI | 标准系统头引用与协议常量/结构字段参考 | 系统 UAPI 许可证及 Linux-syscall-note 按头文件适用；未将 Linux 实现源代码加入本项目 |
| MoonBit 工具链、core 与 `moonbit.h` | 标准库、编译器、FFI/外部对象 ABI | core/运行时 Apache-2.0；通过标准工具链引用，无 core 源码复制 |
| [iproute2](https://github.com/iproute2/iproute2) | 外部独立命令差分测试、零长度硬件地址展示行为诊断 | GPL-2.0-or-later；只调用已安装测试命令及链接说明，未复制/链接其代码 |
| Mooncakes/GitHub/Hackathon 官网 | 选题元数据和公开规则调研 | 摘要与链接保留在调研报告；原始网页、抓取数据不随仓库/包分发 |

`scenarios/fixtures.mbt`、独立字节 golden 和所有合成输入由本项目编写。`fixtures/namespace-events.jsonl` 是本项目在独立 Linux 网络命名空间内执行测试后录制的报文，使用文档保留地址和临时 dummy 网卡，不含登录凭据。`fixtures/capture.mbt` 由 `scripts/embed-fixture.py` 生成，只嵌入同一份报文，不构成手写实现规模。测试数据随项目 MIT 许可提供。

AI 参与了调研、代码与测试生成。参与者需要在参赛提交时审阅并解释架构与代码，开发复盘已记录生成和实测过程。项目采用 MIT，源码仓库归属 Magic486；当前发布证据见 docs/release.md。
