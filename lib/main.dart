import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komorebi_app/data/log/log_repository.dart';
import 'package:komorebi_app/src/rust/frb_generated.dart';
import 'package:komorebi_app/ui/landing/landing_page.dart';

Future<void> main() async {
  // 使用 runZonedGuarded 捕获绝大部分未处理异常，并统一写入日志
  await runZonedGuarded<Future<void>>(
    () async {
      // 捕获 Flutter 框架级异常（例如构建 / 布局阶段抛出的错误）
      FlutterError.onError = (FlutterErrorDetails details) {
        LogRepository.instance.logFlutter(
          level: 'ERROR',
          fileAndLine: 'FlutterError',
          message: '${details.exception}\n${details.stack}',
        );
      };

      // 初始化 RustLib（包括 flutter_rust_bridge 的内部状态）
      await RustLib.init();
      // 设置 Rust -> Dart 的日志通道（Repository 内部订阅 Rust Stream）
      await LogRepository.instance.initRustLogging();
      runApp(const MyApp());
    },
    (error, stack) {
      // 兜底：捕获 zone 内未被处理的异常
      LogRepository.instance.logFlutter(
        level: 'ERROR',
        fileAndLine: 'main.dart:main',
        message: '$error\n$stack',
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //添加一行启动日志“程序启动了”
    LogRepository.instance.logFlutter(
      level: 'INFO',
      fileAndLine: 'main.dart:45',
      message: '程序启动了',
    );
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Komorebi',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}
