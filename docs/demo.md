# 三分钟展示

提前准备：打开 README、`route/decode.mbt`、`tracker/dump.mbt` 和终端。Windows 展示离线重放；Linux 展示实时查询。真实采集的 fixture 已随项目提供，无需现场修改主机网络。

## 0–30 秒：问题

“MoonBit 已有 HTTP、AI、工作流和 WASM 应用能力，但我们本次检索没有找到原生 Netlink 库。Linux 工具若只能解析 ip 文本，就缺少类型化内核事件、事务完成判定和可跨平台复现的原始记录。MoonNetlink 补上这层基础能力。”展示生态竞争表、模块图。

## 30–120 秒：代码与实际运行

用一分钟展示 `Socket::dump` 的 seq/DONE 检查和 `route.decode` 的类型化事件，强调 C 桥只收发字节。Linux 项目根目录执行：

```sh
moon run cmd/moonnet --target native -- snapshot --record demo-output/demo-snapshot.jsonl
moon run cmd/moonnet --target native -- replay demo-output/demo-snapshot.jsonl
```

显示四类对象与 `complete_by_kind`，指出 `atomic_across_kinds: false`。再在 Windows 或 Linux 执行：

```sh
moon run examples/kernel_replay --target wasm-gc
moon run examples/kernel_replay --target js
```

展示 32 条真实内核事件，包括 IPv4/IPv6、四类对象的增删，最后对象清空且 stale=false。解释这些来自临时网络命名空间，不是手写成功输出。

## 120–180 秒：效果与可信度

```sh
moon run examples/replay --target wasm-gc
```

最后的 stale=true 展示显式丢失，不允许后续正常事件假装恢复完整性。打开 validation 报告：跨后端逐步一致、iproute2 独立字段比较、真实事件重放一致。结束于扩展路线：Generic Netlink family discovery、多路径类型化、async transport。

现场若允许等待，Linux 执行 `python3 scripts/linux_integration.py` 重现完整隔离实验；它只在临时 namespace 内创建 mn-demo0，不改主机网络。三分钟演示使用已保存证据，避免测试等待占据讲解时间。`demo-output` 目录由验证脚本创建，也可提前 `mkdir -p demo-output`。
