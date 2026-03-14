import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:komorebi_app/data/imu/imu_repository.dart';

class ImuViewModel extends ChangeNotifier {
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  // Dart 原始计算结果（弧度）
  double dartPitch = 0.0;
  double dartRoll = 0.0;

  // Rust 融合返回结果（弧度）
  double rustPitch = 0.0;
  double rustRoll = 0.0;
  double rustYaw = 0.0;

  // 传感器的最新值缓冲
  double _ax = 0, _ay = 0, _az = 0;
  double _gx = 0, _gy = 0, _gz = 0;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  void toggleStream() {
    if (_isRunning) {
      _stopStream();
    } else {
      _startStream();
    }
  }

  void _startStream() {
    _isRunning = true;
    ImuRepository.instance.initAhrs(); // 初始化/重置滤波器
    notifyListeners();

    _accelSub = accelerometerEventStream().listen((event) {
      _ax = event.x;
      _ay = event.y;
      _az = event.z;
      _computeDartAttitude();
      _updateRustFusion();
    });

    _gyroSub = gyroscopeEventStream().listen((event) {
      _gx = event.x;
      _gy = event.y;
      _gz = event.z;
    });
  }

  void _stopStream() {
    _isRunning = false;
    _accelSub?.cancel();
    _gyroSub?.cancel();
    notifyListeners();
  }

  /// 极简的 Dart 端计算：仅依靠加速度计计算 Pitch / Roll (单位: 弧度)
  void _computeDartAttitude() {
    // Android 原生坐标系：
    // X 轴水平向右，Y 轴垂直向上，Z 轴垂直屏幕向外
    // 手机绕 X 轴旋转产生 Pitch (俯仰，反映在 Y 和 Z 变化)
    // 手机绕 Y 轴旋转产生 Roll (横滚，反映在 X 和 Z 变化)
    dartPitch = math.atan2(_ay, _az);
    dartRoll = math.atan2(-_ax, math.sqrt(_ay * _ay + _az * _az));
    notifyListeners();
  }

  /// 每收集到一次 Accelerometer 数据，就送给 Rust 的滤波算法做融合
  void _updateRustFusion() {
    // 轴向映射修正：
    // sensors_plus 默认：X 右，Y 上，Z 垂直屏幕向外
    // 我们将其映射为标准航向坐标系 (比如使用类似航空的习惯或者和 ahrs crate 匹配的坐标系)
    // 根据 ahrs crate，重力方向应该是 Z 轴正向或负向，通常东北地 NED (X北, Y东, Z下) 或 ENU。
    // 如果我们把手机平放，Z 是向上(大约 +9.8)，而在 NED 下 Z 是向下。
    // 为了使 Rust 算出的角度和 Dart 直观视觉匹配且不过滤掉正确的重力：
    // 陀螺仪的轴向也需要匹配
    final result = ImuRepository.instance.updateAhrs(
      ax: _ax,     // X: Right -> X
      ay: _ay,     // Y: Up -> Y
      az: _az,     // Z: Out -> Z
      gx: _gx,
      gy: _gy,
      gz: _gz,
    );

    rustPitch = result.$1;
    rustRoll = result.$2;
    rustYaw = result.$3;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopStream();
    super.dispose();
  }
}
