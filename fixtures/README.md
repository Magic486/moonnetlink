# 本项目真实 Linux 录制数据

2026-10-14，在 Ubuntu 内核 `7.0.0-38-generic` 的测试环境上，测试脚本创建临时网络命名空间，执行 dummy 网卡建立/启用、IPv4 与 IPv6 地址分配、路由与邻居增删，最终删除网卡。没有修改宿主网络。

- `namespace-events.jsonl`：32 个原始内核 Netlink datagram，含端序，供 CLI 离线重放。
- `namespace-watch.jsonl`：同一次录制的 typed 事件与最终摘要，供阅读和解释。
- `capture.mbt`：相同 JSONL 的生成嵌入，用于 WASM-GC/JS 无宿主 I/O 重放。不要手改；运行 `python scripts/embed-fixture.py` 重生成。
- `nlctrl.jsonl` / `family_capture.mbt`：同日以只读 Generic Netlink 查询 `nlctrl` 得到的真实 family metadata 与 ACK；不含主机网络快照或凭据。重放展示操作能力与 multicast group 发现。

生成数据来源是本项目自身测试，许可 MIT。随机网卡 MAC 和内核计数是该次录制内容，不用于断言宿主后续状态。独立 golden byte tests 另置于 `wire/codec_test.mbt`，不依赖该录制的编码器。
