# 发布与验收材料

## 0.2.0：已发布与独立安装验证

材料日期：2026-10-15。公开源码为 [Magic486/moonnetlink](https://github.com/Magic486/moonnetlink)，注册表版本为 [Magic486/moonnetlink@0.2.0](https://mooncakes.io/docs/Magic486/moonnetlink@0.2.0)，MIT。发布返回 HTTP 200；归档 106 个文件。安装：`moon add Magic486/moonnetlink@0.2.0`。

相对 0.1.0，新增加权多路径解析与依赖清理、Generic Netlink controller discovery 与 metadata/ACK 事务、原生 family 查询及录制重放、增量 replay SDK、缓存属性隔离、可执行文档与实际归档消费者 CI。源码功能冻结后通过 [完整公开 CI](https://github.com/Magic486/moonnetlink/actions/runs/38600644676)，申报复核提交的 [公开 CI](https://github.com/Magic486/moonnetlink/actions/runs/38601791311) 也已通过；最终默认分支状态可在 README 的 CI 徽章查看。

| 验证范围 | 实测结果 |
|---|---|
| 模块测试，官方 2026-10-12 工具链 | Windows WASM-GC/JS 各 87，Linux native 96，deny-warn 通过 |
| 三个跨后端示例 | 合成 7 步、真实 rtnetlink 32 步、真实 nlctrl 1 步，输出逐步一致 |
| Linux 独立查询比较 | link 13、address 21、route 68、neighbor 70；其中 68 个非空硬件地址比较一致 |
| 真实事件与 Generic | 隔离环境 32 条事件重放一致；nlctrl metadata/ACK 重放一致，缺失 family 被拒绝 |
| 实际归档消费 CI | 独立 workspace 另增加 1 项消费者测试，native 编译 C 桥并查询 Route/Generic |
| 公开注册表独立消费 | Windows WASM-GC/JS、Linux WASM-GC/JS/native 各 1 项通过；Linux 返回 13 个 link 事件与 nlctrl |

包消费数不与模块测试数混加。[Linux 实测](test-evidence/v0.2.0-linux.json)、[公开注册表消费](test-evidence/v0.2.0-consumer.json)、[发布记录](test-evidence/v0.2.0-publication.json) 与 [规模口径](test-evidence/source-scale.json) 均保留。0.2.0 包的代码版本与功能冻结提交一致；后续发布证据及申报 PDF 在 GitHub 提供，PDF 不进入 Mooncakes 库归档。

上传范围经过检查：保留源代码、必要 C 桥、文档及隔离 fixture；不含账户凭据、SSH 配置、真实主机网络快照、原始网页抓取、本地工具链、构建产物。仓库另提供一页 [申报书 PDF](../output/pdf/MoonNetlink-proposal-0.2.0.pdf) 与 [Markdown 正文](../submission-proposal.md)。验收准备见 [复核说明](acceptance-review.md)；报名和官方审核仍按赛事流程完成。

## 0.1.0：历史发布基线

源码：[Magic486/moonnetlink](https://github.com/Magic486/moonnetlink)，公开默认分支 `main`。模块版本：`Magic486/moonnetlink@0.1.0`。使用 MoonBit 2026-10-12 或更新的兼容工具链。

[首次通过的公开 CI](https://github.com/Magic486/moonnetlink/actions/runs/38549319992) 使用 2026-10-12 工具链，完整执行格式、WASM-GC/JS 测试、跨后端示例比较、Linux 原生构建/测试及独立集成脚本。它检验的提交为 `d395dad3bef8f151062179302c1680d5069d4c46`。

2026-10-14 已成功发布 [Mooncakes 0.1.0](https://mooncakes.io/docs/Magic486/moonnetlink@0.1.0)。注册表返回 `Magic486/moonnetlink`、版本 `0.1.0`、MIT、上述 GitHub 仓库，未被撤回。

注册表安装：`moon add Magic486/moonnetlink@0.1.0`；导入 `Magic486/moonnetlink/wire` 等子包。

## 独立安装实测

在独立消费模块中通过公开注册表下载 `Magic486/moonnetlink@0.1.0`，没有使用本地 path dependency：

- Windows，2026-10-12 工具链：独立 golden link bytes 经 wire/route 解码、journal 记录、tracker 重放；WASM-GC 与 JavaScript 各 1 项测试通过。
- Linux，同版工具链：独立消费模块 native 测试通过；从注册表包编译 C 桥并运行 `Socket::dump(Links)`，实际返回 13 个网卡事件。
- 上传包的 71 个文件经清单检查，包含必要 C 桥与 fixture；不含构建产物、本机连接脚本、实机网络快照、原始抓取或凭据。公开仓库初次导入 74 个文件。

消费测试、下载归档与本地工具链保持在忽略的工作目录，避免成为库依赖或上传内容。

## 技术交付证据

| 项目 | 证据 |
|---|---|
| MoonBit 主要实现 | wire、route、tracker、journal；C 仅负责系统调用和 I/O |
| 能够运行与测试 | README、两个跨后端示例、54 核心测试与 5 原生测试 |
| 独立验证 | Linux iproute2 字段差分与临时 namespace 的 32 条真实事件 |
| 开源合规 | MIT、THIRD_PARTY、隔离测试数据来源说明 |
| AI 可解释 | architecture、API、development 复盘 |
| 安装与持续检查 | 上述公开 CI 已通过，公开注册表下载与独立消费测试通过 |

原始调研抓取、构建目录、发布临时文件、真实主机网络快照、账户凭据、SSH 连接脚本均不分发；保留独立隔离实验产生的必要 fixture。包与仓库清单在上传前单独检查。

## 赛事流程边界

依据 [当前十月赛官网](https://moonbitlang.github.io/Hackathon2026/)，需公开可追踪开发、README/示例/测试、开源与 AI 说明，并在 2026-10-31 前走报名及验收流程。首次公开源码导入发生在本地 MVP 完成后；不声称此前已公开持续提交。无法补造已有开发历史，后续实际维护记录将如实保留。

本页为技术材料核对，不是官方审核结论。报名的一页说明见根目录 submission-proposal.md。报名表中的个人/团队资料、入群昵称以及赛事方审核需由参赛者完成或另行明确授权。
