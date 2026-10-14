# 验收准备复核

材料日期：2026-10-15。对象：Magic486/moonnetlink 0.2.0，默认分支 main。当前十月赛以 [官方页面](https://moonbitlang.github.io/Hackathon2026/) 为准；旧 OSC 技能的提交数/规模提示用于识别风险，不当作本期硬性门槛。

可核验的技术材料已具备：MoonBit 主要实现、公开源码、真实功能提交、README/示例/测试、MIT/来源、公开 CI、实际包消费。功能冻结时已有 16 条公开实质提交，随后仅记录申报、发布和验证；无空提交、日期改写或历史拆分。

| 条目 | 实际证据 |
|---|---|
| 生态新增 | 初始全量/GitHub 调研；原创协议/事务/重放组件，非 HTTP 或 JSON 包装 |
| 主要语言 | 手写 MoonBit 4,088 物理行（含测试/示例/合成辅助）；实现 2,342 行、测试 1,522 行，生成 fixture 46 行单列 |
| 规模口径 | 手写非空非注释约 3,415 行；生成接口、数据与空行不冒充有效代码，详见 test-evidence/source-scale.json |
| 功能 | 四类对象、多路径、Generic discovery、完成事务、失效、隔离视图、增量重放 |
| 工具链 | 官方 2026-10-12，moon 0.1.20261012 / moonc v0.10.15，按实际版本记录 |
| 测试 | WASM-GC/JS 各 87；Linux native 96，全部通过且 deny-warn |
| 真实验证 | iproute2 差分、32 条隔离事件、nlctrl metadata+ACK、缺失 family 拒绝 |
| 包消费 | 实际 zip 解包至独立 workspace；消费者调用新 API，Linux 构建 C 桥并查询 Route/Generic |
| 公共 CI | [冻结版本 CI](https://github.com/Magic486/moonnetlink/actions/runs/38600644676) 成功，含归档消费检查 |
| 合规 | LICENSE、THIRD_PARTY、fixtures README；抓取、主机记录、连接脚本与凭据不发布 |
| 申报 | 根目录 Markdown ≤30 行，PDF 一页；只使用已验证事实与公开项目账号 |

报名/资格审核、团队资料、入群及开发记录采纳由赛事流程确认。公开开发从首次导入开始，不能将此前本地开发声称为公开持续提交；提交数量不等于官方已经验收。

Generic 本期仅支持 envelope/controller discovery，不实现任意操作或 policy/multicast。缓存始终部分覆盖，跨类快照不原子；多路径依赖删除采用保守清理，不覆盖所有内核路由替换/通配删除语义。

0.1.0 发布记录保留；0.2.0 发布、最终 CI 与注册表消费证据在 release.md 更新。自查不替代官方评审。
