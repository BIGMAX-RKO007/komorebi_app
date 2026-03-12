import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komorebi_app/src/rust/api/simple.dart';
import 'package:komorebi_app/src/rust/frb_generated.dart';

/// 应用统一的日志入口
/// 目标格式：
/// [timestamp][layer][level][file:line] message
/// 例如：
/// [2025-01-01T12:00:01.123+09:00][Flutter][INFO][main.dart:32] 应用启动
/// [2025-01-01T12:00:02.456+09:00][Rust][ERROR][inference.rs:44] OOM: 内存不足
void appLog({
  DateTime? time,
  required String layer, // Flutter / Rust / 其它
  required String level, // INFO / ERROR / DEBUG / WARN
  required String fileAndLine, // 形如 main.dart:32 或 simple.rs:48
  required String message,
}) {
  final now = time ?? DateTime.now();
  final ts = _formatTimestamp(now);

  // ignore: avoid_print
  print('[$ts][$layer][$level][$fileAndLine] $message');
}

/// 将 DateTime 格式化为 `YYYY-MM-DDTHH:MM:SS.mmm+HH:MM`
String _formatTimestamp(DateTime time) {
  final local = time.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');

  final year = local.year.toString().padLeft(4, '0');
  final month = two(local.month);
  final day = two(local.day);
  final hour = two(local.hour);
  final minute = two(local.minute);
  final second = two(local.second);
  final millisecond = local.millisecond.toString().padLeft(3, '0');

  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final offsetAbs = offset.abs();
  final offsetHour = two(offsetAbs.inHours);
  final offsetMinute = two(offsetAbs.inMinutes.remainder(60));

  return '$year-$month-${day}T$hour:$minute:$second.$millisecond$sign$offsetHour:$offsetMinute';
}

/// 订阅从 Rust 侧发来的日志流，并接入 appLog
Future<void> setupRustLogging() async {
  createLogStream().listen((event) {
    // Rust 侧 tag 约定为 file:line（例如 simple.rs:48）
    final eventTime = DateTime.fromMillisecondsSinceEpoch(
      event.timeMillis.toInt(),
      isUtc: true,
    );
    appLog(
      time: eventTime,
      layer: 'Rust',
      level: _levelLabelFromInt(event.level),
      fileAndLine: event.tag,
      message: event.msg,
    );
  });
}

/// 将整数 level 映射为字符串标签
String _levelLabelFromInt(int level) {
  switch (level) {
    case 0:
      return 'DEBUG';
    case 1:
      return 'INFO';
    case 2:
      return 'WARN';
    case 3:
      return 'ERROR';
    default:
      return 'INFO';
  }
}

Future<void> main() async {
  // 使用 runZonedGuarded 捕获绝大部分未处理异常，并统一写入日志
  await runZonedGuarded<Future<void>>(
    () async {
      // 捕获 Flutter 框架级异常（例如构建 / 布局阶段抛出的错误）
      FlutterError.onError = (FlutterErrorDetails details) {
        appLog(
          layer: 'Flutter',
          level: 'ERROR',
          fileAndLine: 'FlutterError',
          message: '${details.exception}\n${details.stack}',
        );
      };

      // 初始化 RustLib（包括 flutter_rust_bridge 的内部状态）
      await RustLib.init();
      // 设置 Rust -> Dart 的日志通道
      await setupRustLogging();
      runApp(const MyApp());
    },
    (error, stack) {
      // 兜底：捕获 zone 内未被处理的异常
      appLog(
        layer: 'Flutter',
        level: 'ERROR',
        fileAndLine: 'main.dart:main',
        message: '$error\n$stack',
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 示例：Flutter 侧日志
    appLog(
      layer: 'Flutter',
      level: 'INFO',
      fileAndLine: 'main.dart:42',
      message: '页面 build 完成',
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Text(
            'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`',
          ),
        ),
      ),
    );
  }
}
