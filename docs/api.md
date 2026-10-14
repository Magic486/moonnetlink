# API 与使用约定

导入路径为 `Magic486/moonnetlink/<package>`，模块版本 0.1.0。公开接口以各包的 `pkg.generated.mbti` 为准；原生接口另见构建器生成的 [native-api.mbti](native-api.mbti)。安装与发布信息见 [交付说明](release.md)。

## 协议解码

`@wire.decode(bytes, endian=...)` 将完整 datagram 解为 `Array[Message]`；`@wire.encode(message, endian=...)` 反向编码。`@wire.decode_attributes` / `encode_attributes` 处理 TLV。默认 Little，真实记录必须传入记录携带的端序。错误统一抛 `ProtocolError`，不会返回截断的成功结果。原始属性的类型标记、载荷和未知字段保留；`Attribute::children` 只接受带 nested 标志的属性。

`@route.decode(message, endian=...)` 返回 `Event`：LinkChanged、AddressChanged、RouteChanged、NeighborChanged、Acknowledged、Done、Overrun、Unknown。变化事件携带 `deleted`。IPv4/IPv6 地址由 `ip_address` 格式化，硬件地址由 `hardware_address` 格式化。IPv6 使用未压缩的有效表示。

`@route.request(kind, sequence)` 生成 Links / Addresses / Routes / Neighbors 的 RTM_GET* dump 请求。解码对象同时提供常用类型化字段和原始 attributes。控制消息区分成功 ACK、负 errno、DONE 和扩展错误文本/偏移。

## 完整查询与观察缓存

`@tracker.Dump::new(sequence, kind)` 创建事务。逐条 `accept(message, endian=...)`，不匹配 seq 返回 false。`status()` 为 Pending、Complete 或 Failed。只有成功 DONE 后 `result()` 才返回结果；ACK 不结束事务，中断、负错误和错误对象类型使事务失败。

`@tracker.State::new()` 创建部分观察缓存。`ingest(bytes, endian=...)` 完整验证一份报文后应用事件；`apply(event)` 接受已解码事件。`mark_stale(reason)` 记录不可自动恢复的失效原因，`view()` 返回对象数组、starts_partial、stale、reasons 和 applied_events。数组是视图快照，嵌套属性没有深复制保证。复杂路由替换/通配删除应重新查询，不能将事件缓存当作 Linux 路由数据库的完整实现。

## 记录格式

`@journal.line(Record)` 输出一行 JSON；`parse_line` / `parse` 严格读取 v1。Datagram 保存 hex 字节和 Little/Big 端序；Loss 保存失效原因。字符串日志只负责传输，协议内容仍经过相同的 wire/route 解码。单条报文上限 1 MiB。

## Linux 原生接口

`@native.Socket::open(groups=0U)` 打开 NETLINK_ROUTE。普通 dump 用零组；事件组掩码为 `0x555U`。`close()` 可重复调用，也有 finalizer。调用者应主动关闭。

`dump(kind, timeout_ms=5000)` 返回 Capture（events、datagrams、endian），有匹配 DONE、总超时和 4096 份报文预算。`receive(timeout_ms=2000)` 返回 `Bytes?`；None 只表示超时，传输损失抛错误。`send(message)` 是底层接口，不是网络修改便捷 API。`NativeError(message, errno)` 保留平台错误码。原生 socket 只支持 Linux。

CLI 命令见 README。快照的四类查询并非同一时刻；watch 从订阅时开始观察，不自动建立完整基线。记录重放不需要网络权限。
