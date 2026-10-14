# GitHub 生态调研

调研日期：2026-10-14。原始证据：`research/github-evidence.json`。

## 检索范围与限制

检索 moonbit language、moonbitlang、moonbit-community、awesome-moonbit、topic:moonbit、language:MoonBit。每项保存前 15 个结果及总数；这是结构化抽样，未声称读完所有仓库源码。另查官方、社区、直接竞争者的 metadata、issue/PR 和 roadmap。公开 API 最后两项查询触发 403 限流，原样记录，不当成零结果。404 不等于项目不存在，包名与仓库名可不同。

| 查询 | GitHub 总结果 | 代表仓库 |
|---|---:|---|
| moonbit language | 83 | moonbitlang/moonbit-docs, moonbitlang/moonbit-agent-guide, pku-dppl/TAPL-in-MoonBit, extism/moonbit-pdk, moonbitlang/protoc-gen-mbt |
| moonbitlang | 30 | moonbitlang/x, oboard/reqbest, suiyunonghen/datetime, FrozenLemonTee/xim-pkgindex-moonbitlang, tonyfettes/encoding.mbt |
| moonbit-community | 3 | moonbit-community/Community-Blog, moonbit-community/tonyfettes-readline, moonbit-community/tui |
| awesome-moonbit | 1 | moonbitlang/awesome-moonbit |
| topic:moonbit | 391 | nikivdev/code, moonbitlang/core, mizchi/actrun, nikivdev/mbt, moonbitlang/moon |
| language:MoonBit | 3138 | moonbitlang/moonbit-docs, moonbitlang/core, mizchi/actrun, nikivdev/mbt, moonbitlang/moonbit-course |
| netlink moonbit | 0 |  |
| rtnetlink moonbit | 0 |  |
| io_uring moonbit | HTTP Error 403: rate limit exceeded |  |
| landlock moonbit | HTTP Error 403: rate limit exceeded |  |

## 官方及社区项目元数据

| 仓库 | Star | 最后推送 UTC | 默认分支 | 活跃/用途 |
|---|---:|---|---|---|
| [moonbitlang/core](https://github.com/moonbitlang/core) | 1225 | 2026-10-14T07:29:08Z | main | MoonBit's Core library |
| [moonbitlang/async](https://github.com/moonbitlang/async) | 71 | 2026-10-13T02:41:19Z | main | async programming library for MoonBit |
| [moonbitlang/moon](https://github.com/moonbitlang/moon) | 424 | 2026-10-14T07:25:29Z | main | The build system and package manager for MoonBit |
| [moonbitlang/moonbit-compiler](https://github.com/moonbitlang/moonbit-compiler) | 705 | 2026-10-12T10:35:53Z | main | 未提供 |
| [moonbitlang/openseek](https://github.com/moonbitlang/openseek) | 100 | 2026-10-14T07:31:47Z | main | DeepSeek-backed MoonBit coding agent. |
| [moonbitlang/awesome-moonbit](https://github.com/moonbitlang/awesome-moonbit) | 158 | 2026-09-11T05:38:50Z | main | A curated collection of awesome MoonBit tools, frameworks, libraries and articles. |
| [moonbit-community/rabbita](https://github.com/moonbit-community/rabbita) | 132 | 2026-10-13T04:48:21Z | main | simple, declarative, functional web UI framework for MoonBit |
| [moonbit-community/proton](https://github.com/moonbit-community/proton) | 33 | 2026-10-14T07:24:28Z | main | A MoonBit framework for building native desktop applications with a web frontend |
| [matrix486/moonjail](https://github.com/matrix486/moonjail) | 0 | 2026-09-28T05:06:26Z | main | MoonBit-native least-privilege sandbox for Linux tools |
| [mizchi/mcp.mbt](https://github.com/mizchi/mcp.mbt) | 未知 | 未提供 | 未提供 | HTTP Error 404: Not Found |
| [mizchi/sandbox.mbt](https://github.com/mizchi/sandbox.mbt) | 0 | 2026-10-05T03:58:26Z | main | 未提供 |
| [0717lee/pixelforge](https://github.com/0717lee/pixelforge) | 1 | 2026-10-01T05:32:56Z | main | Pure MoonBit image-processing library: 26 filters & transforms, morphology ops, PNG/QOI/BMP codecs, affine transforms, layer compositing, and a generic convolution engine. Zero dependencies, compiles to JS / WebAssembly / native, with an in-browser Playground. |
| [2515050242/moonagentcheck](https://github.com/2515050242/moonagentcheck) | 0 | 2026-10-10T16:50:39Z | master | 可重复的 Agent 工具行为契约测试，MoonBit 核心与离线 fixture |
| [weopqrst/agent](https://github.com/weopqrst/agent) | 未知 | 未提供 | 未提供 | HTTP Error 404: Not Found |
| [mihujiang/MoonBit](https://github.com/mihujiang/MoonBit) | 1 | 2026-08-24T02:09:03Z | main | MoonBit for Agent |
| [mizchi/workflow](https://github.com/mizchi/workflow) | 未知 | 未提供 | 未提供 | HTTP Error 404: Not Found |
| [yadidyc/moonpod](https://github.com/yadidyc/moonpod) | 0 | 2026-09-30T17:04:32Z | main | 未提供 |
| [chensuiyi/subproc](https://github.com/chensuiyi/subproc) | 未知 | 未提供 | 未提供 | HTTP Error 404: Not Found |
| [i5ting/chokidar](https://github.com/i5ting/chokidar) | 3 | 2026-05-18T15:43:33Z | codex/chokidar-native | 未提供 |

## Issues、路线图、TODO

以下明确区分 issue 与 PR，不将开放请求说成已实现能力。

### moonbitlang/async

- Issue [#655 Windows: relative symlink target type is checked against process cwd](https://github.com/moonbitlang/async/issues/655)
- Issue [#652 Feature request: Unix domain socket support in @socket (for local IPC)](https://github.com/moonbitlang/async/issues/652)
- Issue [#648 Support opt-in process groups and descendant cleanup for managed processes](https://github.com/moonbitlang/async/issues/648)
- Issue [#646 async fn main is not recognized as the entry point unless an async subpackage is imported](https://github.com/moonbitlang/async/issues/646)
- PR [#644 test(process): make "pipe" redirect test independent of timing](https://github.com/moonbitlang/async/pull/644)
- Issue [#643 spawn_orphan: add an opt-in way to start the child in a new session (like Node's detached / Python's start_new_session)](https://github.com/moonbitlang/async/issues/643)
- PR [#642 feat(http): support extension request methods](https://github.com/moonbitlang/async/pull/642)
- Issue [#641 http: support extension request methods (WebDAV PROPFIND, REPORT, custom API methods)](https://github.com/moonbitlang/async/issues/641)
- Issue [#640 @fs.mkdir(recursive=true) still raises when the target directory already exists (mkdir -p convention)](https://github.com/moonbitlang/async/issues/640)
- Issue [#639 Loops containing an await point pay ~20 µs per iteration even when the await is never reached at runtime](https://github.com/moonbitlang/async/issues/639)
- PR [#634 fix(unix): keep waiting when a readiness wake-up is spurious](https://github.com/moonbitlang/async/pull/634)
- PR [#633 API changes before merging into `moonbitlang/core`](https://github.com/moonbitlang/async/pull/633)

### moonbitlang/moon

- PR [#2293 feat(moonrun): add append_bytes_to_file_new, sync_file_new and rename_new host imports](https://github.com/moonbitlang/moon/pull/2293)
- PR [#2292 feat(moonrun): support fixed working directories per run](https://github.com/moonbitlang/moon/pull/2292)
- PR [#2289 feat(moonrun): support per-run standard streams through channels](https://github.com/moonbitlang/moon/pull/2289)
- Issue [#2288 bug(moonrun): macOS async conformance snapshots depend on timer interleaving](https://github.com/moonbitlang/moon/issues/2288)
- Issue [#2263 moonrun: allow writable directory contents without granting removal of the root](https://github.com/moonbitlang/moon/issues/2263)
- Issue [#2262 Native builds do not disable FP contraction (-ffp-contract=off), so floating-point results change under GCC](https://github.com/moonbitlang/moon/issues/2262)
- Issue [#2254 [native/windows] moonc's moonbit_init (18.5k-line flat init block) makes cl /O2 ~5-10x slower than clang; MSVC 14.51 regressed ~1.4-1.6x on this shape](https://github.com/moonbitlang/moon/issues/2254)
- Issue [#2251 Promote remaining moon.pkg options to dedicated DSL declarations](https://github.com/moonbitlang/moon/issues/2251)
- Issue [#2228 native: stack overflow exits with a bare SIGSEGV — no diagnostic, and buffered stdout is lost](https://github.com/moonbitlang/moon/issues/2228)
- PR [#2220 feat: support conditional imports in moon.pkg](https://github.com/moonbitlang/moon/pull/2220)
- PR [#2192 feat(build): add opt-in Wasm hash executor](https://github.com/moonbitlang/moon/pull/2192)
- PR [#2166 refactor(build): prefix per-script build directories with a dot](https://github.com/moonbitlang/moon/pull/2166)

### moonbitlang/openseek

- PR [#2012 fix(desktop): replace continuation glyphs with codicons](https://github.com/moonbitlang/openseek/pull/2012)
- PR [#2011 feat(desktop): integrate Cloud into Chat](https://github.com/moonbitlang/openseek/pull/2011)
- PR [#2010 refactor(desktop): make host resources and toolchain selection explicit](https://github.com/moonbitlang/openseek/pull/2010)
- PR [#2009 test(desktop): split large browser specs by feature](https://github.com/moonbitlang/openseek/pull/2009)
- PR [#2008 feat(desktop): edit user messages inline before forking](https://github.com/moonbitlang/openseek/pull/2008)
- PR [#2004 feat(desktop): annotate PDF text and regions](https://github.com/moonbitlang/openseek/pull/2004)
- Issue [#1999 [External] Independent judging of agent harnesses — free L1 slot on our live leaderboard (launched Oct 12)](https://github.com/moonbitlang/openseek/issues/1999)
- PR [#1993 feat(desktop): preserve terminal shells across network reconnects](https://github.com/moonbitlang/openseek/pull/1993)
- PR [#1971 [codex] Replace custom multipart encoders with Yoorkin/multipart](https://github.com/moonbitlang/openseek/pull/1971)
- PR [#1970 feat: have a serve engine report its MCP servers](https://github.com/moonbitlang/openseek/pull/1970)
- PR [#1969 refactor(desktop): extract remote access into its own package](https://github.com/moonbitlang/openseek/pull/1969)
- PR [#1968 refactor(desktop): move root update tests into domain files](https://github.com/moonbitlang/openseek/pull/1968)

### matrix486/moonjail


### 路线图解读

- async Issue #652 请求 Unix domain socket，本轮 API 还只公开 TCP/UDP 等。它支持“原生 I/O 仍有补齐空间”，但不能直接证明 Netlink 的所有功能缺失。
- async #648/#643 讨论进程组与子孙进程生命周期，说明进程管理也在演进；不选择重做已有 process manager。
- OpenSeek `agent-improvement-guide.md` 强调 CLI 外部契约、文件/标准输入的真实验证和文档复现；新项目将以 Linux 实机结果和 iproute2 差分测试落实这一点。
- awesome-moonbit 已列出 parser、formatter、async、maria、前端框架、WASI、crypto 等。它是导航清单，更新慢于全量包索引。
- compiler README 描述后续工具开源路线，不能把闭源/未公开编译器内部当作比赛项目可依赖的公共 API。

## 直接竞争检索与结论

全量 Mooncakes 元数据无 netlink/rtnetlink 匹配；GitHub 仓库搜索 `netlink moonbit` 与 `rtnetlink moonbit` 均返回 0。额外网页搜索 MoonBit + AF_NETLINK、RTM_GETLINK、rtnetlink 未发现直接实现。所检查的官方 socket 接口不提供相同 API。**结论仅限公开可检索的本轮样本**；未发表、未标关键词或私有项目仍可能存在。
Linux 沙箱直接竞争者 [matrix486/moonjail](https://github.com/matrix486/moonjail) 已有 typed policy 和 native runtime，因此按用户规则否决。io_uring 当前未找到直接 MoonBit 模块，但不选它：取消、GC 内存所有权与内核共享队列的工程风险显著高于 Netlink。
选中 Netlink 时不重做 HTTP、网络协议栈或通用解析器。它新增 MoonBit 与 Linux 内核网络对象交互、观察、录制和重放能力。

## 来源

- [MoonBit 官方](https://github.com/moonbitlang)、[社区](https://github.com/moonbit-community)、[awesome-moonbit](https://github.com/moonbitlang/awesome-moonbit)
- [Linux Netlink 文档](https://docs.kernel.org/userspace-api/netlink/intro.html) 与 Linux UAPI headers：作为协议定义参考，不移植现有语言库。
- [十月 Hackathon 官网](https://moonbitlang.github.io/Hackathon2026/)：本期截止 2026-10-31。官网页面 JS 内容本地保存为 `research/hackathon-asset-0.txt`；与早期 OSC/SCC 分开。
