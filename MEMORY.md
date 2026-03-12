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
- 2026-03-12 [init]: 初始化项目，使用 flutter_rust_bridge 官方模板创建并确认在本机 flutter run 正常

# TODO / Next Steps

## 当前迭代
- [ ] 当前迭代要做的事情

## Backlog / 未来计划
- [ ] 未来计划
