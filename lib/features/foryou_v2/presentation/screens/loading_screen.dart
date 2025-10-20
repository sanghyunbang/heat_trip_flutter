import 'dart:async';
import 'package:flutter/material.dart';

/// React 예시(Screen3_Loading) 느낌의 로딩 스크린
/// - 따뜻한 그라데이션 배경
/// - 2초마다 아이콘/메시지 순환
/// - 진행률 바 + 퍼센트
/// - 아이콘 뒤 핑(펄스) + 원형 물결 파동
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    super.key,
    this.onDone,
    this.totalDuration = const Duration(seconds: 6),
  });

  /// 100% 도달 후 호출(선택)
  final VoidCallback? onDone;

  /// 0→100% 소요 시간
  final Duration totalDuration;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl; // 물결(리플)
  late final AnimationController _pulseCtrl; // 핑(숨쉬기)
  Timer? _progressTimer;
  Timer? _messageTimer;

  double _progress = 0; // 0~100
  int _messageIndex = 0;

  final _messages = const [
    _Msg(
      Icons.psychology_alt_rounded,
      '감정 상태를 분석하고 있습니다...',
      Color(0xFFFF5A7A),
    ),
    _Msg(Icons.auto_awesome, '당신에게 맞는 여행 테마를 찾고 있습니다...', Color(0xFFFFB300)),
    _Msg(Icons.place_rounded, '최적의 여행지를 추천하고 있습니다...', Color(0xFFFF7B42)),
  ];

  @override
  void initState() {
    super.initState();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..repeat(reverse: true);

    // 진행률 증가 타이머(선형)
    const tickMs = 80;
    final ticks = widget.totalDuration.inMilliseconds / tickMs;
    final inc = 100 / ticks;
    _progressTimer = Timer.periodic(const Duration(milliseconds: tickMs), (t) {
      setState(() {
        _progress += inc;
        if (_progress >= 100) {
          _progress = 100;
          t.cancel();
          Future.delayed(const Duration(milliseconds: 350), () {
            if (!mounted) return;
            widget.onDone?.call();
          });
        }
      });
    });

    // 메시지 순환(2초)
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _messageTimer?.cancel();
    _waveCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = _messages[_messageIndex];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF7B42), Color(0xFFFF5A7A), Color(0xFFFF8FB5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(.18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 아이콘 + 리플 + 핑
                    SizedBox(
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _waveCtrl,
                            builder: (_, __) {
                              return CustomPaint(
                                painter: _RipplePainter(
                                  progress: _waveCtrl.value,
                                ),
                                size: const Size(140, 140),
                              );
                            },
                          ),
                          ScaleTransition(
                            scale: _pulseCtrl,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(22),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                transitionBuilder: (child, a) =>
                                    ScaleTransition(scale: a, child: child),
                                child: Icon(
                                  msg.icon,
                                  key: ValueKey(_messageIndex),
                                  size: 56,
                                  color: msg.color,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(.18),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: Text(
                        msg.text,
                        key: ValueKey('msg-$_messageIndex'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 진행률 표시
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: _progress / 100,
                            backgroundColor: Colors.white.withOpacity(.25),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_progress.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // 로딩 점 3개(바운스). const 제거(애니메이션 문맥에서 안전)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _BouncingDot(delayMs: 0),
                        SizedBox(width: 8),
                        _BouncingDot(delayMs: 150),
                        SizedBox(width: 8),
                        _BouncingDot(delayMs: 300),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Msg {
  final IconData icon;
  final String text;
  final Color color;
  const _Msg(this.icon, this.text, this.color);
}

class _BouncingDot extends StatefulWidget {
  const _BouncingDot({super.key, required this.delayMs});
  final int delayMs;

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: .8, end: 1.2).animate(_anim),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.8),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// 원형 파동(리플) 페인터
class _RipplePainter extends CustomPainter {
  final double progress; // 0~1
  _RipplePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;

    for (var i = 0; i < 3; i++) {
      final t = (progress + i / 3) % 1.0;
      final radius = _lerp(maxR * .35, maxR, t);
      final opacity = (1 - t).clamp(0.0, 1.0);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withOpacity(.20 * opacity);
      canvas.drawCircle(center, radius, paint);
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
