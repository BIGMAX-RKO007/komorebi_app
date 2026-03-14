import 'package:flutter/material.dart';
import 'package:komorebi_app/data/log/log_repository.dart';
import 'package:komorebi_app/view_model/log_view_model.dart';

/// 极简日志展示页面（View）
/// - 通过 LogViewModel 读取日志列表
/// - 实时展示最新日志
class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  late final LogViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LogViewModel(LogRepository.instance);
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = _viewModel.logs;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('日志流（Flutter ↔ Rust）'),
        actions: [
          IconButton(
            onPressed: _viewModel.refreshLogs,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新并打印日志',
          ),
          IconButton(
            onPressed: _viewModel.clearLogs,
            icon: const Icon(Icons.delete_outline),
            tooltip: '清空日志',
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(
              child: Text(
                '暂无日志输出',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final line = logs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    line,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

