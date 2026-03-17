# Project Overview
- 名称：komorebi_app
- 目标：跑在手机上的 3D 数据人形象的大模型
- 技术栈：Flutter + Rust (flutter_rust_bridge)

# Key Links
- Flutter 入口：`lib/main.dart`
- Rust crate：`rust/`
- Rust ↔ Flutter 配置：`flutter_rust_bridge.yaml`
- Rust 构建工具说明：`rust_builder/README.md`

# 项目结构说明（目录与文件职责）

以下基于当前工程实际目录与文件，便于开发者快速理解层级与职责；**生成文件请勿手改**，业务只改标注为「可编辑」的部分。

```
komorebi_app/                    # 项目根目录
├── lib/                         # Flutter 应用源码（Dart）
│   ├── main.dart                 # 【可编辑】应用入口、统一日志 appLog、全局异常捕获、MyApp
│   ├── data/
│   │   ├── imu/
│   │   │   └── imu_repository.dart # 【可编辑】IMU 数据层，负责封装对接底层 Rust 姿态解算
│   │   └── log/
│   │       └── log_repository.dart # 【可编辑】日志数据层，管理日志流与内存存储
│   ├── ui/
│   │   ├── landing/
│   │   │   └── landing_page.dart    # 【可编辑】应用入口页/引导页，包含品牌介绍与能力状态板
│   │   ├── home/
│   │   │   └── feature_page.dart    # 【可编辑】核心展示页，整合了 IMU 对比看板与日志面板
│   │   ├── imu/
│   │   │   └── imu_page.dart        # 【可编辑】IMU 对比看板 UI 组件
│   │   └── log/
│   │       └── log_page.dart        # 【可编辑】原极简日志展示页面（已拆分到展示页复用）
│   ├── view_model/
│   │   ├── imu_view_model.dart   # 【可编辑】IMU 数据流状态管理，遵循 MVVM 仅调用 Repository
│   │   └── log_view_model.dart   # 【可编辑】日志逻辑层，对接 UI 和 Repository 触发 Rust
│   └── src/rust/                 # flutter_rust_bridge 生成代码，勿手改
│       ├── frb_generated.dart    # FRB 运行时与入口（如 RustLib.init）
│       ├── frb_generated.io.dart # 桌面/移动端 FFI 实现
│       ├── frb_generated.web.dart# Web 端实现
│       └── api/
│           └── simple.dart       # 对 rust/src/api/simple.rs 的 Dart 绑定（greet, mayFail, createLogStream, triggerRefreshLog 等）
│
├── rust/                         # Rust 库（与 Flutter 桥接的业务与基础设施）
│   ├── Cargo.toml                # 【可编辑】crate 依赖（如 flutter_rust_bridge、once_cell）
│   ├── Cargo.lock                # 依赖锁定，一般自动维护
│   └── src/
│       ├── lib.rs                # 【可编辑】仅声明模块：pub mod api; mod frb_generated;
│       ├── frb_generated.rs      # 生成代码，勿手改
│       └── api/
│   │           ├── mod.rs            # 【可编辑】声明子模块，如 pub mod simple, imu;
│   │           ├── simple.rs         # 【可编辑】日志流（LogEntry, create_log_stream）、greet、mayFail 等
│   │           └── imu.rs            # 【可编辑】IMU 相关 API，包含姿态解算推送流（create_imu_stream）
│
├── rust_builder/                 # 将 Rust 编译为各平台动态库的 Flutter 插件封装
│   ├── pubspec.yaml              # 声明插件，供主工程依赖
│   ├── android/                  # Android 构建脚本
│   ├── ios/                      # iOS Podspec 等
│   ├── macos/                    # macOS 构建
│   ├── windows/                  # Windows CMake
│   ├── linux/                    # Linux CMake
│   └── cargokit/                 # 调用 Cargo 并产出各平台产物的工具与脚本
│
├── flutter_rust_bridge.yaml      # 【可编辑】FRB 配置：rust_input、rust_root、dart_output
├── pubspec.yaml                  # 【可编辑】Flutter 依赖（含 rust_lib_komorebi_app、flutter_rust_bridge）
├── MEMORY.md                     # 【可编辑】项目记忆：结构说明、日志用法、Timeline、TODO
├── COMMANDS.md                   # 常用命令（如 codegen、运行、清理）可集中写于此
│
├── android/                      # Android 宿主工程（入口 MainActivity 等）
├── ios/                          # iOS 宿主工程
├── windows/                      # Windows 宿主工程
├── macos/                        # macOS 宿主工程
├── linux/                        # Linux 宿主工程
├── web/                          # Web 资源（index.html 等）
│
├── integration_test/             # 集成测试
└── test_driver/                  # 测试驱动
```

**职责速查**

| 层级 | 职责 | 主要可编辑文件 |
|------|------|----------------|
| 根配置 | 应用依赖、FRB 代码生成配置、项目说明 | `pubspec.yaml`, `flutter_rust_bridge.yaml`, `MEMORY.md` |
| Flutter UI/逻辑 | 入口引导、全局异常、业务页面与自适应布局 | `lib/main.dart`, `lib/ui/landing/landing_page.dart`, `lib/ui/home/feature_page.dart` |
| Dart–Rust 绑定 | 由 FRB 根据 Rust API 生成，供 Dart 调用 | `lib/src/rust/**`（仅通过改 Rust + codegen 更新） |
| Rust 业务层 | 日志流、IMU 姿态解算、业务逻辑接口 | `rust/src/api/simple.rs`, `rust/src/api/imu.rs` |
| Rust 构建与插件 | 各平台编译 Rust 并接入 Flutter | `rust_builder/**`（一般沿用模板即可） |
| 各平台宿主 | 启动 Flutter、加载 Rust 动态库 | `android/`, `ios/`, `windows/`, `macos/`, `linux/`, `web/` |

修改 Rust 公开 API 或类型后，需在项目根目录执行 `flutter_rust_bridge_codegen generate`（或项目约定的 codegen 命令），再重新构建/运行，否则会出现 Dart 与 Rust 内容哈希不一致等错误。

# FRB 双向调用说明（Dart ↔ Rust）

FRB（flutter_rust_bridge）实现的是 **Dart 与 Rust 之间的双向通信**：既可以由 Flutter/Dart 主动调用 Rust 函数并拿返回值，也可以由 Rust 在任意时刻向 Dart 推送数据（通过 Stream）。下面用当前工程里的真实代码说明两条链路，方便不熟悉 FRB 的开发者理解如何用好两种语言。

---

## 方向一：Dart 调用 Rust（Flutter 主动调 Rust，拿返回值）

**含义**：在 Flutter 的 UI 或逻辑里，像调用普通 Dart 函数一样调用“由 Rust 实现的函数”，参数和返回值由 FRB 自动做类型转换。

**1. Rust 侧：声明并实现供 Dart 调用的函数**

在 `rust/src/api/simple.rs` 中，用 `#[flutter_rust_bridge::frb(sync)]` 标记的 `pub fn` 会被 codegen 暴露给 Dart，例如：

```rust
/// 演示业务函数：在返回问候语前先打一个日志
#[flutter_rust_bridge::frb(sync)]
pub fn greet(name: String) -> String {
    let file_line = format!("{}:{}", file!(), line!());
    log_from_rust(1, &file_line, &format!("greet called with {name}"));
    format!("Hi, {name}! from Rust {}", name.len())
}

#[flutter_rust_bridge::frb(sync)]
pub fn may_fail(should_fail: bool) -> Result<String, String> {
    // 成功返回 Ok(s)，失败返回 Err(e)；Dart 侧失败时会收到异常，需 try/catch
    if should_fail { Err("simulated failure from Rust".to_string()) } else { Ok("success from Rust".to_string()) }
}
```

- `greet(name: String) -> String`：Dart 调用时传入 `name`，直接拿到 `String` 返回值。
- `may_fail(should_fail: bool) -> Result<String, String>`：Dart 侧成功时拿到 `String`，失败时 FRB 会把它映射为 Dart 的异常，需在 Dart 里 `try/catch`。

**2. Dart 侧：使用 codegen 生成的绑定函数**

运行 `flutter_rust_bridge_codegen generate` 后，会在 `lib/src/rust/api/simple.dart` 中生成对应的 Dart 函数（该文件为自动生成，勿手改），例如：

```dart
String greet({required String name}) =>
    RustLib.instance.api.crateApiSimpleGreet(name: name);

String mayFail({required bool shouldFail}) =>
    RustLib.instance.api.crateApiSimpleMayFail(shouldFail: shouldFail);
```

**3. Flutter 业务代码里直接调用**

在 `lib/main.dart` 中 import 上述 API 后，像调用普通 Dart 函数一样调用即可：

```dart
import 'package:komorebi_app/src/rust/api/simple.dart';

// 同步调用，直接拿到返回值
final message = greet(name: "Tom");

// 可能抛异常，需要 try/catch
try {
  final result = mayFail(shouldFail: false);
} catch (e, s) {
  appLog(layer: 'Flutter', level: 'ERROR', ...);
}
```

**小结**：在 Rust 里写带 `#[frb]` 的 `pub fn`，跑 codegen 后 Dart 侧就会出现对应函数；Flutter 里直接调用即可，实现 **Dart → Rust** 的“主动调用、拿返回值”。

---

## 方向二：Rust 向 Dart 推送数据（Rust 主动推，Dart 用 Stream 接收）

**含义**：Rust 在任意时刻（例如计算完成、或收到事件时）向 Dart 推送一条数据，Dart 通过订阅 Stream 即可收到，无需轮询。本项目中用这条链路实现了“Rust 日志发到 Dart 统一打印”。

**1. Rust 侧：接收 Dart 传进来的“发送端”，并保存起来**

Dart 会先调用一个“创建 Stream”的 Rust 函数，并把 FRB 提供的 `StreamSink<T>` 传进 Rust；Rust 把这个 sink 存到全局（或结构体），之后随时可以往 sink 里 `add` 数据，数据就会出现在 Dart 的 Stream 里。

在 `rust/src/api/simple.rs` 中：

```rust
static LOG_STREAM_SINK: Lazy<Mutex<Option<StreamSink<LogEntry>>>> = ...

/// Dart 调用 createLogStream() 时，FRB 会创建 Stream 并把对应的 Sink 传进本函数
pub fn create_log_stream(sink: StreamSink<LogEntry>) {
    let mut guard = LOG_STREAM_SINK.lock().unwrap();
    *guard = Some(sink);
}

/// 任意时刻在 Rust 里调用，即可向 Dart 推送一条日志
pub fn log_from_rust(level: i32, tag: &str, msg: &str) {
    let entry = LogEntry { time_millis, level, tag: tag.to_string(), msg: msg.to_string() };
    if let Some(sink) = LOG_STREAM_SINK.lock().unwrap().as_ref() {
        let _ = sink.add(entry);   // 这里一 add，Dart 的 listen 就会收到
    }
}
```

**2. Dart 侧：订阅 Stream，收到 Rust 推来的数据**

在 `lib/main.dart` 中，应用启动后先调用 `createLogStream()`（内部会调用 Rust 的 `create_log_stream` 并把当前 Stream 的 Sink 传给 Rust），再对返回的 `Stream<LogEntry>` 做 `listen`：

```dart
Future<void> setupRustLogging() async {
  createLogStream().listen((event) {
    // event 即 Rust 里 sink.add(entry) 的 LogEntry
    final eventTime = DateTime.fromMillisecondsSinceEpoch(event.timeMillis.toInt(), isUtc: true);
    appLog(time: eventTime, layer: 'Rust', level: _levelLabelFromInt(event.level), fileAndLine: event.tag, message: event.msg);
  });
}

// 在 main() 里：await RustLib.init(); 之后调用
await setupRustLogging();
```

**3. 调用顺序与数据流**

1. Flutter 启动 → `RustLib.init()` → `setupRustLogging()`。
2. `createLogStream()` 被调用 → FRB 在底层创建一条 Stream，并把对应的 `StreamSink<LogEntry>` 传给 Rust 的 `create_log_stream(sink)` → Rust 把 `sink` 存到 `LOG_STREAM_SINK`。
3. 之后任意时刻，Rust 代码（例如 `greet` 里）调用 `log_from_rust(...)` → 内部 `sink.add(entry)` → Dart 的 `createLogStream().listen((event) { ... })` 收到 `event`，在回调里用 `appLog` 打印或写文件。

**小结**：Rust 不直接“调 Dart 函数”，而是 **Dart 先把一个“发送端”（StreamSink）交给 Rust，Rust 之后随时往这个发送端里 add 数据，Dart 通过 Stream 的 listen 收到**，实现 **Rust → Dart** 的“主动推送”。

---

## 如何利用两种语言

| 更适合放在 Rust | 更适合放在 Flutter/Dart |
|----------------|------------------------|
| 高性能计算、与系统/硬件/安全相关的逻辑、已有 Rust 库的复用、多端共享的核心算法 | UI、路由、本地状态、与 Flutter 生态的集成、快速迭代的交互逻辑 |
| 在 Rust 里用 `#[frb]` 暴露为函数，或通过 StreamSink 向 Dart 推送数据 | 需要结果时调用 Rust 函数；需要持续接收数据时订阅 Rust 通过 Stream 推来的数据 |

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
- 2026-03-17 [debug-web-panic]:
  - 问题现象：Flutter Web 端在浏览器中运行（python http.server）时出现白屏，控制台报错 `RuntimeError: unreachable`，且未见 "Rust WASM initialized!" 日志。
  - 诊断过程：
    1. **使用 Browser Agent 检查**：确认关键静态资源（JS, WASM）加载正常（200 OK），排除了 404 或 MIME 类型配置问题。
    2. **控制台日志分析**：在开发者工具中捕获到报错堆栈指向 `rust_lib_komorebi_app_bg.wasm`。错误表现为 WASM 级的 `unreachable` 指令，这在 Rust WASM 中通常对应于 `panic`。
    3. **源码排查**：定位到 `rust/src/api/simple.rs` 中使用了 `SystemTime::now()`。标准 WASM 环境（非 WASI）不具备系统时钟支持，调用此 API 会直接触发 panic。
  - 解决方案与进展：
    1. **增强 Flutter 侧异常捕获**：在 `lib/main.dart` 的 `runZonedGuarded` 基础上，针对 `RustLib.init()` 增加了显式的 `try-catch` 块，确保在 WASM 初始化失败时能打印出具体的 Dart 异常及堆栈，而非仅仅是静默白屏。
    2. **制定 Rust 修复计划**：已在 `implementation_plan.md` 中记录修复方案，拟将日志中的时间戳获取改为 WASM 兼容方式（如使用 `js-sys` 获取浏览器时间）或暂时移除。

- 2026-03-15 [ui-landing-entry]:
  - 问题现象：项目需要上线 Web 平台，直接进入功能实验页（原 `HomePage`）缺乏品牌感知和引导。需要一个具备“游戏启动页”风格的入口，向访问者介绍项目目标、当前开发状态，并提供清晰的进入路径。
  - 解决方案：实施了 Web 导向的首页重构方案：
    1. **新建着陆页 `landing_page.dart`**：设计了极简深色科技感 UI，包含 "KOMOREBI" 大标题和副标题。新增了 **CAPABILITY STATUS** 面板，通过状态磁贴直观展示 IMU、Rust Core、LLM 等核心模块的活跃状态（Active/Planned）。
    2. **路由架构解耦**：将原 `home_page.dart` 重命名为 `feature_page.dart` (类名改为 `FeaturePage`)，定位为“功能演示/实验区”。在 `main.dart` 中将初始路由切换为 `LandingPage`。
    3. **视觉风格标准化**：在 `main.dart` 为 `MaterialApp` 配置了完整的深色主题（Material 3 Dark Theme），统一了应用在桌面端与 Web 端的视觉基调，并移除了代码中过时的 `withOpacity`（改为 `.withValues`）并精修了 `const` 约束。
- 2026-03-15 [ui-adaptive-dashboard]:
  - 问题现象：应用主页需要面向未来支持手机、平板、宽带桌面端的多端自由缩放与扩展。原有固定比例的 `Column` 或粗糙的横竖屏切换在添加更多窗格时会导致严重的宽度挤压；并且在宽平台快速 Resize 窗口时，底层（如 Rust）的异步日志上报会导致 Flutter 在进行 Layout 测量时触发严重的同步撞帧（`setState called during build`）崩溃报错。
  - 解决方案：在 `home_page.dart` 与对应的 View Model 进行了系统级的终极自适应架构重构：
    1. **三层跨端宽度断点 (Breakpoints)**：
       - **大屏 (>= 900)**：左主区 + 右侧栏架构，主侧区宽度死锁为强对抗性的 `7:3` 比例，同时内部通过各子 Pane 的垂直 `flex` 权重计算高度，保护大视界展现。
       - **中屏 (600-900)**：自动折行的双列网格布局。当窗格超过两个时自动折行（Row nesting），并利用所在行的最大权重面版动态顶起当前行的弹性行高（`rowFlex`）。
       - **小屏 (< 600)**：小屏幕回归安全的单列垂直堆叠。
    2. **完全解耦的数据组件**：提取了 `AdaptivePane` 泛型实体和壳组件 `_AdaptiveDashboardLayout`，主页只需在 `panes: [...]` 中塞入积木面版及预期弹性比重，壳组件会自动完成测量、截断和精准绘制多端各向分割线。
    3. **微任务状态解耦 (Microtask Decoupling)**：将 `_LogListPanel` 精简为无生命周期包袱的 `StatelessWidget + ListenableBuilder`；在 `LogViewModel.dart` 中，将向上抛出给 UI 层的同步 `notifyListeners()` 强行推迟到当前布局帧结束后的微任务队列（`Future.microtask(...)`）中。这彻底断绝了快速改变窗口大小导致底层数据频繁 Layout 发出的框架测算重绘冲突（Frame racing），实现极简轻量的页面流自适应安全更新机制。
- 2026-03-15 [ui-mvvm-refactor]:
  - 问题现象：用户要求遵循 MVVM 原则，剥离 `ImuViewModel` 中直接调用 Rust API 的逻辑，并将新增的 `ImuPage` 与原来的日志视图集成到同一个页面中，同时保持 `main.dart` 轻量。
  - 执行命令与依赖变更：
    - 运行 `flutter pub add provider` 引入 provider 库作为状态管理（UI 根据数据状态重绘）。
  - 解决方案：
    - 新增 `lib/data/imu/imu_repository.dart` 并将 `updateAhrs` 和 `initAhrs` 的底层 Rust 调用迁移至此。
    - 将 `ImuViewModel` 的依赖从 Rust API 改为 `ImuRepository.instance`。
    - 新增 `lib/ui/home/home_page.dart`，将独立的 `ImuPage` 作为组件嵌入上半部分，并在下半部分拆分并嵌入了实时日志输出列表，使得 `MainNavigation` 可以被删除。
- 2026-03-15 [imu-comparison-view]:
  - 问题现象：需要验证从 Flutter UI 层一路打通到 Rust 底层的交互全链路，要求在 `LogPage` 点击刷新按钮时，先由 `LogViewModel` 在 Flutter 侧输出一条“点击了日志刷新按钮”，再触发 Rust 输出一条带有具体行号的“rust 调用成功”日志，最终双双展示在 UI 流上。后续增加了实现设备姿态流 (Dart vs Rust) 的实时分屏对比实验页面，并在后台通过 `flutter_rust_bridge_codegen generate --watch` 自动维护双端绑定。
  - 执行命令与依赖变更：
    - Flutter 端获取传感器数据：运行 `flutter pub add sensors_plus` 引入 IMU 流读取能力。
    - Rust 端传感器融合过滤算法：运行 `cargo add ahrs nalgebra` 引入 Madgwick 滤波器及所需的高性能矩阵计算依赖。
  - 解决方案：遵循了单向依赖与数据流原则（View → ViewModel → Repository）。首先在 `lib/main.dart` 补充了应用启动日志。接着在 `LogPage` AppBar 增加 IconButton 调用 `_viewModel.refreshLogs()`；在 `LogViewModel` 发送“点击事件”给 `LogRepository` 打印。随后 `LogViewModel` 调用了由 FFI 暴露的 Rust 接口 `triggerRefreshLog()`；其对应的 Rust 原生函数定义于 `rust/src/api/simple.rs`，并在内部通过 `log_from_rust` 推送“rust 调用成功”。之后开始构建 `ImuPage` 以展示横向和纵向传感器读数差异测试，测试表明 FFI 生成即时生效，跨端通信基建非常坚固。
- 2026-03-13 [clock-page]:
  - 问题现象：需要一个简单但直观的 Flutter 页面来作为基础 UI 验证和后续交互实验的载体。
  - 解决方案：在 `lib/main.dart` 中实现 `ClockPage`（StatefulWidget + Timer），作为应用首页（`MyApp` 的 `home`）；`ClockPage` 使用 `Timer.periodic` 每秒更新当前时间，在全黑背景上居中显示大号的 `HH:MM:SS` 和当天日期 `YYYY-MM-DD`，用于验证状态更新、重绘性能和基础 UI 管线工作正常。
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
- [ ] 修复 Rust WASM `SystemTime::now()` 导致的 panic <!-- id: iter_fix_panic -->
- [ ] 验证 Web 端在正确处理异常后能显示基本 UI <!-- id: iter_verify_web -->

## Backlog / 未来计划
- [ ] 集成 `js_sys` 或其他 WASM 兼容的时间库 <!-- id: backlog_wasm_time -->
- [ ] 优化 Web 端 COOP/COEP 头的自动化配置 <!-- id: backlog_web_headers -->
