import 'package:flutter/material.dart';
import 'package:komorebi_app/ui/home/feature_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Colors.blue.withValues(alpha: 0.1),
              Colors.black,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 上半屏：项目介绍
            const Text(
              'KOMOREBI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.w900,
                letterSpacing: 12,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '3D AVATAR • LLM POWERED • CROSS-PLATFORM',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '次世代数字人跨平台大模型驱动平台',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 80),

            // 中间：当前能力状态
            const Text(
              'CAPABILITY STATUS',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusChip('IMU Fusion', true),
                const SizedBox(width: 12),
                _buildStatusChip('Rust Core', true),
                const SizedBox(width: 12),
                _buildStatusChip('LLM Engine', false),
              ],
            ),

            const SizedBox(height: 100),

            // 下方：进入按钮
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const FeaturePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                elevation: 20,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'START EXPERIENCE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
        border: Border.all(
          color: isActive ? Colors.white24 : Colors.white10,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? Colors.greenAccent : Colors.white10,
              shape: BoxShape.circle,
              boxShadow: isActive ? [
                BoxShadow(
                  color: Colors.greenAccent.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              ] : [],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white70 : Colors.white24,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
