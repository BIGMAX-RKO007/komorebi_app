import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:komorebi_app/src/rust/api/simple.dart';

/// 日志数据层（Repository）
/// - 负责接收 Flutter / Rust 的日志输入
/// - 统一格式化为字符串
/// - 通过 ValueListenable 向上层暴露日志列表
class LogRepository {
  LogRepository._();

  static final LogRepository instance = LogRepository._();

  /// 所有日志的累积列表（最新追加在末尾）
  final ValueNotifier<List<String>> _logs = ValueNotifier<List<String>>([]);

  ValueListenable<List<String>> get logs => _logs;

  StreamSubscription<LogEntry>? _rustSub;

  /// 初始化与 Rust 的日志流对接（Dart 侧订阅 Rust 的 Stream）
  Future<void> initRustLogging() async {
    _rustSub = createLogStream().listen((event) {
      _addRustLog(event);
    });
  }

  /// Flutter 侧写日志的统一入口
  void logFlutter({
    DateTime? time,
    required String level,
    required String fileAndLine,
    required String message,
  }) {
    final ts = _formatTimestamp(time ?? DateTime.now());
    final line = '[$ts][Flutter][$level][$fileAndLine] $message';

    // 控制台输出 + 写入内存列表
    // ignore: avoid_print
    print(line);

    final current = List<String>.from(_logs.value);
    current.add(line);
    _logs.value = current;
  }

  /// 从 Rust 侧来的日志（LogEntry）转成统一格式并记录
  void _addRustLog(LogEntry entry) {
    final ts = _formatTimestamp(
      DateTime.fromMillisecondsSinceEpoch(entry.timeMillis.toInt(), isUtc: true),
    );
    final levelLabel = _levelLabelFromInt(entry.level);
    final line = '[$ts][Rust][$levelLabel][${entry.tag}] ${entry.msg}';

    // ignore: avoid_print
    print(line);

    final current = List<String>.from(_logs.value);
    current.add(line);
    _logs.value = current;
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

  /// 清空当前内存中的所有日志
  void clear() {
    _logs.value = [];
  }

  Future<void> dispose() async {
    await _rustSub?.cancel();
  }
}

