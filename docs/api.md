# API 与使用约定

导入路径为 `Magic486/moonnetlink/<package>`，已发布版本 0.2.0。公开接口以各包的 `pkg.generated.mbti` 为准；原生接口另见构建器生成的 [native-api.mbti](native-api.mbti)。安装与发布信息见 [交付说明](release.md)。

## 协议解码

`@wire.decode(bytes, endian=...)` 将完整 datagram 解为 `Array[Message]`；`@wire.encode(message, endian=...)` 反向编码。`@wire.decode_attributes` / `encode_attributes` 处理 TLV。默认 Little，真实记录必须传入记录携带的端序。错误统一抛 `ProtocolError`，不会返回截断的成功结果。原始属性的类型标记、载荷和未知字段保留；`Attribute::children` 只接受带 nested 标志的属性。

`@route.decode(message, endian=...)` 返回 `Event`：LinkChanged、AddressChanged、RouteChanged、NeighborChanged、Acknowledged、Done、Overrun、Unknown。变化事件携带 `deleted`。IPv4/IPv6 地址由 `ip_address` 格式化，硬件地址由 `hardware_address` 格式化。IPv6 使用未压缩的有效表示。

`@route.request(kind, sequence)` 生成 Links / Addresses / Routes / Neighbors 的 RTM_GET* dump 请求。解码对象同时提供常用类型化字段和原始 attributes。控制消息区分成功 ACK、负 errno、DONE 和扩展错误文本/偏移。

## 完整查询与观察缓存

`@tracker.Dump::new(sequence, kind)` 创建事务。逐条 `accept(message, endian=...)`，不匹配 seq 返回 false。`status()` 为 Pending、Complete 或 Failed。只有成功 DONE 后 `result()` 才返回结果；ACK 不结束事务，中断、负错误和错误对象类型使事务失败。

`@tracker.State::new()` 创建部分观察缓存。`ingest(bytes, endian=...)` 完整验证一份报文后应用事件；`apply(event, endian=...)` 接受已解码事件并保留多路径路由的原始端序。`mark_stale(reason)` 记录不可自动恢复的失效原因，`view()` 返回对象数组、starts_partial、stale、reasons 和 applied_events。输入及输出的可变属性数组均复制，修改调用方数组不会改变缓存；不可变 Bytes 可共享。复杂路由替换/通配删除应重新查询，不能将事件缓存当作 Linux 路由数据库的完整实现。

## 记录格式

`@journal.line(Record)` 输出一行 JSON；`parse_line` / `parse` 严格读取 v1。Datagram 保存 hex 字节和 Little/Big 端序；Loss 保存失效原因。字符串日志只负责传输，协议内容仍经过相同的 wire/route 解码。单条报文上限 1 MiB。

## Linux 原生接口

`@native.Socket::open(groups=0U)` 打开 NETLINK_ROUTE。普通 dump 用零组；事件组掩码为 `0x555U`。`close()` 可重复调用，也有 finalizer。调用者应主动关闭。

`dump(kind, timeout_ms=5000)` 返回 Capture（events、datagrams、endian），有匹配 DONE、总超时和 4096 份报文预算。`receive(timeout_ms=2000)` 返回 `Bytes?`；None 只表示超时，传输损失抛错误。`send(message)` 是底层接口，不是网络修改便捷 API。`NativeError(message, errno)` 保留平台错误码。原生 socket 只支持 Linux。

CLI 命令见 README。快照的四类查询并非同一时刻；watch 从订阅时开始观察，不自动建立完整基线。记录重放不需要网络权限。

## 0.2.0 新增接口

`@route.decode_next_hops(payload, family, endian=...)` / `Route::next_hops(endian=...)` 返回 index、flags、weight、gateway 与未知属性；weight 为 rtnh_hops+1，必须传入原始端序。短头、长度、padding 和非法 IP 全部检查。依赖网卡删除时，缓存保守清除该路由；复杂路由语义以重新 dump 为准。

`@genl.decode` / `encode` 处理 Generic envelope 与 user header；`family_request` / `decode_family` 处理 controller 元数据。Lookup 要求同 seq/name 的 metadata 和成功 ACK，不能用单个 ACK 假装完成。

`@native.Socket::open(protocol=Generic)` 打开 NETLINK_GENERIC，`family(name)` 返回 FamilyCapture。CLI family/family-replay 为只读 controller 查询与重放；不包含 policy 查询或组订阅。

`@replay.Session` 支持 typed Record、逐行 JSONL 与增量文本；summary 包含 records/datagrams/losses/rejected 和隔离状态视图。失败标记 stale 并抛错，先前完整记录保留。Session 解释 rtnetlink，Generic 使用相应 Lookup；v1 日志不会自动识别协议。
