import 'package:flutter/material.dart';
import 'package:komorebi_app/ui/imu/imu_page.dart';
import 'package:komorebi_app/view_model/log_view_model.dart';
import 'package:komorebi_app/data/log/log_repository.dart';

class FeaturePage extends StatefulWidget {
  const FeaturePage({super.key});

  @override
  State<FeaturePage> createState() => _FeaturePageState();
}

class _FeaturePageState extends State<FeaturePage> {
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
      body: _AdaptiveDashboardLayout(
        // 这里可以自由增加新面板，自动根据屏幕宽度在 Row 和 Column 之间切换
        panes: [
          const AdaptivePane(
            flex: 6,
            child: ImuPage(),
          ),
          AdaptivePane(
            flex: 4,
            child: _LogListPanel(viewModel: _logViewModel),
          ),
          // 未来只需在此处添加更多 AdaptivePane() 即可自动分配屏幕空间
        ],
      ),
    );
  }
}

/// 定义自适应面板数据结构，包含要渲染的组件和分配的比例
class AdaptivePane {
  final Widget child;
  final int flex;

  const AdaptivePane({
    required this.child,
    this.flex = 1,
  });
}

/// 统一的自适应仪表盘布局壳组件
/// - 内部使用宽度断点（如 600 和 900）来智能重排大尺寸设备的自适应
/// - 小屏幕 (< 600)    -> 纵向单列
/// - 中屏幕 (600-900)  -> 最大双列分栏（每行2个）
/// - 大屏幕 (>= 900)   -> 混合主次栏（左侧主图 + 右侧多个窗格纵列）
class _AdaptiveDashboardLayout extends StatelessWidget {
  final List<AdaptivePane> panes;
  
  // Material Design 推荐的断点
  final double mediumBreakpoint = 600.0;
  final double largeBreakpoint = 900.0;

  const _AdaptiveDashboardLayout({
    required this.panes,
  });

  @override
  Widget build(BuildContext context) {
    if (panes.isEmpty) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        if (width >= largeBreakpoint) {
          return _buildLargeLayout();
        } else if (width >= mediumBreakpoint) {
          return _buildMediumLayout();
        } else {
          return _buildSmallLayout();
        }
      },
    );
  }

  /// 小于 600：全部单列垂直堆叠
  Widget _buildSmallLayout() {
    final children = <Widget>[];
    for (int i = 0; i < panes.length; i++) {
      children.add(Expanded(flex: panes[i].flex, child: panes[i].child));
      
      if (i < panes.length - 1) {
        children.add(const Divider(color: Colors.white24, height: 1, thickness: 1));
      }
    }
    return Column(children: children);
  }

  /// 600 ~ 900：通常支持双栏。
  /// 对于2个 pane 以内，直接水平排；对应 3 个以上 pane，采用双列折行的网格布局。
  Widget _buildMediumLayout() {
    if (panes.length <= 2) {
      // 简单横屏排布
      final children = <Widget>[];
      for (int i = 0; i < panes.length; i++) {
        children.add(Expanded(flex: panes[i].flex, child: panes[i].child));
        
        if (i < panes.length - 1) {
          children.add(const VerticalDivider(color: Colors.white24, width: 1, thickness: 1));
        }
      }
      return Row(children: children);
    }

    // 超过 2 个面板，折行处理（基于 Row/Column 嵌套）
    final columnChildren = <Widget>[];
    for (int i = 0; i < panes.length; i += 2) {
      final isLastRowWithSingleItem = (i == panes.length - 1);
      final rowChildren = <Widget>[];
      
      rowChildren.add(Expanded(flex: panes[i].flex, child: panes[i].child));
      
      // 计算这一行应该占的高度权重 (取行内最大值)
      int rowFlex = panes[i].flex;

      if (!isLastRowWithSingleItem) {
        rowChildren.add(const VerticalDivider(color: Colors.white24, width: 1, thickness: 1));
        rowChildren.add(Expanded(flex: panes[i+1].flex, child: panes[i+1].child));
        if (panes[i+1].flex > rowFlex) {
           rowFlex = panes[i+1].flex;
        }
      }

      columnChildren.add(
        Expanded(
          flex: rowFlex, // 动态适应内容权重，非固定1
          child: Row(children: rowChildren),
        ),
      );

      if (i + 2 < panes.length) {
        columnChildren.add(const Divider(color: Colors.white24, height: 1, thickness: 1));
      }
    }
    return Column(children: columnChildren);
  }

  /// >= 900：大屏幕空间充足，提供主次区分视阈
  /// 采用 "左侧主区(Main) + 右侧侧栏(Sidebar)" 的经典布局
  Widget _buildLargeLayout() {
    if (panes.length <= 2) {
      return _buildMediumLayout(); // 面板少于2个时不需要硬拆分，行为与等宽横列一致
    }

    // 第一个为主要工作区，后续的面板组装为侧边状态栏
    final mainPane = panes.first;
    final sidebarPanes = panes.sublist(1);
    
    // 主次区的宽度比例固定为 7:3，不再随侧栏组件数量无限增加而挤压主区
    const int mainWidthFlex = 7;
    const int sidebarWidthFlex = 3;

    return Row(
      children: [
        // 左侧大主区
        Expanded(
          flex: mainWidthFlex,
          child: mainPane.child,
        ),
        
        const VerticalDivider(color: Colors.white24, width: 1, thickness: 1),
        
        // 右侧小栏区，内部组件独立应用各自的高度比例
        Expanded(
          flex: sidebarWidthFlex,
          child: Column(
            children: List<Widget>.generate(sidebarPanes.length * 2 - 1, (index) {
              if (index.isEven) {
                final paneIndex = index ~/ 2;
                final pane = sidebarPanes[paneIndex];
                // 使用面板自带的高度 flex进行垂直分配
                return Expanded(flex: pane.flex, child: pane.child);
              } else {
                return const Divider(color: Colors.white24, height: 1, thickness: 1);
              }
            }),
          ),
        ),
      ],
    );
  }
}

/// 拆分出的日志列表面板，不再独占一个 Scaffold
class _LogListPanel extends StatelessWidget {
  final LogViewModel viewModel;
  
  const _LogListPanel({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // 使用 ListenableBuilder 代替 StatefulWidget 中手动 addListener/setState 模式
    // 它能将重新构建的作用域限制在此处，并且避免布局和状态变更引起的帧冲突
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final logs = viewModel.logs;
        
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
      },
    );
  }
}
