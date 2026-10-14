# Mooncakes 生态调研

调研日期：2026-10-14（Asia/Shanghai）。先完成生态检索，再开始项目代码。

## 方法与证据边界

直接读取 [Mooncakes](https://mooncakes.io/) 当前全量模块 API，共 **2,996** 条；保存 `research/mooncakes-modules.json`。按名称、说明、关键词进行本地全量检索，并对用户指定的 13 个词逐一调用官网真实搜索端点 `/api-new/v0/search?kw=…&limit=20`，保存 `research/mooncakes-searches.json`。搜索使用模糊匹配，返回 20 条不等于总数，也不能把 io_uring 搜索的模糊结果误认为同名实现。
官网首页脚本实际使用上述端点；最初尝试的 modules?q/query/search 参数均未过滤，已改用正确端点。全量精确词扫描中 netlink、rtnetlink、io_uring 均未命中。
`created_at` 是索引当前版本条目的时间，**不是仓库最后提交时间**。活跃性另看 GitHub pushed_at；未取得数据标记未知。Star 与下载不能证明真实用户规模。索引里可能有已撤回版本，必须看 yanked。无搜索结果仅表示本次检索未发现，不能证明绝对不存在。

## 关键词逐项结果

| 关键词 | 官网返回条数（最多20） | 全量元数据命中数 | 代表项目 |
|---|---:|---:|---|
| AI | 20 | 415 | mizchi/bitx_rebase_ai, JQ-ai-nb/robopolicy, colmugx/ai-passport |
| agent | 20 | 88 | totto2727/agent-core-sdk, totto2727/agent-sdk, totto2727/agent-cli-sdk |
| workflow | 20 | 23 | bobzhang/codex_workflow, moonbitlang/workflow, bobzhang/workflow |
| parser | 20 | 255 | moonbitlang/parser, tiye/cirru-parser, illusory0x0/simple_parserc |
| compiler | 20 | 42 | Kaida-Amethyst/MoonLLVM, Milky2018/milkir, Milky2018/machv |
| database | 20 | 44 | Lfan-ke/moondb, moonbitstack/moondb, kath61105/moon_schema_plan |
| web | 20 | 167 | mizchi/js_web, mizchi/crater-webvitals, dijdzv/websys |
| image | 20 | 35 | mizchi/image, gmlewis/image, Nanaloveyuki/image |
| crypto | 20 | 38 | mizchi/experimental_crypto, Kali-Leo/moonbit-CryptoAssert, Tigls/mb-hash |
| testing | 20 | 54 | moonrockz/expect, illusory0x0/inspect, 2d5rrr333/moonwebtest |
| devtool | 13 | 5 | wzzc-dev/moui_devtools, justjavac/cdp, moonbit-community/proton_cdp |
| wasm | 20 | 238 | mizchi/oci_wasm, mizchi/wasmx, Milky2018/wasm_core |
| visualization | 20 | 15 | totto2727/workgraph-visualization, eanzhao/vibe-map, totto2727/moon-agent-graph |

## 项目记录

| 项目/版本 | 作者 | 功能 | 当前版本条目时间 UTC | Star/下载 | 维护判断 | 重叠判断 |
|---|---|---|---|---|---|---|
| [moonbitlang/async](https://mooncakes.io/docs/moonbitlang/async@0.22.4) 0.22.4 | moonbitlang | Asynchronous programming library for MoonBit | 2026-09-24T07:08:17.578592 | 71 / 610830 | 最后推送 2026-10-13T02:41:19Z | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [moonbitlang/workflow](https://mooncakes.io/docs/moonbitlang/workflow@0.10.0) 0.10.0 | moonbitlang | Engine-agnostic multi-agent workflow orchestration with journaled replay/resume | 2026-09-28T01:08:41.165755 | 未知 / 20514 | 未核实最后提交；不能仅按版本号判断 | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [moonbitlang/parser](https://mooncakes.io/docs/moonbitlang/parser@0.4.4) 0.4.4 | moonbitlang | AST and parsers for the MoonBit programming language | 2026-10-12T03:06:22.297896 | 未知 / 未知 | 未核实最后提交；不能仅按版本号判断 | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [moonbitlang/quickcheck](https://mooncakes.io/docs/moonbitlang/quickcheck@0.15.0) 0.15.0 | moonbitlang | Automatic testing of MoonBit programs | 2026-10-12T23:59:20.454318 | 未知 / 189879 | 未核实最后提交；不能仅按版本号判断 | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [bobzhang/openseek](https://mooncakes.io/docs/bobzhang/openseek@0.3.2) 0.3.2 | bobzhang | DeepSeek-backed MoonBit coding agent | 2026-09-13T14:09:28.792947 | 未知 / 未知 | 未核实最后提交；不能仅按版本号判断 | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [weopqrst/agent](https://mooncakes.io/docs/weopqrst/agent@0.5.1) 0.5.1 | weopqrst | MoonBit version of LangChain core library — type-safe, composable, embeddable AI Agent framework. Depends on mizchi/llm for LLM clients. | 2026-08-19T00:56:02.386105 | 1 / 43 | 最后推送 2026-08-24T02:09:03Z | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [colmugx/mcp](https://mooncakes.io/docs/colmugx/mcp@0.18.0) 0.18.0 | colmugx | Type-safe MCP SDK in MoonBit with server/client support and dual transport (STDIO/HTTP) | 2026-10-12T16:19:13.989321 | 未知 / 未知 | 未核实最后提交；不能仅按版本号判断 | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [marianoguerra/mcp](https://mooncakes.io/docs/marianoguerra/mcp@0.10.0) 0.10.0 | marianoguerra | MCP 2026-07-28 protocol types, JSON-RPC codec and SEP-2243 header validation. No dependencies. | 2026-09-08T22:25:19.407169 | 未知 / 185 | 未核实最后提交；不能仅按版本号判断 | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [123123213weqw/moonbit_mcp](https://mooncakes.io/docs/123123213weqw/moonbit_mcp@0.1.0) 0.1.0 | 123123213weqw | A MoonBit SDK for the Model Context Protocol (MCP). Build MCP servers and clients in MoonBit. | 2026-07-24T10:23:51.425999 | 未知 / 未知 | 未核实最后提交；不能仅按版本号判断 | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [2515050242/moonagentcheck](https://mooncakes.io/docs/2515050242/moonagentcheck@0.2.0) 0.2.0 | 2515050242 | 未提供 | 2026-09-29T15:54:52.131295 | 0 / 未知 | 最后推送 2026-10-10T16:50:39Z | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [0717lee/pixelforge](https://mooncakes.io/docs/0717lee/pixelforge@0.19.0) 0.19.0 | 0717lee | Pure MoonBit image processing library with filters, morphology, color-space operations, affine transforms, drawing, compositing, PNG/GIF/QOI/BMP codecs, TIFF and lossless WebP decoding, and JPEG/WebP encoding adapters. Backend-agnostic (js, wasm-gc, native) with a browser Playground. | 2026-09-29T14:40:08.200211 | 1 / 86 | 最后推送 2026-10-01T05:32:56Z | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [matrix486/moonjail](https://mooncakes.io/docs/matrix486/moonjail@0.1.1) 0.1.1 | matrix486 | Linux least-privilege sandbox planning and runtime for MoonBit | 2026-09-23T12:13:47.120592 | 0 / 6 | 最后推送 2026-09-28T05:06:26Z | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [mizchi/sandbox](https://mooncakes.io/docs/mizchi/sandbox@0.1.3) 0.1.3 | mizchi | In-memory sandbox primitives for MoonBit - virtual filesystem, POSIX emulation, shell | 2026-10-05T03:58:51.126045 | 0 / 未知 | 最后推送 2026-10-05T03:58:26Z | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [mizchi/fswatch](https://mooncakes.io/docs/mizchi/fswatch@0.2.1) 0.2.1 | mizchi | Cross-platform filesystem watcher for MoonBit: FSEvents on macOS, inotify on Linux, polling fallback elsewhere. | 2026-06-29T17:31:45.963066 | 未知 / 未知 | 未核实最后提交；不能仅按版本号判断 | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [i5ting/chokidar](https://mooncakes.io/docs/i5ting/chokidar@0.1.0) 0.1.0 | i5ting | Cross-platform file watching library for MoonBit native target. Port of chokidar v5 with kqueue (macOS/FreeBSD) and inotify (Linux) backends. | 2026-05-18T15:41:16.292149 | 3 / 未知 | 最后推送 2026-05-18T15:43:33Z | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [hevienz/moonbit_libbpf](https://mooncakes.io/docs/hevienz/moonbit_libbpf@0.10.0) 0.10.0 | hevienz | moonbit libbpf bindings | 2026-03-22T04:04:54.96315 | 未知 / 未知 | 未核实最后提交；不能仅按版本号判断 | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [conglinyizhi/moondbus](https://mooncakes.io/docs/conglinyizhi/moondbus@0.1.1) 0.1.1 | conglinyizhi | Pure MoonBit D-Bus protocol implementation — connect, authenticate, call methods, and export objects on the session bus. Only ~40 lines of C for the unix socket. | 2026-09-07T06:59:37.801508 | 未知 / 未知 | 未核实最后提交；不能仅按版本号判断 | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [yadidyc/moonpod](https://mooncakes.io/docs/yadidyc/moonpod@0.2.0) 0.2.0 | yadidyc | A transport-neutral resource policy and audit engine for MoonBit hosts | 2026-09-30T17:25:25.683902 | 0 / 未知 | 最后推送 2026-09-30T17:04:32Z | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [daqing/sqlite](https://mooncakes.io/docs/daqing/sqlite@0.4.0) 0.4.0 | daqing | SQLite3 bindings for latest MoonBit toolchian | 2026-10-13T00:55:45.440162 | 未知 / 未知 | 未核实最后提交；不能仅按版本号判断 | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [Lfan-ke/moonraft](https://mooncakes.io/docs/Lfan-ke/moonraft@0.6.0) 0.6.0 | Lfan-ke | Raft consensus algorithm implemented in MoonBit. | 2026-09-14T00:02:56.838519 | 未知 / 未知 | 未核实最后提交；不能仅按版本号判断 | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [moonbit-community/rabbita](https://mooncakes.io/docs/moonbit-community/rabbita@0.16.5) 0.16.5 | moonbit-community | functional Web UI framework for MoonBit | 2026-10-14T02:27:32.858877 | 132 / 未知 | 最后推送 2026-10-13T04:48:21Z | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |
| [Xpeng/mooncharts](https://mooncakes.io/docs/Xpeng/mooncharts@0.8.0) 0.8.0 | Xpeng | Lightweight native SVG charting library for MoonBit — bar, line, pie/donut and scatter charts. | 2026-07-07T15:27:23.230092 | 未知 / 未知 | 未核实最后提交；不能仅按版本号判断 | 与通用候选方向重叠；与 Netlink 内核网络观察无直接重叠 |

## API 与禁止撞车结论

- **Agent/RAG/Prompt**：`weopqrst/agent` 已有 `RunnableWrapper.pipe/map`、`LLMChain`、`AgentExecutor`、检索器、PromptTemplate；OpenSeek 还有真实工具执行与评估入口。禁止再造泛化 Agent/RAG SDK。来源：[项目 README](https://github.com/mihujiang/MoonBit)。
- **MCP**：多个协议 SDK 并存，`marianoguerra/mcp` 分离 codec、server、client、native 传输；`moonbit_mcp` 已有 typed tools/resources/prompts 与 transport。禁止再造基础 MCP SDK。来源：[mcp-mb](https://github.com/marianoguerra/mcp-mb)。
- **工作流**：官方 `moonbitlang/workflow` 已到 0.10.0，带日志、恢复、重放；元数据依赖 async。重做普通 DAG/Agent workflow 无优势。证据：`research/manifest-moonbitlang-workflow.json`。
- **图像/音频/可视化**：pixelforge 已覆盖图像变换与多格式，SVG 图表、图布局、WAV 也已有包，不能只按领域名声称空白。
- **测试/工具**：quickcheck 已有性质测试，moonagentcheck 与官方评估 harness 已存在；细分缺口需要逐项证明。
- **Linux 沙箱/文件监控**：moonjail、chokidar、fswatch、libbpf 均已登记，排除。MoonPod 提供宿主策略与审计，不能把策略层误称 OS 隔离。
- **官方网络 API**：直接查看 `moonbitlang/async` 的 `src/socket/pkg.generated.mbti`，当前公开 TCP、UDP 和 DNS；本次所查 API 没有 AF_NETLINK/route dump/event API。证据：`research/async-api.txt`。
- **剩余可验证缺口**：Linux Netlink 通用报文/TLV 编解码、rtnetlink 结构化查询、事件重放与一致性跟踪；io_uring 也是潜在方向，但 GC 缓冲生命周期与取消语义难度更高。

## 全部关键词返回项目附录

### AI

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| mizchi/bitx_rebase_ai | mizchi | AI-assisted rebase helpers (extension module for mizchi/bit) | 2026-09-21T15:03:37.985106 | https://github.com/mizchi/bit-vcs |
| JQ-ai-nb/robopolicy | JQ-ai-nb | MoonBit AI crawler intent gate with robots evidence, remediation gaps, and release capsules | 2026-08-21T11:10:59.611823 | https://github.com/JQ-ai-nb/robopolicy.git |
| colmugx/ai-passport | colmugx | MoonBit application SDK and host toolchain for supported embedded devices and the Web host. | 2026-09-22T15:23:47.186424 | https://github.com/colmugx/ai-passport.mbt |
| JJ-ai-nb/moonbit-shard-note | JJ-ai-nb | Printable short-message shard cards with checksum validation, multi-parity recovery, diagnostics, and conformance scenarios. | 2026-08-20T07:04:40.459734 | https://github.com/JJ-ai-nb/moonbit-shard-note.git |
| WB-ai-nb/pantrycalc | WB-ai-nb | MoonBit-native recipe scaling, allergen-safe substitution and pantry shopping planner | 2026-08-24T12:50:17.670375 | https://github.com/WB-ai-nb/pantrycalc.git |
| EJJ-ai-nb/harborcheck | EJJ-ai-nb | MoonBit-native README example verifier and open-source provenance proof toolkit | 2026-08-20T05:29:12.866725 | https://github.com/EJJ-ai-nb/harborcheck.git |
| MX-ai-nb/taptrail | MX-ai-nb | Pure MoonBit TAP13 parser, CI validation gate, and Markdown/JSON report renderer. | 2026-08-20T08:01:55.784681 | https://github.com/MX-ai-nb/taptrail.git |
| LMK-ai-nb/permscope | LMK-ai-nb | Audit Permissions-Policy browser capability boundaries in MoonBit. | 2026-09-30T15:14:51.919344 | https://github.com/LMK-ai-nb/permscope.git |
| WB-ai-nb/constraint-lens | WB-ai-nb | A MoonBit engine for reviewer-feedback parsing, novelty matrices, and resubmission plans. | 2026-08-18T17:36:50.914897 | https://github.com/WB-ai-nb/constraint-lens.git |
| WB-ai-nb/reviewproof-kit | WB-ai-nb | MoonBit-native review feedback, overlap disclosure and resubmission proof toolkit | 2026-08-20T06:58:52.120126 | https://github.com/WB-ai-nb/harborcheck.git |
| ZBZ-ai-nb/cakecheck | ZBZ-ai-nb | MoonBit cross-target scenario reproduction matrix and evidence toolkit | 2026-08-24T14:42:04.061232 | https://github.com/ZBZ-ai-nb/cakecheck.git |
| SHX-ai-nb/capsuletrace-upload | SHX-ai-nb | MoonBit-native data retention capsule planner | 2026-08-21T16:26:28.965608 | https://github.com/SHX-ai-nb/capsuletrace-upload.git |
| DWS-ai-nb/termproof | DWS-ai-nb | Streaming ANSI/ECMA-48 terminal log sanitizer and security auditor for MoonBit | 2026-08-20T11:03:21.832214 | https://github.com/DWS-ai-nb/moonbit-readme-ci-mooncakes-io-git-10.git |
| JJ-ai-nb/moonbit-submit-guard | JJ-ai-nb | Audit MoonBit project readiness for hackathon submission review. | 2026-08-16T10:05:55.993974 | https://github.com/JJ-ai-nb/moonbit-submit-guard-clean.git |
| LF-ai-nb/caseweave | LF-ai-nb | Deterministic constrained combinatorial test matrix generator for MoonBit. | 2026-08-21T09:32:18.599696 | https://github.com/LF-ai-nb/caseweave |
| WSH-ai-nb/reslock | WSH-ai-nb | Deterministic resource lockfile and integrity manifest toolkit for MoonBit asset pipelines. | 2026-08-19T17:09:18.454854 | https://github.com/WSH-ai-nb/reslock.git |
| CJR-ai-nb/evowitness | CJR-ai-nb | Minimal compatibility counterexample witness generator for MoonBit | 2026-08-24T14:54:56.152377 | https://github.com/CJR-ai-nb/evowitness.git |
| EJJ-ai-nb/canaryring | EJJ-ai-nb | Deterministic canary rollout planner and blast-radius simulator for MoonBit | 2026-08-21T10:27:16.81893 | https://github.com/EJJ-ai-nb/canaryring.git |
| MM-ai-nb/bech32-kit | MM-ai-nb | Pure MoonBit Bech32/Bech32m codec and SegWit address validator. | 2026-08-20T04:43:34.890701 | https://github.com/MM-ai-nb/bech32-kit.git |
| ZYK-ai-nb/cspkit | ZYK-ai-nb | MoonBit-native Content-Security-Policy parser, auditor, and diff toolkit. | 2026-08-20T06:57:03.392707 | https://github.com/ZYK-ai-nb/mooncake-auditor-public.git |
### agent

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| totto2727/agent-core-sdk | totto2727 | Shared MoonBit process foundation for agent CLIs | 2026-08-23T07:13:05.78754 | https://github.com/totto2727-org/agent-core-sdk |
| totto2727/agent-sdk | totto2727 | Provider-neutral MoonBit interfaces for agent CLI SDKs | 2026-08-23T08:23:10.83552 | https://github.com/totto2727-org/agent-sdk |
| totto2727/agent-cli-sdk | totto2727 | Shared MoonBit process foundation for JSONL agent CLIs | 2026-08-05T11:39:38.344748 | https://github.com/totto2727-org/monorepo |
| totto2727/workgraph-agent-cli | totto2727 | Coding-agent nodes for workgraph | 2026-08-23T08:24:33.373186 | https://github.com/totto2727-org/workgraph |
| poipoiiii/agent-runtime | poipoiiii | Lightweight AI Agent Runtime based on MoonBit | 2026-08-25T00:46:00.238506 | https://github.com/poipoiiii/MoonBit_ws |
| totto2727/moon-agent-graph | totto2727 | Native asynchronous agent graph runtime with Mermaid visualization | 2026-08-05T11:40:01.834984 | https://github.com/totto2727-org/monorepo |
| 2515050242/agentcheck | 2515050242 | 未提供 | 2026-09-06T06:51:47.763526 | https://github.com/2515050242/agentcheck |
| agentdebug799/moonbit-triage | agentdebug799 | Explainable emergency triage scoring primitives for MoonBit. | 2026-08-24T13:15:28.62106 | https://github.com/agentdebug799/moonbit-triage |
| wzzc-dev/moui_agent | wzzc-dev | MoUI agent protocol layer: observable/controllable runtime surface for external agents | 2026-10-06T13:53:28.557712 | 未提供 |
| cybershang/agent-telemetry | cybershang | 未提供 | 2026-07-02T12:55:23.679059 | https://github.com/cybershang/agent-telemetry |
| weopqrst/agent | weopqrst | MoonBit version of LangChain core library — type-safe, composable, embeddable AI Agent framework. Depends on mizchi/llm for LLM clients. | 2026-08-19T00:56:02.386105 | https://github.com/mihujiang/MoonBit |
| PerfectPan/agent-finder | PerfectPan | Read-only local code agent discovery for agent-task-loop. | 2026-06-09T06:57:15.296064 | https://github.com/PerfectPan/agent-task-loop |
| cybershang/agent-o11y-demo | cybershang | 未提供 | 2026-07-08T03:24:31.826897 | https://github.com/cybershang/moonbit-agent-observability |
| wzzc-dev/moui_agent_mcp | wzzc-dev | MCP JSON-RPC router and stdio transport exposing a MoUI AgentHost to external agents | 2026-10-06T13:54:48.697022 | 未提供 |
| totto2727/workgraph-core | totto2727 | Runtime-independent asynchronous graph compiler and runtime | 2026-08-23T08:24:30.758621 | https://github.com/totto2727-org/workgraph |
| Yoorkin/grill-me | Yoorkin | Grill the user relentlessly through a dependency-aware decision-tree interview. | 2026-08-24T03:05:52.515204 | 未提供 |
| Showichiro/moon_openapi_cli | Showichiro | Agent-friendly OpenAPI extraction CLI | 2026-04-22T15:58:42.332188 | https://github.com/Showichiro/moon_openapi_cli |
| peter-jerry-ye/hn-brief | peter-jerry-ye | Hacker News hot-comment briefing demo built with MoonBit async and Wasm | 2026-07-03T09:28:26.779051 | https://github.com/peter-jerry-ye/hn-brief |
| totto2727/workgraph-opencode-cli | totto2727 | OpenCode CLI integration for workgraph | 2026-08-23T08:24:40.48788 | https://github.com/totto2727-org/workgraph |
| 2515050242/moonagentcheck | 2515050242 | 未提供 | 2026-09-29T15:54:52.131295 | https://github.com/2515050242/moonagentcheck |
### workflow

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| bobzhang/codex_workflow | bobzhang | Multi-agent workflow runner for Codex. | 2026-09-28T02:27:00.034228 | https://github.com/bobzhang/codex_workflow |
| moonbitlang/workflow | moonbitlang | Engine-agnostic multi-agent workflow orchestration with journaled replay/resume | 2026-09-28T01:08:41.165755 | https://github.com/moonbitlang/workflow |
| bobzhang/workflow | bobzhang | Engine-agnostic multi-agent workflow orchestration with journaled replay/resume | 2026-09-02T07:50:33.049814 | https://github.com/bobzhang/openseek |
| Lyl66655/moonbit-workflow-engine | Lyl66655 | A hierarchical finite state machine (HSM) and workflow execution engine for MoonBit | 2026-08-16T04:13:36.097174 | https://github.com/Lyl66655/moonbit-statemachine |
| mizchi/bitflow | mizchi | Workflow engine core with Starlark-subset parser, DAG execution, and cache planning primitives. | 2026-10-05T03:58:00.348103 | https://github.com/mizchi/bitflow |
| AlexenderSokolov/moonflowgraph | AlexenderSokolov | A MoonBit task graph and provenance trace library for reproducible research and agent workflows. | 2026-07-13T12:04:42.850567 | https://github.com/AlexenderSokolov/moonflowgraph |
| Yu-zh/codex_worfkow | Yu-zh | Multi-agent workflow runner for Codex. | 2026-01-19T03:26:02.758133 | 未提供 |
| mizchi/actrun | mizchi | MVP GitHub Actions-compatible push CI runner with bitflow lowering, native execution, and bit workspace materialization. | 2026-09-18T04:21:51.648967 | https://github.com/mizchi/actrun |
| mizchi/threads | mizchi | Experimental threads | 2026-02-26T15:33:54.505375 | https://github.com/mizchi/threads |
| black-duck666/moontxnkit | black-duck666 | Deterministic atomic state transitions, MVCC transactions and logical recovery for MoonBit. | 2026-07-17T02:11:53.462063 | https://github.com/black-duck666/MoonTxnKit |
| yadidyc/moonpod | yadidyc | A transport-neutral resource policy and audit engine for MoonBit hosts | 2026-09-30T17:25:25.683902 | https://github.com/yadidyc/moonpod |
| mldong/jeeflow-core | mldong | jeeflow workflow engine core (MoonBit port, zero registry deps) | 2026-10-14T03:23:51.965815 | https://github.com/mldong/jeeflow-moon |
| Milky2018/selene_tools | Milky2018 | CLI tools for Selene workflows. | 2026-04-14T07:40:10.083218 | https://github.com/moonbit-community/selene.git |
| Rz-coder8848/moon-fsm | Rz-coder8848 | An auditable, type-safe workflow state machine library for MoonBit. | 2026-08-16T01:10:18.294033 | https://github.com/Rz-coder8848/MoonBit-FSM |
| totto2727/codex-sdk | totto2727 | MoonBit SDK for embedding the Codex agent in workflows and applications | 2026-08-23T08:13:22.938278 | https://github.com/totto2727-org/codex-sdk |
| peter-jerry-ye/md-outline | peter-jerry-ye | Markdown outline and section reader CLI for agent workflows | 2026-06-12T08:09:41.420586 | https://github.com/peter-jerry-ye/md-outline |
| Ycq-68798/moonbit-icd | Ycq-68798 | MoonBit ICD-10/ICD-11 parsing, catalog queries, delimited import, batch validation, deterministic reports, and CLI workflows. | 2026-08-24T12:52:15.762464 | https://github.com/Ycq-68798/moonbit-icd |
| lllg123/mooncontext | lllg123 | A deterministic context audit tool for LLM and agent workflows | 2026-10-13T10:17:21.301069 | https://github.com/lllg123/mooncontext |
| Lyhdsba/moonforge | Lyhdsba | A MoonBit-native incremental task runner for small builds, codegen workflows, and local CI orchestration. | 2026-08-11T02:44:37.386012 | https://github.com/Lyhdsba/MoonForge |
| illusory0x0/printer | illusory0x0 | A MoonBit AST printer for string serialization of Abstract Syntax Tree nodes from moonbitlang/parser/syntax, designed for code generation and AST visualization workflows. | 2025-10-14T11:02:30.490102 | https://github.com/illusory0x0/illu-printer |
### parser

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| moonbitlang/parser | moonbitlang | AST and parsers for the MoonBit programming language | 2026-10-12T03:06:22.297896 | https://github.com/moonbitlang/parser |
| tiye/cirru-parser | tiye | parser for Cirru Syntax | 2026-04-30T04:26:14.532956 | https://github.com/Cirru/parser.mbt |
| illusory0x0/simple_parserc | illusory0x0 | Monadic parser combinators | 2025-09-23T15:20:01.774586 | https://github.com/moonbit-community/simple_parserc |
| illusory0x0/parserc | illusory0x0 | A simple parser combinator | 2025-05-20T11:11:35.111971 | https://github.com/illusory0x0/parserc.mbt |
| ZSeanYves/doc_parser | ZSeanYves | MoonBit-native document structure foundation for source-native parsing, inspect, validation, and custom tooling | 2026-05-11T07:26:24.642605 | https://github.com/ZSeanYves/markitdown.git |
| bobzhang/html_parser | bobzhang | MoonBit HTML parser and sanitizer ported from JustHTML. | 2026-09-28T04:29:34.841354 | https://github.com/bobzhang/html_parser |
| maria/csv_parser | maria | A robust RFC 4180 compliant CSV parser with support for custom delimiters, quoted fields, and serialization | 2025-11-18T12:32:23.360367 | https://github.com/maria/csv_parser |
| peter-jerry-ye/parser-combinator | peter-jerry-ye | 未提供 | 2024-09-04T02:21:08.851501 | https://github.com/peter-jerry-ye/moonbit-parser-combinator |
| kokic/katex-parser | kokic | A port of the KaTeX parser: lexing and parsing LaTeX math expressions with macro expansion into a typed AST, plus a Unicode rendering backend | 2026-10-02T09:13:42.333731 | https://github.com/kokic/katex-parser |
| maria/json_parser | maria | Fast and compliant JSON parser and serializer for MoonBit supporting the full JSON specification with strict validation, unicode escapes, pretty printing, and detailed error reporting | 2025-11-22T06:47:57.065592 | https://github.com/maria/json_parser |
| f4ah6o/jww_parser | f4ah6o | 未提供 | 2026-09-29T17:43:46.501691 | https://github.com/f4ah6o/jww_parser.mbt.git |
| tonyfettes/json_test_parser | tonyfettes | A lightweight and efficient JSON parser for MoonBit with support for parsing and stringifying JSON data | 2025-11-17T07:45:41.972373 | https://github.com/tonyfettes/json_test_parser |
| bobzhang/html_parser_examples | bobzhang | Runnable examples and documentation for bobzhang/html_parser. | 2026-05-21T03:43:22.933298 | https://github.com/bobzhang/html_parser |
| horideicom/jww_parser | horideicom | 未提供 | 2026-02-06T04:23:10.812938 | https://github.com/horideicom/jww_parser.mbt.git |
| tonyfettes/json_parser | tonyfettes | A complete JSON parser for MoonBit with full spec compliance, error handling, and pretty-printing support | 2025-11-19T10:45:34.391094 | 未提供 |
| tonyfettes/maria_json_parser | tonyfettes | A pure MoonBit JSON parser with comprehensive parsing and serialization capabilities | 2025-11-17T11:35:15.748208 | https://github.com/tonyfettes/maria_json_parser |
| tonyfettes/toml_parser | tonyfettes | A pure MoonBit TOML parser supporting strings, numbers, booleans, arrays, tables, and comments | 2025-11-17T11:53:49.788377 | https://github.com/tonyfettes/toml_parser |
| maria/toml_parser | maria | A complete TOML (Tom's Obvious, Minimal Language) parser implementation in MoonBit with support for all basic types, arrays, tables, and nested structures. | 2025-11-18T12:36:30.481339 | 未提供 |
| Ronlands/ttf_parser_moonbit | Ronlands | High-performance TrueType font parser with modular architecture, supporting TTF/OTF/Variable/Color fonts | 2025-10-27T13:52:01.643099 | https://github.com/Ronlands/ttf_parser_moonbit |
| bzy-debug/json_parser | bzy-debug | A complete JSON parser implementation in MoonBit supporting all JSON data types with comprehensive error handling | 2025-11-17T09:45:13.399577 | https://github.com/bzy-debug/json_parser |
### compiler

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| Kaida-Amethyst/MoonLLVM | Kaida-Amethyst | Moonbit version of LLVM, A Tiny, Friendly Companion to LLVM | 2026-09-10T03:34:18.838221 | https://github.com/moonbitlang/MoonLLVM |
| Milky2018/milkir | Milky2018 | Reusable Cranelift-like SSA intermediate representation | 2026-09-16T04:00:20.873764 | https://github.com/Milky2018/wasmoon.git |
| Milky2018/machv | Milky2018 | Target-neutral semantic machine IR | 2026-08-28T09:37:36.535258 | https://github.com/Milky2018/wasmoon.git |
| Milky2018/regalloc | Milky2018 | Target-independent register allocation algorithm | 2026-09-16T04:00:25.095249 | https://github.com/Milky2018/wasmoon.git |
| Kaida-Amethyst/llvm | Kaida-Amethyst | llvm-c binding for Moonbit with friendly API, keeps the Cpp Style. | 2026-10-14T06:17:27.404365 | https://github.com/moonbitlang/llvm.mbt |
| Milky2018/milkir_machv | Milky2018 | MilkIR-to-MachV lowering | 2026-08-28T09:38:23.720948 | https://github.com/Milky2018/wasmoon.git |
| Milky2018/machv_regalloc | Milky2018 | Target VCode adapter for the reusable register allocator | 2026-08-28T09:38:32.571988 | https://github.com/Milky2018/wasmoon.git |
| Milky2018/vcode | Milky2018 | Target-independent native lowering, VCode, and code-object infrastructure | 2026-09-16T03:59:29.287408 | https://github.com/Milky2018/wasmoon.git |
| Milky2018/vcode_regalloc | Milky2018 | Target VCode adapter for the reusable register allocator | 2026-09-16T04:00:36.933383 | https://github.com/Milky2018/wasmoon.git |
| Milky2018/machv_emit | Milky2018 | Reusable MachV machine-code emitter | 2026-07-14T05:43:23.830186 | https://github.com/Milky2018/wasmoon.git |
| YumeXi/nanocake | YumeXi | Composable, type-safe AST and compiler-pass generation for MoonBit. | 2026-08-18T10:09:15.596513 | https://github.com/PrairieFire2b/nanocake |
| Milky2018/isa_target | Milky2018 | ISA lowering from MilkIR to MachV | 2026-07-07T11:19:25.550535 | https://github.com/Milky2018/wasmoon.git |
| vitro/engine | vitro | MoonBit implementation of the Vitro C teaching engine: 137 diagnostic codes, 135 opcodes, full AST family, byte-for-byte parity with the Rust oracle | 2026-10-04T14:35:02.236407 | https://github.com/rustin-beep/Vitro |
| t-ujiie-g/yxl | t-ujiie-g | A YAML-driven Excel (.xlsx) compiler and CLI — manage spreadsheets as version-controllable YAML with reuse/dedup, built on bobzhang/mbtexcel. | 2026-10-13T23:31:58.127078 | https://github.com/t-ujiie-g/yxl |
| marianoguerra/tailwindcss | marianoguerra | A MoonBit implementation of the Tailwind CSS v4 compiler | 2026-09-08T22:02:47.260076 | https://github.com/marianoguerra/tailwindcss-moonbit |
| Milky2018/aarch64_target | Milky2018 | AArch64 direct MilkIR target pipeline to native code | 2026-09-16T04:00:46.547055 | https://github.com/Milky2018/wasmoon.git |
| ubugeeei/vapor_moon | ubugeeei | Vapor Moon is a MoonBit-first Single File Component compiler and tooling layer built on top of luna.mbt. | 2026-05-18T05:32:35.022105 | https://github.com/ubugeeei/vapor-moon |
| azhzx/qbe | azhzx | QBE reimplemented in MoonBit: the optimizer pipeline plus a programmatic IR builder, an in-memory aarch64 JIT, and LoongArch64/WASM backends | 2026-10-03T10:50:58.183605 | https://github.com/azhzx/qbe.mbt |
| Kaida-Amethyst/MoonMIR | Kaida-Amethyst | Machine IR, support compile llvm module (from MoonLLVM) to different architecture machine code. | 2025-12-02T11:11:32.477527 | https://github.com/moonbitlang/MoonMIR |
| Milky2018/wasm_isa_lower | Milky2018 | WebAssembly MilkIR dialect adapter for MachV lowering | 2026-07-14T05:43:28.942499 | https://github.com/Milky2018/wasmoon.git |
### database

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| Lfan-ke/moondb | Lfan-ke | The standard database-access interface for MoonBit — the driver↔query-layer contract, transliterated from Go's database/sql/driver and Python's DB-API 2.0. ORMs (moonorm) build on it; drivers (moonsqlite / moonpostgres / moonmysql) implement it. | 2026-09-13T23:57:27.796212 | https://github.com/moonbitstack/moonorm |
| moonbitstack/moondb | moonbitstack | The standard database-access interface for MoonBit — the driver↔query-layer contract, transliterated from Go's database/sql/driver and Python's DB-API 2.0. ORMs (moonorm) build on it; drivers (moonsqlite / moonpostgres / moonmysql) implement it. | 2026-09-22T16:56:37.410952 | https://github.com/moonbitstack/moonorm |
| kath61105/moon_schema_plan | kath61105 | Deterministic schema diff, migration planning, and destructive-change gates for MoonBit | 2026-09-19T12:10:55.645733 | https://github.com/kath61105/moon-schema-plan |
| wflixu/Orion | wflixu | Derive + Codegen ORM for MoonBit. Schema DSL, type-safe CRUD, Query Builder. | 2026-04-21T14:44:18.293778 | https://github.com/wflixu/Orion |
| trkbt10/vcdb | trkbt10 | High-performance vector database with multiple ANN algorithms | 2026-07-20T12:09:43.86963 | https://github.com/trkbt10/vcdb_mbt |
| codeworm96/magpiedb | codeworm96 | vibe coded lightweight OLAP database | 2026-04-20T06:57:07.939677 | https://github.com/codeworm96/magpiedb |
| geniuszby/pagelens | geniuszby | Read-only SQLite database and WAL file analyzer written in MoonBit | 2026-08-11T02:10:38.901325 | https://github.com/geniuszby/pagelens |
| yuzhiblue/moon-qdrant | yuzhiblue | A MoonBit client for the Qdrant vector database REST API. | 2026-10-13T13:48:26.771078 | https://github.com/yuzhiblue/moon-qdrant |
| f4ah6o/duckdb | f4ah6o | MoonBit bindings for DuckDB on native and JavaScript targets (Node.js and browser WASM backends) | 2026-09-30T14:46:38.939934 | https://github.com/f4ah6o/duckdb.mbt |
| oboard/morm | oboard | A lightweight MoonBit ORM with typed queries, code generation, and multi-database engines | 2026-09-24T12:18:15.600034 | https://github.com/oboard/morm |
| Lfan-ke/moon-sqlite | Lfan-ke | SQLite driver for moondb/moonorm — native FFI, amalgamation vendored here (isolated). | 2026-08-30T15:38:42.145655 | https://github.com/Lfan-ke/moonorm |
| moonbitstack/moonsqlite | moonbitstack | SQLite driver for moondb/moonorm — native FFI, amalgamation vendored here (isolated). | 2026-09-22T17:01:42.122102 | https://github.com/moonbitstack/moonorm |
| wallll-wal6/moonkv | wallll-wal6 | An append-only key-value storage engine in MoonBit based on Bitcask architecture. | 2026-08-14T15:11:48.5665 | https://github.com/wallll-wal6/MoonKV |
| allain/mongodb | allain | MongoDB binary wire protocol driver for MoonBit | 2026-01-29T18:30:06.080944 | https://github.com/allain/moonbit-mongodb |
| Lfan-ke/moonsqlite | Lfan-ke | SQLite driver for moondb/moonorm — native FFI, amalgamation vendored here (isolated). | 2026-09-13T23:57:30.514844 | https://github.com/moonbitstack/moonorm |
| JIA2JIA2/moonbitgeodb | JIA2JIA2 | 未提供 | 2026-09-28T15:31:22.068606 | 未提供 |
| uiwcvb/moonsql | uiwcvb | A pure MoonBit embedded relational SQL engine | 2026-08-13T15:26:35.950461 | https://github.com/uiwcvb/moonsql |
| shiyukonghui/kingbase-client | shiyukonghui | KingbaseES client for MoonBit: PostgreSQL wire protocol 3.0, SCRAM-SHA-256, text COPY, and a dialect layer for the pg / oracle / mysql / sqlserver compatibility modes | 2026-10-09T13:29:42.852096 | https://github.com/shiyukonghui/kingbase-client |
| Nanaloveyuki/vellum | Nanaloveyuki | Single-file page store. One writer, crash recovery from a write-ahead log. | 2026-10-09T03:24:50.920585 | https://github.com/Nanaloveyuki/vellum |
| Rz-coder8848/moon-neo4j | Rz-coder8848 | A pure-MoonBit Neo4j client: Bolt protocol, PackStream codec, HTTP transactional endpoint, and a typed Cypher query builder. | 2026-09-23T18:06:05.332389 | https://github.com/Rz-coder8848/moon-neo4j |
### web

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| mizchi/js_web | mizchi | web standard api bindings (fetch, Streams, Blob, URL, Crypto, ...) | 2026-09-16T10:43:56.465973 | https://github.com/mizchi/js.mbt |
| mizchi/crater-webvitals | mizchi | Web Vitals metrics helpers for crater | 2026-07-10T14:08:33.460767 | https://github.com/mizchi/crater |
| dijdzv/websys | dijdzv | MoonBit bindings for Web APIs (DOM, HTML, Canvas, WebGL, etc.) | 2026-02-15T15:57:21.006573 | https://github.com/dijdzv/websys.mbt |
| 15614376790/moon-weblink | 15614376790 | RFC 8288 Web Linking and RFC 9264 Linkset parser, serializer, query and audit toolkit for MoonBit. | 2026-08-21T14:17:21.229683 | https://github.com/15614376790/moon-weblink |
| bikallem/webapi | bikallem | Moonbit browser WebApi - dom, fetch, html, xhr, url, svg, uievents and more | 2026-04-06T16:08:57.137275 | https://github.com/bikallem/webapi.git |
| justjavac/webview | justjavac | MoonBit bindings for webview, a tiny library for creating web-based desktop GUIs. | 2025-06-30T14:27:41.174019 | https://github.com/justjavac/moonbit-webview |
| lepus-apps/webview | lepus-apps | A modern desktop application framework based on web technologies. | 2026-06-18T15:33:00.863571 | https://github.com/lepus-apps/lepus_webview |
| wzzc-dev/moui_webview | wzzc-dev | WebView platform view addon for MoUI: wraps platform-native WebView backends (WKWebView, WebKitGTK, WebView2) into MoUI's declarative view tree. | 2026-10-06T13:54:33.130136 | https://github.com/wzzc-dev/moui |
| emadurandal/rhodonite_webgpu | emadurandal | WebGPU abstraction for browser and native targets (RhodoniteMBT). | 2026-05-20T10:33:39.870325 | https://github.com/emadurandal/RhodoniteMBT |
| Yoorkin/webidl | Yoorkin | Whatwg WebIDL parser in MoonBit | 2025-12-31T06:01:27.472943 | https://github.com/moonbit-community/webidl.mbt |
| mizchi/crater-webdriver-bidi | mizchi | WebDriver BiDi adapter module for crater browser integration | 2026-07-10T14:08:31.363245 | https://github.com/mizchi/crater |
| Areo-Joe/webidl | Areo-Joe | A Web IDL parser for MoonBit | 2026-07-26T08:21:40.790318 | https://github.com/Areo-Joe/webidl |
| mizchi/webdriver | mizchi | WebDriver BiDi client library for MoonBit | 2026-10-05T03:58:01.713505 | https://github.com/mizchi/webdriver.mbt |
| KingBes/webui | KingBes | 🚀 moon 绑 定 webui 库。 | 2025-06-25T09:16:27.31835 | https://gitcode.com/KingBes/moon-webui |
| f4ah6o/simple-webauthn | f4ah6o | WebAuthn (FIDO2) implementation for MoonBit - ported from SimpleWebAuthn | 2026-09-29T17:09:58.015425 | https://github.com/f4ah6o/simple-webauthn.mbt |
| mizchi/js_webextensions | mizchi | WebExtensions / chrome.* / browser.* API bindings | 2026-09-16T06:17:29.696786 | https://github.com/mizchi/js.mbt |
| mizchi/webdriver.mbt | mizchi | WebDriver BiDi client library for MoonBit | 2026-02-04T05:04:30.9004 | https://github.com/mizchi/webdriver.mbt |
| shiguri-01/webview | shiguri-01 | Low-level MoonBit bindings to webview/webview | 2026-05-30T01:36:34.378488 | https://github.com/shiguri-01/app.mbt |
| zdu881/webmocket | zdu881 | A simple WebSocket client for MoonBit with pure JSON messaging support | 2025-09-27T12:23:25.460379 | https://github.com/zdu881/webmocket |
| mizchi/webnn | mizchi | WebNN backend and TFLite inference runtime for MoonBit | 2026-07-14T18:23:40.061938 | https://github.com/mizchi/webnn-mbt |
### image

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| mizchi/image | mizchi | Image codec primitives for MoonBit with PNG/BMP/JPEG decode+encode, GIF/WebP/ICO/AVIF encode, and resize. | 2026-07-20T12:22:02.986307 | https://github.com/mizchi/image-mbt |
| gmlewis/image | gmlewis | MoonBit image: simple image representation. | 2026-10-13T10:36:44.174333 | https://github.com/gmlewis/moonbit-image |
| Nanaloveyuki/image | Nanaloveyuki | Pure MoonBit image codecs and icon container encoders. | 2026-09-25T12:19:49.827557 | https://github.com/Nanaloveyuki/image |
| riantr/moonbit_image | riantr | Pure-MoonBit image decoder/encoder covering BMP / QOI / TGA / PNG / GIF / JPEG / ICO / TIFF / FIM with zero external runtime dependencies. Decoders raise a structured `DecodeError` sub-error type so callers can branch on cause (UnsupportedFormat / TruncatedData / InvalidHeader / InvalidValue / EncodeNotImplemented). 0.3.7 re-licensed under MIT only (was `MIT OR Apache-2.0`); see LICENSE-MIT for the full text. | 2026-09-30T15:49:46.270101 | https://github.com/riantr/moonbit_image |
| shunge/image | shunge | 一个纯 MoonBit 实现的图像解码库，支持 BMP/QOI/TGA/PNG/GIF/JPEG 六种格式，内置完整 DEFLATE 解压器和 LZW/RLE 压缩支持，一行代码即可完成图像解码。 | 2026-07-10T14:11:24.143901 | https://github.com/buildliming/moonbit_image |
| bikallem/image | bikallem | 未提供 | 2026-03-27T09:29:59.647839 | https://github.com/bikallem/image.git |
| mizchi/crater-terminal-image-cache | mizchi | Terminal image cache entry format and raster normalization helpers for crater | 2026-07-10T14:07:12.763896 | https://github.com/mizchi/crater |
| walkzzz/image | walkzzz | MoonBit image library: pure MoonBit backend for native/wasm-gc/js/wasm multi-target support. | 2026-10-09T10:04:15.79395 | https://github.com/toadium/stb-image |
| Milky2018/svgdiff-image-compat | Milky2018 | WIP image codec primitives for MoonBit (PNG-first). | 2026-10-13T04:11:05.633433 | https://github.com/moonbit-community/svgdiff |
| Zzqy-yi/firmware-image-toolkit | Zzqy-yi | Validated Intel HEX and Motorola S-record firmware image toolkit | 2026-08-10T12:20:43.347987 | https://github.com/Zzqy-yi/moonbit-firmware-image |
| mizchi/pixelmatch | mizchi | Fast pixel-level image comparison library for MoonBit/WASM | 2026-05-26T10:19:20.788719 | https://github.com/mizchi/pixelmatch |
| 0717lee/pixelforge | 0717lee | Pure MoonBit image processing library with filters, morphology, color-space operations, affine transforms, drawing, compositing, PNG/GIF/QOI/BMP codecs, TIFF and lossless WebP decoding, and JPEG/WebP encoding adapters. Backend-agnostic (js, wasm-gc, native) with a browser Playground. | 2026-09-29T14:40:08.200211 | https://github.com/0717lee/pixelforge |
| riantr/moonbit_labeler | riantr | Image / video labeling backend for the MoonBit Labeler app: 24 async ops over @fs/@json for folder browsing, image IO, label IO, schema normalization (parse/serialize round-trip), class management, and VOC/YOLO/COCO export. The op_handlers are pure async MoonBit functions and can be wired into any IPC layer (Proton/CEF, stdio JSON-RPC, HTTP, WASM, custom bridge). Includes a `dispatch_op(op, payload) -> Json raise` entry point in 0.2.0+ for embedding outside the CEF runtime. | 2026-10-09T10:27:29.812718 | https://github.com/riantr/moonbit-labeler |
| megemini/millow | megemini | A zero-FFI, cross-platform image-processing library for MoonBit. | 2026-07-11T03:45:38.863062 | https://github.com/megemini/Millow |
| Asterless/MoonQOI | Asterless | QOI (Quite OK Image Format) encoder/decoder library for MoonBit | 2025-11-17T02:12:15.46627 | https://github.com/Asterless/MoonQOI |
| hanbings/fluorescence | hanbings | ✨ Fluorescence - A library for dominant color extraction and fuzzy graphics processing. | 2025-03-11T07:36:24.126333 | https://github.com/hanbings/fluorescence |
| yuzhiblue/moon-watermark | yuzhiblue | Image watermark library for MoonBit: visible and invisible traceable watermarks with embed/extract/verify APIs and a CLI. | 2026-10-04T08:23:09.221187 | https://github.com/yuzhiblue/moon-watermark.git |
| Milky2018/svgdiff-pixelmatch | Milky2018 | Fast pixel-level image comparison library for MoonBit/WASM | 2026-10-13T04:11:31.048625 | https://github.com/moonbit-community/svgdiff |
| PingGuoMiaoMiao/MoonVision | PingGuoMiaoMiao | MoonBit-native lightweight image processing and basic computer vision algorithms. | 2026-08-17T05:50:58.398101 | https://github.com/PingGuoMiaoMiao/MoonVision |
| oyjh0381/moonoci | oyjh0381 | Deterministic OCI image layout builder and validator for MoonBit | 2026-08-13T08:56:36.083737 | https://github.com/oyjh0381/MoonBit |
### crypto

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| mizchi/experimental_crypto | mizchi | EXPERIMENTAL — pure-MoonBit cryptography / PKI / JOSE building blocks. Educational reference, not production-grade. No warranty. | 2026-06-02T11:20:51.651438 | https://github.com/mizchi/experimental_crypto |
| Kali-Leo/moonbit-CryptoAssert | Kali-Leo | Multi-chain cryptographic assertion & formal verification library. | 2026-07-30T12:34:08.086298 | https://github.com/Kali-Leo/moonbit-CryptoAssert |
| Tigls/mb-hash | Tigls | Secure hashing for MoonBit (SHA-256, SHA-512; native+WASM) | 2026-04-08T06:21:17.350795 | https://github.com/moonbit-crypto/mb-crypto |
| cc06b/mooncry | cc06b | Pure-MoonBit crypto primitives: SHA-1/2 (incl. SHA-512/224/256), SHA-3, Keccak-256, SHAKE/cSHAKE, BLAKE2b/BLAKE2s/BLAKE3 (+keyed), RIPEMD-160, HMAC/Poly1305/CMAC/KMAC/GMAC, AES-CBC/GCM/CTR/CCM/KW/SIV, ChaCha20/XChaCha20 + Salsa20, HKDF/PBKDF2/scrypt/Argon2, RSA (PKCS1-v1.5/OAEP/PSS), ECDSA P-256, Ed25519/Ed25519ctx/Ed25519ph, X25519, HOTP/TOTP (SHA-1/256/512), SipHash, CRC32/CRC32C/CRC-64/Adler-32, Base64/Hex, sealed-box envelope, Chinese national (GM) cryptography: SM2/SM3/SM4 and ZUC-128/ZUC-256 with 128-EEA3/128-EIA3 (3GPP TS 35.221/222/223), post-quantum: ML-KEM/ML-DSA/SLH-DSA (FIPS 203/204/205), LMS/HSS, XMSS/XMSS^MT, Falcon-512/1024 | 2026-09-20T10:54:43.609452 | github.com/cc06b/mooncry |
| Tigls/mb-getrandom | Tigls | Secure random number generation for MoonBit (OS entropy; native+WASM) | 2026-04-07T18:35:29.35034 | https://github.com/moonbit-crypto/mb-crypto |
| moonbitstack/mooncrypt | moonbitstack | mooncrypt — cryptographic algorithms for MoonBit, one algorithm per package: SHA-1, SHA-2, MD5, HMAC, HKDF, PBKDF2, Ed25519, ECDSA P-256 and RSA PKCS#1 v1.5, on a small set of traits so a third algorithm drops in without touching the library. | 2026-09-22T16:39:04.490386 | https://github.com/moonbitstack/mooncrypt |
| Tigls/mb-hmac | Tigls | HMAC message authentication for MoonBit (HMAC-SHA256, HMAC-SHA512; native+WASM) | 2026-04-10T12:30:41.604126 | https://github.com/moonbit-crypto/mb-crypto |
| Tigls/mb-jwt | Tigls | JWT (JSON Web Tokens) for MoonBit with HS256 signing and verification | 2026-04-10T12:32:28.458432 | https://github.com/moonbit-crypto/mb-crypto |
| oboard/mooncrypto | oboard | MoonBit Crypto Library | 2024-07-30T12:09:43.313495 | https://github.com/oboard/mooncrypto |
| Tigls/mb-chacha | Tigls | ChaCha20 and XChaCha20 stream ciphers for MoonBit (RFC 8439) | 2026-04-10T12:31:31.67784 | https://github.com/moonbit-crypto/mb-crypto |
| Tigls/mb-p256 | Tigls | NIST P-256 elliptic curve (secp256r1) for MoonBit: ECDSA and ECDH | 2026-04-20T18:44:36.981704 | https://github.com/moonbit-crypto/mb-crypto |
| jedisct1/aegis | jedisct1 | AEGIS cipher implementation in Moonbit | 2026-09-16T20:00:11.797079 | https://github.com/jedisct1/moonbit-aegis |
| GMH233/moonpassword | GMH233 | Check the strength of your password. Generate some strong passwords of your own---with many options. | 2025-01-23T15:32:43.379916 | 未提供 |
| bob/aegis | bob | AEGIS cipher implementation in Moonbit | 2024-05-17T06:57:16.599651 | https://github.com/jedisct1/moonbit-aegis |
| 2d5rrr333/toolsfx-moonbit | 2d5rrr333 | Pure-MoonBit crypto & CTF toolbox (a port of ToolsFx): national crypto SM2/SM3/SM4 (GB/T 32905/32907/32918, byte-for-byte standard vectors), encoding toolkit (Base16/32/58/58Check/62/64/85/91, Punycode, URL, radix, QP, UU/XX), classical ciphers with ciphertext auto-detection, and a single-JSON-dispatch workbench shared by the browser frontend and the moon run demo. | 2026-08-24T17:23:15.954082 | github.com/2d5rrr333/toolsfx-moonbit |
| PaiGack/gmsm | PaiGack | 国密算法库的 MoonBit 移植 | 2026-07-30T16:01:41.507933 | https://github.com/PaiGack/moonbit_gmsm.git |
| Q30399/moonvault | Q30399 | MoonVault -- Pure MoonBit password hashing and cryptographic library | 2026-08-12T07:23:54.995438 | https://github.com/Q30399/moonvault |
| illusory0x0/rijndael | illusory0x0 | A MoonBit implementation of the Rijndael (AES) encryption algorithm | 2025-09-06T04:39:44.700555 | https://github.com/moonbit-community/rijndael.mbt |
| ChenJiasen-123/mb-secure-stream | ChenJiasen-123 | MoonBit cryptography and JWT gateway with experimental libsodium-compatible secretstream authenticated encryption and independent interoperability tests. | 2026-10-12T03:07:55.003316 | https://github.com/ChenJiasen-123/mb-secure-stream |
| Rutubet/moon_rsa | Rutubet | A Moonbit implementation of RSA cryptographic algorithm, under development. | 2025-12-01T16:39:49.827266 | https://github.com/moonbit-community/moon_rsa |
### testing

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| moonrockz/expect | moonrockz | A fluent assertion library for MoonBit | 2026-10-13T22:15:21.678506 | https://github.com/moonrockz/expect |
| illusory0x0/inspect | illusory0x0 | A powerful quotation meta programming library that hacks MoonBit's snapshot test system, allowing you to customize `moon test` behavior with automatic source file updates and enhanced testing capabilities. | 2025-09-23T20:38:25.595741 | https://github.com/illusory0x0/illu-inspect.mbt |
| 2d5rrr333/moonwebtest | 2d5rrr333 | Test toolkit for MoonBit wasm-gc web apps: a Node harness that drives your wasm exports over the JSON bridge, a headless-Chromium runner for DOM assertions, and moon-level envelope checks. The tools test themselves against the bundled demo app. | 2026-09-12T02:49:23.162168 | https://github.com/2d5rrr333/moonwebtest |
| LF-ai-nb/caseweave | LF-ai-nb | Deterministic constrained combinatorial test matrix generator for MoonBit. | 2026-08-21T09:32:18.599696 | https://github.com/LF-ai-nb/caseweave |
| Ag108/MoonReduce | Ag108 | Deterministic failure-preserving testcase reduction for MoonBit projects | 2026-09-21T11:04:08.217452 | 未提供 |
| wuhaiting321/moonprobe | wuhaiting321 | A pure-MoonBit declarative API test runner: parses .probe cases, sends HTTP requests, asserts responses, and emits console / JUnit XML reports. | 2026-09-30T16:12:05.15839 | https://github.com/wuhaiting321/MoonProbe |
| z2823253773-p/moontick | z2823253773-p | Audit a fixed-interval sampling plan against observed tick timestamps. | 2026-09-23T10:56:55.80462 | https://github.com/z2823253773-p/moontick |
| kaigeliang/casekit | kaigeliang | Collect and compare MoonBit behavior across compiler backends | 2026-09-28T05:49:26.160035 | https://github.com/kaigeliang/moonbit-casekit |
| moonbitlang/quickcheck | moonbitlang | Automatic testing of MoonBit programs | 2026-10-12T23:59:20.454318 | https://github.com/moonbitlang/quickcheck |
| f4ah6o/turtles | f4ah6o | Mutation testing for MoonBit projects | 2026-10-13T11:35:12.407915 | https://github.com/gpui-mbt/turtles.mbt |
| CAIMEOX/quickcheck | CAIMEOX | Automatic testing of MoonBit programs | 2024-11-18T02:37:53.419876 | https://github.com/moonbitlang/quickcheck |
| kokic/prime | kokic | An efficient implementation of primality testing in MoonBit. | 2026-09-07T13:50:34.397934 | https://github.com/kokic/algol/tree/main/prime |
| Magic486/moon_mutest | Magic486 | Mutation testing toolkit for MoonBit projects | 2026-07-12T09:07:43.389559 | https://github.com/Magic486/moon_mutest |
| paveg/molt | paveg | Simple HTTP load testing CLI built with MoonBit | 2026-04-10T15:54:01.530323 | https://github.com/paveg/molt |
| bobzhang/scrut | bobzhang | CLI testing in Markdown and Cram files (port of facebookincubator/scrut), the engine for `moon cram` | 2026-09-26T15:22:16.600884 | https://github.com/bobzhang/scrut.mbt |
| CAIMEOX/qc_pyext | CAIMEOX | QuickCheck and reference testing extension for Python programs | 2026-01-26T08:08:48.174191 | 未提供 |
| f4ah6o/aletheia | f4ah6o | 未提供 | 2026-01-22T03:01:00.245758 | https://github.com/f4ah6o/aletheia.mbt.git |
| zlhahaha/moonsim | zlhahaha | Deterministic simulation and model testing toolkit for MoonBit. | 2026-07-12T15:26:10.081707 | https://github.com/zlhahaha/moonsim |
| pla678889/moon-experiment | pla678889 | A mature A/B testing analysis library for MoonBit, supporting sample size estimation, sequential testing, metrics comparison and guardrails. | 2026-08-24T09:33:17.253943 | https://github.com/pla678889/moon-experiment |
| aspnmy/moonitest | aspnmy | MoonBit integration test framework - real Docker/TCP/HTTP API via fangyinc/socket + C FFI | 2026-07-12T13:05:34.346865 | https://github.com/aspnmy/moonitest |
### devtool

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| wzzc-dev/moui_devtools | wzzc-dev | Repo-local MoUI inspector snapshot summaries and debug formatters | 2026-10-06T13:53:58.73003 | 未提供 |
| justjavac/cdp | justjavac | MoonBit Chrome DevTools Protocol library | 2026-07-24T15:44:54.921145 | https://github.com/justjavac/moonbit-cdp |
| moonbit-community/proton_cdp | moonbit-community | MoonBit Chrome DevTools Protocol library | 2026-10-10T08:55:41.747354 | https://github.com/moonbit-community/proton |
| justjavac/cdp_examples | justjavac | Examples for justjavac/cdp | 2026-07-24T17:18:47.245443 | https://github.com/justjavac/moonbit-cdp |
| tiye/redstart | tiye | Lightweight process manager for local development | 2026-05-07T11:44:27.199845 | https://github.com/tiye/redstart |
| mizchi/crater-browser | mizchi | Browser engine for crater CSS layout engine | 2026-07-10T14:08:09.118482 | https://github.com/mizchi/crater |
| Suquster/moonbit-pathfinding | Suquster | A MoonBit pathfinding and graph algorithms library with executable documentation, runtime-checked proof predicates, and multi-backend verification gates. Built for OSC 2026. | 2026-07-12T22:38:23.743768 | https://github.com/Suquster/moonbit-pathfinding |
| Ag108/MoonCache | Ag108 | A transport-independent, explainable HTTP cache policy and runtime toolkit. | 2026-08-25T05:01:51.960213 | https://github.com/yzy726/MoonCache |
| Nanaloveyuki/moonview | Nanaloveyuki | Direct native WebView embedding for MoonBit. | 2026-09-25T12:10:56.386708 | https://github.com/Nanaloveyuki/moonview |
| lampclaw/minimoon | lampclaw | A MoonBit UI runtime for WeChat MiniApp Skyline with Elm-style state machines, Val-based UI composition, transactional local state, and generated MiniApp host commands. | 2026-10-08T04:02:22.426713 | https://github.com/lucavance/minimoon |
| lepus-apps/lepus | lepus-apps | A modern desktop application framework based on web technologies. | 2026-09-30T10:05:03.403002 | https://github.com/lepus-apps/lepus |
| hnlyxiaobing/MBOpenClacky | hnlyxiaobing | AI Agent CLI tool rewritten in MoonBit | 2026-08-28T04:51:45.556977 | https://github.com/hnlyxiaobing/MBOpenClacky |
| XiLaiTL/skillpress | XiLaiTL | 把写给 AI 看的 skill 印成给人看的站点：书架树 / 本页目录 / 站内搜索 / 代码高亮，另出 llms.txt 与每页原文 | 2026-10-07T16:43:17.135615 | https://github.com/XiLaiTL/skillpress |
### wasm

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| mizchi/oci_wasm | mizchi | WebAssembly package registry client | 2026-10-05T03:58:02.846724 | https://github.com/mizchi/oci_wasm |
| mizchi/wasmx | mizchi | Experimental fork of moonbitlang/wasm5. WebAssembly VM built with pure MoonBit. | 2026-02-11T11:26:56.022149 | https://github.com/mizchi/wasmx |
| Milky2018/wasm_core | Milky2018 | Reusable WebAssembly specification model for parsers, validators, and frontends | 2026-09-16T03:59:19.703427 | https://github.com/Milky2018/wasmoon.git |
| Milky2018/wasm_milkir | Milky2018 | WebAssembly dialect adapter for MilkIR extension operations | 2026-09-16T04:00:31.394146 | https://github.com/Milky2018/wasmoon.git |
| Milky2018/wasmoon | Milky2018 | A slow and insecure runtime for WebAssembly | 2026-09-16T04:01:08.393364 | https://github.com/Milky2018/wasmoon.git |
| Milky2018/wasmoon_jit | Milky2018 | Wasmoon-specific JIT integration and native runtime glue | 2026-09-16T04:00:56.920333 | https://github.com/Milky2018/wasmoon.git |
| Milky2018/wasm_machv | Milky2018 | WebAssembly MilkIR dialect adapter for target-neutral MachV | 2026-08-28T09:38:50.435405 | https://github.com/Milky2018/wasmoon.git |
| Milky2018/wasm_component | Milky2018 | Portable WebAssembly Component Model syntax and validation | 2026-09-16T04:00:02.474297 | https://github.com/Milky2018/wasmoon.git |
| Milky2018/wasm_isa_lower | Milky2018 | WebAssembly MilkIR dialect adapter for MachV lowering | 2026-07-14T05:43:28.942499 | https://github.com/Milky2018/wasmoon.git |
| mizchi/crater-wasm | mizchi | Wasm bindings and WIT-facing facade for crater | 2026-07-10T14:08:24.566533 | https://github.com/mizchi/crater |
| AdUhTkJm/wasmtools | AdUhTkJm | A tool to convert between WebAssembly and WAT. | 2025-07-13T10:06:25.729543 | 未提供 |
| illusory0x0/moonbit-wasm-nodejs-ts-template | illusory0x0 | moonbit node.js wasm app template | 2025-02-04T12:16:29.879532 | https://github.com/moonbit-community/moonbit-wasm-nodejs-ts-template |
| suiyunonghen/wasmMemManager | suiyunonghen | wasm的线性内存管理 | 2025-03-28T03:15:02.845168 | https://github.com/suiyunonghen/wasmMemManager |
| clbbbb/moonbit-wasm-inspect | clbbbb | A MoonBit-native WebAssembly binary inspection and analysis library. | 2026-08-22T14:45:34.409007 | https://github.com/clbbbb/moonbit-wasm-inspect |
| mizchi/wasmtime | mizchi | Wasmtime C API bindings for MoonBit (native target) | 2026-04-25T13:26:23.454891 | https://github.com/mizchi/wasmtime.mbt |
| tonyfettes/wasm | tonyfettes | 未提供 | 2025-03-18T11:10:25.644457 | 未提供 |
| moonbitlang/wasm4 | moonbitlang | An opinionated binding for WASM-4, a retro game framework using WebAssembly | 2025-11-18T02:28:47.869535 | https://github.com/moonbitlang/wasm4 |
| bobzhang/crescent_wasm_demo | bobzhang | A minimal Crescent web server that also builds for the wasm target. | 2026-09-27T12:33:34.931751 | https://github.com/moonbit-community/crescent |
| illusory0x0/moonbit-wasm-vite-ts-template | illusory0x0 | moonbit vite template | 2025-02-04T14:37:17.948734 | https://github.com/moonbit-community/moonbit-wasm-vite-ts-template |
| felix-schultz/flow-like-wasm-sdk | felix-schultz | SDK for building Flow-Like WASM nodes in MoonBit | 2026-02-20T12:02:10.299211 | 未提供 |
### visualization

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| totto2727/workgraph-visualization | totto2727 | Runtime-independent workgraph visualization | 2026-08-23T08:24:36.26289 | https://github.com/totto2727-org/workgraph |
| eanzhao/vibe-map | eanzhao | DAG-based progress visualization for vibe coding — Lean 4 region map style | 2026-06-03T08:45:13.723849 | https://github.com/eanzhao/vibe-map |
| totto2727/moon-agent-graph | totto2727 | Native asynchronous agent graph runtime with Mermaid visualization | 2026-08-05T11:40:01.834984 | https://github.com/totto2727-org/monorepo |
| shop1111/frontierlab | shop1111 | A MoonBit algorithm trace protocol and polished offline HTML visualization kit. | 2026-08-10T05:18:22.712773 | https://github.com/shop1111/FrontierLab.git |
| hxiuzheng/moon_diffusion_lab | hxiuzheng | A 1D/2D toy diffusion model experimentation and visualization lab in MoonBit | 2026-08-16T15:02:55.516096 | https://github.com/hxiuzheng/MoonDiffusionLab |
| 668xin/moonbit-chart | 668xin | A native MoonBit SVG chart library with light/dark theme, CLI tool and Markdown to HTML converter | 2026-07-17T14:17:01.419121 | https://github.com/668xin/moonbit-chart |
| Xpeng/mooncharts | Xpeng | Lightweight native SVG charting library for MoonBit — bar, line, pie/donut and scatter charts. | 2026-07-07T15:27:23.230092 | https://github.com/pxgt/mooncharts |
| Mitsuha11zz/MoonChartSVG | Mitsuha11zz | 纯 MoonBit 实现的 SVG 图表生成库，支持柱状图、折线图、饼图、散点图、雷达图、面积图、堆叠柱状图、水平柱状图、环形图共9种图表类型，零依赖，Builder API 设计。 | 2026-07-10T11:44:57.6439 | https://gitlink.org.cn/Mitsuha/MoonChartSVG |
| cn-cheems/moonnavkit | cn-cheems | Weighted path planning, multi-goal flow fields, and search visualization for MoonBit. | 2026-07-05T19:09:35.252704 | https://github.com/cn-cheems/moonnavkit |
| weedmind-6812/moonbit-color | weedmind-6812 | Comprehensive color manipulation library for MoonBit - color space conversions, interpolation, contrast calculation, and palette generation | 2026-09-16T02:36:08.987864 | https://github.com/weedmind-6812/moonbit-color |
| gywcs101/moonflame | gywcs101 | Render folded stack profiles into interactive SVG flame graphs. | 2026-09-29T13:32:56.599364 | https://github.com/gywcs101/moonflame |
| JunJunTnT/moonchart | JunJunTnT | A statistical chart SVG generation library for MoonBit. Supports bar charts, line charts, scatter plots with error bars and multi-series rendering. | 2026-07-17T05:04:43.831021 | https://github.com/JunJunTnT/moonchart |
| hzc-666-ai/moonpathfinding | hzc-666-ai | A pure MoonBit pathfinding library with 9 algorithms, graph and grid support, path smoothing, and visualization | 2026-08-01T07:53:45.396239 | https://github.com/hzc-666-ai/MoonPathfinding-MoonBit |
| oilleelssq-wq/moonsatkit | oilleelssq-wq | Pure MoonBit toolkit for satellite orbit data, pass prediction, and visualization | 2026-08-23T16:49:21.010348 | https://github.com/oilleelssq-wq/MoonSatKit |
| illusory0x0/printer | illusory0x0 | A MoonBit AST printer for string serialization of Abstract Syntax Tree nodes from moonbitlang/parser/syntax, designed for code generation and AST visualization workflows. | 2025-10-14T11:02:30.490102 | https://github.com/illusory0x0/illu-printer |
| cosettese/moonchartkit | cosettese | Accessible SVG and Markdown report artifacts for MoonBit. | 2026-07-06T02:10:13.400361 | https://github.com/cosettese/moonchartkit |
| dowdiness/graphviz | dowdiness | Parser, layout engine, and SVG renderer for Graphviz DOT graphs | 2026-04-21T13:41:19.354333 | https://github.com/dowdiness/graphviz |
| mizchi/actrun | mizchi | MVP GitHub Actions-compatible push CI runner with bitflow lowering, native execution, and bit workspace materialization. | 2026-09-18T04:21:51.648967 | https://github.com/mizchi/actrun |
| cg-zhou/drawille | cg-zhou | MoonBit port of drawille for terminal graphics with Unicode Braille characters | 2026-05-08T02:10:39.562438 | https://github.com/cg-zhou/moon-drawille |
| Ridge-Lab/moonwavkit | Ridge-Lab | MoonBit-native WAV parser, PCM decoder, waveform analysis, validation, and audio utility toolkit. | 2026-08-20T05:10:54.940166 | https://github.com/Ridge-Lab/MoonWavKit.git |
### netlink

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
### rtnetlink

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
### io_uring

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| ZSeanYves/bufferutils | ZSeanYves | Zero-copy shared byte buffers with high-performance synchronous, native, and async I/O for MoonBit. | 2026-07-23T10:28:37.621499 | https://github.com/ZSeanYves/BufferUtils.git |
| mizchi/x | mizchi | Cross-platform MoonBit compatibility facades with native delegation and accelerated JS implementations for async IO, bytes, regexp, and JSON. | 2026-09-11T10:28:22.647978 | https://github.com/mizchi/x |
| bobzhang/jsonl | bobzhang | Async reader for JSON Lines (newline-delimited JSON) streams. | 2026-06-02T09:08:42.613926 | https://github.com/bobzhang/jsonl |
| Milky2018/diago | Milky2018 | A diagram toolkit for MoonBit with Dagre, ELK, and Railway layout engines, rendering SVG, ASCII, and Unicode outputs. | 2026-10-13T04:15:24.187382 | https://github.com/moonbit-community/diago |
| moonbitlang/jsonl | moonbitlang | Async reader for JSON Lines (newline-delimited JSON) streams. | 2026-09-28T02:02:24.69884 | https://github.com/moonbitlang/jsonl |
| Lfan-ke/raft-moonbit | Lfan-ke | Raft consensus algorithm implemented in MoonBit. | 2026-07-26T19:38:49.498952 | https://github.com/Lfan-ke/raft-moonbit |
| bobzhang/atd | bobzhang | A MoonBit port of ATD (Adaptable Type Definitions) with a MoonBit code generator | 2026-10-02T02:32:38.408443 | https://github.com/bobzhang/atd.mbt |
| quelgar/lunar-reactor | quelgar | Asynchronous reactive streams library for Moonbit | 2026-08-20T11:40:54.635809 | https://github.com/quelgar/lunar-reactor |
| hackwaly/moonback | hackwaly | A web backend framework for MoonBit | 2026-08-19T03:42:21.871674 | 未提供 |
| moonbitlang/pdflite | moonbitlang | Byte-oriented PDF reading, writing, and manipulation toolkit for MoonBit. | 2026-10-13T11:30:11.540049 | https://github.com/moonbitlang/pdflite |
| bikallem/compress | bikallem | Compression library for MoonBit: flate, gzip, zlib, lzw, bzip2, snappy, lz4, zstd, brotli | 2026-03-25T21:59:29.558509 | https://github.com/bikallem/compress.git |
| ihb2032/MoonFrame | ihb2032 | A lightweight DataFrame and tabular-data library for MoonBit | 2026-10-02T01:26:40.799407 | https://github.com/ihb2032/MoonFrame |
| Magic486/moon_mutest | Magic486 | Mutation testing toolkit for MoonBit projects | 2026-07-12T09:07:43.389559 | https://github.com/Magic486/moon_mutest |
| ZSeanYves/MoonbitHTTP | ZSeanYves | Streaming HTTP protocol suite for MoonBit with HTTP/1.1, HTTP/2, HTTP/3, QUIC, TLS integration, and policy-driven transports. | 2026-10-07T06:57:33.416382 | https://github.com/ZSeanYves/MoonbitHTTP |
| sbqrre/moonbit-mcu-hal | sbqrre | MoonBit Microcontroller Hardware Abstraction Layer & Simulation Suite | 2026-08-23T06:58:30.451658 | https://github.com/sbqrre/moonbit-mcu-hal |
| gmlewis/spin-moonbit-sdk | gmlewis | Experimental Spin SDK for the MoonBit programming language. | 2026-10-13T10:34:39.660141 | https://github.com/gmlewis/spin-moonbit-sdk |
| bobzhang/asciidoctor | bobzhang | A port of Asciidoctor (AsciiDoc processor) to MoonBit | 2026-10-02T09:58:24.549038 | https://github.com/bobzhang/asciidoctor.mbt |
| PingGuoMiaoMiao/MoonVision | PingGuoMiaoMiao | MoonBit-native lightweight image processing and basic computer vision algorithms. | 2026-08-17T05:50:58.398101 | https://github.com/PingGuoMiaoMiao/MoonVision |
| IvanAXu/BioSeqs | IvanAXu | 未提供 | 2026-08-16T18:18:00.229089 | 未提供 |
| hyl-star/moonsic | hyl-star | A MoonBit music IR and interoperability library with MIDI, MusicXML, WAV, and browser event export. | 2026-07-12T13:38:03.633581 | https://github.com/hyl-star/moonsic |
### sandbox

| 包 | 作者 | 说明 | 版本条目 UTC | 仓库 |
|---|---|---|---|---|
| mizchi/sandbox | mizchi | In-memory sandbox primitives for MoonBit - virtual filesystem, POSIX emulation, shell | 2026-10-05T03:58:51.126045 | https://github.com/mizchi/sandbox.mbt |
| matrix486/moonjail | matrix486 | Linux least-privilege sandbox planning and runtime for MoonBit | 2026-09-23T12:13:47.120592 | https://github.com/matrix486/moonjail |
| Haoxincode/moonbash | Haoxincode | Zero-dependency pure-memory POSIX Shell sandbox | 2026-04-18T09:44:17.228016 | https://github.com/Haoxincode/MoonBash |
| tuya-me/aegisrun | tuya-me | AegisRun - AI Agent Secure Tool Runtime (MoonBit + Wasm) | 2026-07-17T09:52:25.375224 | https://gitlink.org.cn/tuya/AegisRun |
| bobzhang/myshell | bobzhang | A small shell-free process EDSL for MoonBit | 2026-08-17T09:44:10.752557 | https://github.com/bobzhang/myshell |
| mizchi/crater-browser-http | mizchi | HTTP, cache, cookie, and request sandbox helpers for crater browser | 2026-07-10T14:05:26.082202 | https://github.com/mizchi/crater |
| mizchi/pkf | mizchi | A Pkl-native task runner with a pure MoonBit implementation. | 2026-08-30T12:37:07.657471 | https://github.com/mizchi/pkfire |
| totto2727/codex-sdk | totto2727 | MoonBit SDK for embedding the Codex agent in workflows and applications | 2026-08-23T08:13:22.938278 | https://github.com/totto2727-org/codex-sdk |
| peter-jerry-ye/codex | peter-jerry-ye | Codex SDK, with some useful tools for building AI applications. | 2026-06-11T07:49:52.261112 | https://github.com/moonbit-community/codex-sdk |
| mizchi/pkl | mizchi | Pure MoonBit parser, interpreter, and typechecker experiments for Apple's Pkl language. | 2026-08-29T15:14:21.046142 | https://github.com/mizchi/pkl-mbt |
| bobzhang/loop_invariants | bobzhang | Comprehensive collection of algorithms and data structures with well-documented loop invariants for correctness reasoning | 2026-09-28T06:39:45.54595 | https://github.com/moonbit-community/loop_invariants |
| ZSeanYves/moonjinja | ZSeanYves | A Jinja-style runtime template engine for MoonBit | 2026-07-23T12:09:01.593356 | https://github.com/ZSeanYves/moonjinja.git |
| bobzhang/scheme | bobzhang | Run R6RS Scheme programs directly with moonx | 2026-09-28T01:07:53.756453 | https://github.com/moonbit-community/moonbit-scheme-r6rs |
| moonbitlang/workflow | moonbitlang | Engine-agnostic multi-agent workflow orchestration with journaled replay/resume | 2026-09-28T01:08:41.165755 | https://github.com/moonbitlang/workflow |
| mizchi/actrun | mizchi | MVP GitHub Actions-compatible push CI runner with bitflow lowering, native execution, and bit workspace materialization. | 2026-09-18T04:21:51.648967 | https://github.com/mizchi/actrun |
| bobzhang/codex_workflow | bobzhang | Multi-agent workflow runner for Codex. | 2026-09-28T02:27:00.034228 | https://github.com/bobzhang/codex_workflow |
| Across2005/harness-self-evolution | Across2005 | 面向 DeepSeek Harness（DSH）的全盘自进化 stdio MCP 插件（MoonBit 原生）：16 个工具完成 扫描→监控→提案→审批→执行 闭环，含子 Agent 工厂与只读运行时快照；人工审批闸门；真实子进程执行在事务性 adapter 落地前 fail closed，失败只回滚提案状态。v3.0 起 DSH 单宿主，v3.1 启动路径可移植化，v3.2 注入面 + M7 安全闸门。 | 2026-09-30T05:18:00.983809 | https://github.com/Across2005/harness-self-evolution-plugin |
| daqing/moon-pay-sdk | daqing | Native MoonBit SDK for WeChat Pay and Alipay | 2026-10-08T09:26:03.385079 | https://github.com/daqing/moon-pay-sdk |
| totto2727/moon-agent-graph | totto2727 | Native asynchronous agent graph runtime with Mermaid visualization | 2026-08-05T11:40:01.834984 | https://github.com/totto2727-org/monorepo |
| bobzhang/openseek | bobzhang | DeepSeek-backed MoonBit coding agent | 2026-09-13T14:09:28.792947 | https://github.com/bobzhang/openseek |
