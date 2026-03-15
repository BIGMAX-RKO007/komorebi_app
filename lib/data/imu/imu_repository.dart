import 'package:komorebi_app/src/rust/api/imu.dart' as rust_imu;

/// IMU 数据仓库层
/// 负责封装所有对底层 Rust IMU 算法的直接调用
class ImuRepository {
  ImuRepository._();

  static final ImuRepository instance = ImuRepository._();

  /// 初始化或重置底层滤波器
  void initAhrs() {
    rust_imu.initAhrs();
  }

  /// 发送传感器原始数据到 Rust 进行 Madgwick 融合，返回 (Pitch, Roll, Yaw)
  (double, double, double) updateAhrs({
    required double ax,
    required double ay,
    required double az,
    required double gx,
    required double gy,
    required double gz,
  }) {
    return rust_imu.updateAhrs(ax: ax, ay: ay, az: az, gx: gx, gy: gy, gz: gz);
  }
}
