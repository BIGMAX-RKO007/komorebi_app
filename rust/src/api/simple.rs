use crate::frb_generated::StreamSink;
use once_cell::sync::Lazy;
use std::sync::Mutex;
use std::time::{SystemTime, UNIX_EPOCH};

/// 从 Rust 发送到 Dart 的一条日志记录
#[derive(Clone, Debug)]
pub struct LogEntry {
    pub time_millis: i64,
    pub level: i32,
    pub tag: String,
    pub msg: String,
}

/// 全局保存 Dart 传进来的日志 StreamSink
static LOG_STREAM_SINK: Lazy<Mutex<Option<StreamSink<LogEntry>>>> =
    Lazy::new(|| Mutex::new(None));

/// 在 Dart 侧会生成函数签名：`Stream<LogEntry> createLogStream()`
pub fn create_log_stream(sink: StreamSink<LogEntry>) {
    let mut guard = LOG_STREAM_SINK.lock().unwrap();
    *guard = Some(sink);
}

/// 在 Rust 侧方便调用的统一日志入口
pub fn log_from_rust(level: i32, tag: &str, msg: &str) {
    // WASM does not support SystemTime::now() without extra bits.
    // Use 0 for now to avoid panics. 
    let time_millis = 0;
    /*
    let time_millis = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or(0);
    */

    let entry = LogEntry {
        time_millis,
        level,
        tag: tag.to_string(),
        msg: msg.to_string(),
    };

    if let Some(sink) = LOG_STREAM_SINK.lock().unwrap().as_ref() {
        // 忽略发送中的错误（例如 Dart 侧已经关闭）
        let _ = sink.add(entry);
    }
}

/// 演示业务函数：在返回问候语前先打一个日志
#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    // 使用 file! 和 line! 生成形如 simple.rs:48 的位置信息
    let file_line = format!("{}:{}", file!(), line!());
    log_from_rust(1, &file_line, &format!("greet called with {name}"));
    format!("Hi, {name}! from Rust {}", name.len())
}

/// 示例：一个可能失败的接口，演示如何在出错时先写 Rust 日志再把错误返回给 Dart
#[flutter_rust_bridge::frb(sync)]
pub fn may_fail(should_fail: bool) -> Result<String, String> {
    let file_line = format!("{}:{}", file!(), line!());

    if should_fail {
        let msg = "simulated failure from Rust";
        // 先写一条错误级别日志
        log_from_rust(3, &file_line, msg);
        // 再把错误信息返回给 Dart（由 flutter_rust_bridge 映射为 Dart 侧的异常 / 错误）
        Err(msg.to_string())
    } else {
        Ok("success from Rust".to_string())
    }
}

/// 点击刷新按钮触发的 Rust 函数
#[flutter_rust_bridge::frb(sync)]
pub fn trigger_refresh_log() {
    let file_line = format!("{}:{}", file!(), line!());
    // 触发打印日志给到 Flutter
    log_from_rust(1, &file_line, "rust 调用成功");
}

/// flutter_rust_bridge 的初始化入口
#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // 默认的工具初始化，后续可以按需自定义
    flutter_rust_bridge::setup_default_user_utils();
}
