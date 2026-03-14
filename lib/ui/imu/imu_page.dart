import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:komorebi_app/view_model/imu_view_model.dart';
import 'package:provider/provider.dart';

class ImuPage extends StatelessWidget {
  const ImuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImuViewModel(),
      child: const _ImuView(),
    );
  }
}

class _ImuView extends StatelessWidget {
  const _ImuView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ImuViewModel>();

    return Column(
      children: [
        // 顶部的控制按钮
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton(
              onPressed: vm.toggleStream,
              style: ElevatedButton.styleFrom(
                backgroundColor: vm.isRunning ? Colors.red.shade900 : Colors.blue.shade900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                vm.isRunning ? "停止采集 (Stop)" : "VS (开始对比)",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          Expanded(
            child: Row(
              children: [
                // 左侧 Dart 区域
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.white24, width: 2)),
                    ),
                    child: _buildPanel(
                      title: "Dart (仅加速度计)",
                      color: Colors.blueAccent,
                      pitch: vm.dartPitch,
                      roll: vm.dartRoll,
                      yaw: null, 
                    ),
                  ),
                ),
                
                // 右侧 Rust 区域
                Expanded(
                  child: _buildPanel(
                    title: "Rust (IMU 融合)",
                    color: Colors.orangeAccent,
                    pitch: vm.rustPitch,
                    roll: vm.rustRoll,
                    yaw: vm.rustYaw,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }

  Widget _buildPanel({
    required String title,
    required Color color,
    required double pitch,
    required double roll,
    double? yaw,
  }) {
    // 弧度转角度用于显示
    final pDeg = (pitch * 180 / math.pi).toStringAsFixed(1);
    final rDeg = (roll * 180 / math.pi).toStringAsFixed(1);
    final yDeg = yaw != null ? (yaw * 180 / math.pi).toStringAsFixed(1) : "N/A";

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          // 动态方块，通过 Transform.rotate 粗略演示姿态变化
          // 这里仅用 roll 来旋转面板展示效果，更复杂的 3D 需要用到 Transform(Matrix4)
          Transform.rotate(
            angle: roll,
            child: Container(
              width: 70,
              height: 100,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Icon(Icons.phone_android, color: Colors.white70, size: 30)),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 数据读数展示
          _buildStatRow("Pitch (俯仰)", pDeg),
          _buildStatRow("Roll (横滚)", rDeg),
          _buildStatRow("Yaw (航向)", yDeg),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
