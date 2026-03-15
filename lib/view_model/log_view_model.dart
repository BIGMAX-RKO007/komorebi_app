import 'package:flutter/foundation.dart';
import 'package:komorebi_app/data/log/log_repository.dart';
import 'package:komorebi_app/src/rust/api/simple.dart';

/// 日志 ViewModel（UI 层只依赖它，不直接依赖 Repository）
class LogViewModel extends ChangeNotifier {
  LogViewModel(this._repository) {
    _logs = List<String>.from(_repository.logs.value);
    _listener = () {
      _logs = List<String>.from(_repository.logs.value);
      // 关键修复：将 UI 重建请求推迟到当前帧的布局/构建周期之后
      // 避免由于窗口 resize 触发 LayoutBuilder 重建时，恰好碰上底层日志更新
      // 从而引发 "setState() or markNeedsBuild() called during build" 的红屏报错
      Future.microtask(() {
        notifyListeners();
      });
    };
    _repository.logs.addListener(_listener);
  }

  final LogRepository _repository;

  late List<String> _logs;
  late VoidCallback _listener;

  List<String> get logs => _logs;

  /// 暴露给 View 的清空日志命令（示例）
  void clearLogs() {
    _repository.clear();
  }

  /// 点击刷新按钮触发日志
  void refreshLogs() {
    _repository.logFlutter(
      level: 'INFO',
      fileAndLine: 'log_view_model.dart',
      message: '点击了日志刷新按钮',
    );
    // 触发 Rust 端的联动打印
    triggerRefreshLog();
  }

  @override
  void dispose() {
    _repository.logs.removeListener(_listener);
    super.dispose();
  }
}
