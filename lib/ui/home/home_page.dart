import 'package:flutter/material.dart';
import 'package:komorebi_app/ui/imu/imu_page.dart';
import 'package:komorebi_app/view_model/log_view_model.dart';
import 'package:komorebi_app/data/log/log_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final LogViewModel _logViewModel;

  @override
  void initState() {
    super.initState();
    _logViewModel = LogViewModel(LogRepository.instance);
  }

  @override
  void dispose() {
    _logViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Komorebi (IMU & Logs)'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _logViewModel.refreshLogs(),
            icon: const Icon(Icons.refresh),
            tooltip: '发送一条测试日志',
          ),
          IconButton(
            onPressed: () => _logViewModel.clearLogs(),
            icon: const Icon(Icons.delete_outline),
            tooltip: '清空日志',
          ),
        ],
      ),
      body: Column(
        children: [
          // 上半部分：IMU 数据面板（内部用 Provider 维护了 ImuViewModel）
          const Expanded(
            flex: 6,
            child: ImuPage(), // 将刚才独立的 ImuPage 作为一个组件嵌入进来
          ),
          
          // 分割线
          const Divider(color: Colors.white24, height: 1, thickness: 1),

          // 下半部分：日志列表
          // 因为 LogPage 最初设计是一个完整的 Scaffold，在这里我们直接从 LogPage 中拆解出显示列表的部分
          Expanded(
            flex: 4,
            child: _LogListPanel(viewModel: _logViewModel),
          ),
        ],
      ),
    );
  }
}

/// 拆分出的日志列表面板，不再独占一个 Scaffold
class _LogListPanel extends StatefulWidget {
  final LogViewModel viewModel;
  
  const _LogListPanel({required this.viewModel});

  @override
  State<_LogListPanel> createState() => _LogListPanelState();
}

class _LogListPanelState extends State<_LogListPanel> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final logs = widget.viewModel.logs;
    
    if (logs.isEmpty) {
      return const Center(
        child: Text(
          '暂无日志输出',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final line = logs[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            line,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontFamily: 'monospace',
              fontSize: 10,
            ),
          ),
        );
      },
    );
  }
}
