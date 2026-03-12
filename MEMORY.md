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

# Timeline & Progress
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
