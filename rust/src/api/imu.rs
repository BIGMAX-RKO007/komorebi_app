use crate::frb_generated::StreamSink;
use ahrs::{Ahrs, Madgwick};
use nalgebra::Vector3;
use once_cell::sync::Lazy;
use std::sync::Mutex;

/// 内部保存的一个全局 Madgwick 滤波器实例（采样率预设为 50Hz 或 100Hz，取决于传感器实际频率，这里示例 50Hz = 0.02s）
static AHRS: Lazy<Mutex<Madgwick<f32>>> = Lazy::new(|| {
    // 采样周期 0.02s (50Hz), beta 增益 0.1 (常见的经验值，平衡稳定性和响应速度)
    Mutex::new(Madgwick::new(0.02, 0.1))
});

/// 重置滤波器状态
#[flutter_rust_bridge::frb(sync)]
pub fn init_ahrs() {
    let mut ahrs = AHRS.lock().unwrap();
    *ahrs = Madgwick::new(0.02, 0.1);
}

/// 接收来自 Dart 的 IMU 数据（加速度计和陀螺仪），进行融合计算
///
/// * `ax, ay, az`: 加速度计 (m/s^2)
/// * `gx, gy, gz`: 陀螺仪 (rad/s)
/// 
/// 返回: (pitch, roll, yaw) 包含三轴欧拉角的元组 (单位: 弧度)
#[flutter_rust_bridge::frb(sync)]
pub fn update_ahrs(ax: f32, ay: f32, az: f32, gx: f32, gy: f32, gz: f32) -> (f32, f32, f32) {
    let mut ahrs = AHRS.lock().unwrap();
    
    let gyroscope = Vector3::new(gx, gy, gz);
    let accelerometer = Vector3::new(ax, ay, az);

    // 对于 6 轴传感器（只有陀螺仪和加速度计，无磁力计），我们使用 update_imu
    let _ = ahrs.update_imu(&gyroscope, &accelerometer);

    let (rot_x, rot_y, rot_z) = ahrs.quat.euler_angles();

    // 根据 nalgebra 的 API 设计：
    // euler_angles 返回 (X轴旋转, Y轴旋转, Z轴旋转)
    // 在 Android 坐标系下：
    // 绕 X 轴旋转对应 Pitch (俯仰)
    // 绕 Y 轴旋转对应 Roll (横滚)
    // 绕 Z 轴旋转对应 Yaw (航向)
    // 根据约定，我们原样返回并由上层映射为 (pitch, roll, yaw)
    (rot_x, rot_y, rot_z)
}
