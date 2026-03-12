## 0. 一次性环境&模板

- 安装 codegen（全局一次）  
  - `cargo install flutter_rust_bridge_codegen` [lib](https://lib.rs/crates/flutter_rust_bridge_codegen)
- 创建一个 Flutter+Rust 示例工程  
  - `flutter_rust_bridge_codegen create my_app` [pub](https://pub.dev/documentation/flutter_rust_bridge/latest/)
- 进入项目  
  - `cd my_app`  

***

## 1. 开发期：Flutter 侧常用命令

### 1.1 设备与运行

- 查看当前可用设备（包括桌面 / Web / 模拟器 / 真机）  
  - `flutter devices` [docs.flutter](https://docs.flutter.dev/reference/flutter-cli)
- 运行到默认设备  
  - `flutter run` [docs.flutter](https://docs.flutter.dev/reference/flutter-cli)
- 指定设备运行（举例）  
  - `flutter run -d windows`  
  - `flutter run -d chrome`  
  - `flutter run -d edge`  
  - `flutter run -d emulator-5554`（Android 模拟器 ID）  
  - `flutter run -d <device_id>`（任意设备 ID） [docs.flutter](https://docs.flutter.dev/reference/flutter-cli)

### 1.2 Android / iOS 开发期命令（移动端）

- 启动 / 管理模拟器  
  - `flutter emulators`（列出并管理模拟器） [docs.flutter](https://docs.flutter.dev/reference/flutter-cli)
  - `flutter emulators --launch <emulator_id>`  
- 安装/运行到已连接设备  
  - `flutter install -d <device_id>`（只安装，不自动运行） [docs.flutter](https://docs.flutter.dev/reference/flutter-cli)
  - `flutter run -d <device_id>`（调试运行） [docs.flutter](https://docs.flutter.dev/reference/flutter-cli)

***

## 2. 开发期：Rust & flutter_rust_bridge 生成命令

### 2.1 每次修改 Rust 后「手动生成一次」

官方 Quickstart 里的最基本用法： [cjycode](https://cjycode.com/flutter_rust_bridge/quickstart)

- 在项目根目录：  
  - `flutter_rust_bridge_codegen generate`  
  - 然后再：`flutter run`  

你也可以合在一行方便习惯：  

- `flutter_rust_bridge_codegen generate && flutter run` [pub](https://pub.dev/documentation/flutter_rust_bridge/latest/)

> 说明：模板工程里通常自带 `flutter_rust_bridge.yaml`，不需要每次写一堆 `--rust-input/--dart-output` 参数；复杂项目可以在这个 yaml 里配置，命令就保持简短。 [github](https://github.com/fzyzcjy/flutter_rust_bridge/issues/2462)

### 2.2 watch 模式：自动监听 Rust 变化

官方文档提到可以用 `--watch` 自动检测 Rust 源码变更并重新生成绑定： [cjycode](https://cjycode.com/flutter_rust_bridge/quickstart)

- 在项目根目录开一个终端：  
  - `flutter_rust_bridge_codegen generate --watch` [github](https://github.com/fzyzcjy/flutter_rust_bridge/issues/2462)

然后另开一个终端只负责跑 Flutter：

- `flutter run`  

这样你只要保存 Rust 代码，generator 会自动更新 Dart / Rust 绑定，你在 Flutter 窗口里热重载即可看到效果。 [cjycode](https://cjycode.com/flutter_rust_bridge/quickstart)

***

## 3. Web / 桌面 开发与构建

### 3.1 Web 开发

- 开发时直接跑 Web（带 COOP/COEP 头，便于某些特性，比如 WASM）：  
  - `flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp` [cjycode](https://cjycode.com/flutter_rust_bridge/quickstart)
- 仅为 Web 生成绑定（如果你区分 Web 绑定）  
  - `flutter_rust_bridge_codegen build-web` [cjycode](https://cjycode.com/flutter_rust_bridge/quickstart)

### 3.2 桌面开发和构建

- Windows 桌面调试  
  - `flutter run -d windows`  
- 构建 Windows 发布包（`.exe` + 资源）  
  - `flutter build windows` [docs.flutter](https://docs.flutter.dev/platform-integration/windows/building)

（Linux / macOS 类似：`flutter build linux`、`flutter build macos`，前提是平台已启用。） [docs.flutter](https://docs.flutter.dev/platform-integration/windows/building)

### 3.3 Web 构建（部署到服务器）

- 标准 Web release 构建  
  - `flutter build web`  
- 若你有单独 Web 代码生成步骤：  
  - `flutter_rust_bridge_codegen build-web && flutter build web` [cjycode](https://cjycode.com/flutter_rust_bridge/quickstart)

***

## 4. Android 上线相关命令

> 前提：已配置好 `android/app/build.gradle` 中的签名信息、Keystore 等。 [geeksforgeeks](https://www.geeksforgeeks.org/flutter/how-to-build-and-release-flutter-application-in-android-device/)

- Debug 包（本地调试）  
  - `flutter run -d android`（真机/模拟器）  
- Release APK（便于发给测试/用户）  
  - `flutter build apk`  
  - 或拆分 ABI 减小体积：`flutter build apk --split-per-abi` [geeksforgeeks](https://www.geeksforgeeks.org/flutter/how-to-build-and-release-flutter-application-in-android-device/)
- Play Store 用 App Bundle  
  - `flutter build appbundle`  
  - 产物：`build/app/outputs/bundle/release/app.aab` [stackoverflow](https://stackoverflow.com/questions/65640066/flutter-building-appbundle-in-release-mode)

***

## 5. iOS 上线相关命令（在 macOS + Xcode）

- Debug 运行  
  - `flutter run -d ios`（模拟器或真机） [docs.flutter](https://docs.flutter.dev/reference/flutter-cli)
- Release 构建（后续在 Xcode 里 Archive / 上传）  
  - `flutter build ios --release` [docs.flutter](https://docs.flutter.dev/platform-integration/windows/building)

***

## 6. 其他通用 Flutter 工具命令

- 拉取 / 更新依赖  
  - `flutter pub get`  
  - `flutter pub upgrade`  
- 格式化 Dart 代码  
  - `dart format .` 或 IDE 内置格式化 [docs.flutter](https://docs.flutter.dev/reference/flutter-cli)
- 查看所有可用子命令  
  - `flutter help`  
  - `flutter help <subcommand>`（如 `flutter help build`） [docs.flutter](https://docs.flutter.dev/reference/flutter-cli)

***

## 7. 总结版“从 0 到上线”命令流水线

以「Windows + Android + Web」为例，按时间顺序只列关键命令：

1. 一次性：`cargo install flutter_rust_bridge_codegen`  
2. 一次性：`flutter_rust_bridge_codegen create my_app && cd my_app`  
3. 常驻终端 A：`flutter_rust_bridge_codegen generate --watch`（Rust 改动自动生成） [cjycode](https://cjycode.com/flutter_rust_bridge/quickstart)
4. 常驻终端 B：`flutter run -d windows`（或 android / chrome）  
5. 开发中：  
   - 如改 pub 依赖：`flutter pub get`  
   - 如想跑 Web：`flutter run -d chrome ...`  
6. 准备发布时：  
   - Windows：`flutter build windows`  
   - Web：`flutter_rust_bridge_codegen build-web && flutter build web`  
   - Android：`flutter build apk --split-per-abi` / `flutter build appbundle`  
   - iOS（如需要）：`flutter build ios --release`  

***