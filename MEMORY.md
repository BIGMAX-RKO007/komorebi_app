# Project Overview
- 名称：komorebi_app
- 目标：跑在手机上的 3D 数据人形象的大模型
- 技术栈：Flutter + Rust (flutter_rust_bridge)

# Key Links
- Flutter 入口：`lib/main.dart`
- Rust crate：`rust/`
- Rust ↔ Flutter 配置：`flutter_rust_bridge.yaml`
- Rust 构建工具说明：`rust_builder/README.md`

# Current State
- 状态：刚完成基础模板初始化，已确认 Flutter + Rust 桥接可运行，尚未开始 3D 相关功能开发。

# Conventions
- 代码风格：写中文注释
- 工作方式：Goal-Driven Development Workflow（目标驱动开发流程）
  - 以目标为导向，前端优先实现交互流程，通过日志或 Mock 确认数据结构，再拆解最小开发单元逐步完成后端实现。  
- Timeline 书写约定：
  - 按日期倒序记录，每条尽量包含「日期 + 标签 + 简短说明」
  - 例如：`2026-03-12 [init]: 初始化项目，验证 flutter_rust_bridge 模板能在本机跑通`
- TODO 书写约定：
  - 只放当前迭代和下一步要做的事，完成后要么勾选，要么移到 Timeline

# Logging Usage（日志使用方式）
- 日志统一输出格式：`[timestamp][layer][level][file:line] message`
  - 例如：
    - `[2025-01-01T12:00:01.123+09:00][Flutter][INFO][main.dart:32] 应用启动`
    - `[2025-01-01T12:00:02.456+09:00][Rust][ERROR][inference.rs:44] OOM: 内存不足`
- Flutter 侧（`lib/main.dart`）：
  - 使用统一入口 `appLog(...)`：
    - `appLog(layer: 'Flutter', level: 'INFO', fileAndLine: 'xxx.dart:line', message: '说明文本');`
  - 全局异常捕获：
    - `FlutterError.onError` 中调用 `appLog(layer: 'Flutter', level: 'ERROR', fileAndLine: 'FlutterError', message: '${details.exception}\n${details.stack}')`
    - `runZonedGuarded` 兜底，在 `onError` 中调用 `appLog(layer: 'Flutter', level: 'ERROR', fileAndLine: 'main.dart:main', message: '$error\n$stack')`
- Rust 侧（`rust/src/api/simple.rs`）：
  - 使用 `log_from_rust(level, tag, msg)` 发送日志到 Dart：
    - `level`：0=DEBUG,1=INFO,2=WARN,3=ERROR（在 Dart 侧由 `_levelLabelFromInt` 转为字符串）
    - `tag`：推荐用 `format!("{}:{}", file!(), line!())`，例如 `simple.rs:48`
    - `msg`：实际日志内容字符串
  - 示例：
    - 正常日志：`log_from_rust(1, &format!("{}:{}", file!(), line!()), "greet called");`
    - 错误日志（同时返回错误给 Dart）：
      - `log_from_rust(3, &format!("{}:{}", file!(), line!()), "simulated failure from Rust");`
      - `return Err("simulated failure from Rust".to_string());`
  - Dart 侧通过 `createLogStream().listen(...)` 接收 `LogEntry`，在 `setupRustLogging` 中统一映射为 `appLog(time: ..., layer: 'Rust', level: _levelLabelFromInt(event.level), fileAndLine: event.tag, message: event.msg)`。

# Timeline & Progress
- 2026-03-13 [logging-test]:
  - 问题现象：需要验证新建的日志与异常处理体系在实际交互中的行为，尤其是 Rust 端出错时是否会同时在 Rust / Flutter 两侧日志中体现。
  - 解决方案：在 `MyApp` UI 中新增两个按钮，分别触发 `mayFail(false)`（成功路径）和 `mayFail(true)`（故意失败）；成功路径下仅输出一条 Flutter INFO 日志；故意失败时，Rust 侧通过 `log_from_rust(3, file!():line!(), "simulated failure from Rust")` 写入一条 Rust ERROR 日志，并将 `Err` 返回给 Dart；Flutter 侧在 `try/catch` 中捕获异常并调用 `appLog(layer: 'Flutter', level: 'ERROR', fileAndLine: 'main.dart:...', message: 'mayFail(true) error: ...')`，从而在控制台看到一对配套的 Rust ERROR + Flutter ERROR 日志，验证了错误链路和统一日志格式生效。
- 2026-03-12 [logging-format]:
  - 问题现象：Flutter 与 Rust 的日志输出格式不一致，Flutter 侧形如 `[0][HomePage] 页面 build 完成`，Rust 侧形如 `rust log: 1773328712759 1 greet greet called with Tom`，不便于统一过滤与搜索。
  - 解决方案：在 `lib/main.dart` 中实现统一日志入口 `appLog`，约定输出格式为 `[timestamp][layer][level][file:line] message`，并提供 `_formatTimestamp` 和 `_levelLabelFromInt` 辅助函数；Flutter 侧调用 `appLog(layer: 'Flutter', level: 'INFO', fileAndLine: 'main.dart:42', message: '页面 build 完成')`；Rust 侧在 `greet` 中使用 `file!()` + `line!()` 生成形如 `simple.rs:48` 的位置信息，通过 `log_from_rust` 发送给 Dart，Dart 在 `setupRustLogging` 中将 `LogEntry` 映射为 `appLog(time: ..., layer: 'Rust', level: 'INFO', fileAndLine: event.tag, message: event.msg)`，从而实现 Flutter / Rust 日志统一格式输出。
- 2026-03-12 [logging]:
  - 问题现象：在为 Flutter + Rust 集成日志系统（Rust 通过 StreamSink 向 Dart 发送日志）时，`flutter run -d windows` 编译 Rust 失败，报错 `unresolved import StreamSink` 和 `type annotations needed`，导致 Rust 动态库 `rust_lib_komorebi_app` 无法构建。
  - 解决方案：在 Rust 侧新增 `LogEntry` 结构体和 `create_log_stream` / `log_from_rust`，使用全局保存的 `StreamSink<LogEntry>` 向 Dart 发送日志；Dart 侧通过 `createLogStream()` 订阅并打印日志。关键修复是：Rust 端 `StreamSink` 必须从 `crate::frb_generated::StreamSink` 导入，而不是直接从 `flutter_rust_bridge` crate 导入，否则会因找不到类型定义而报 unresolved import 和推断错误。
- 2026-03-12 [init]: 初始化项目，使用 flutter_rust_bridge 官方模板创建并确认在本机 flutter run 正常

# TODO / Next Steps

## 当前迭代
- [ ] 当前迭代要做的事情

## Backlog / 未来计划
- [ ] 未来计划
