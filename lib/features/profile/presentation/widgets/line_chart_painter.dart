import 'package:flutter/material.dart';

/// 패키지 없이 간단한 라인 차트
class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 가이드 라인
    final axis = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height - (size.height * i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), axis);
    }

    // 더미 데이터 (시안 형태)
    final points = <Offset>[
      Offset(0, size.height * .85),
      Offset(size.width * .18, size.height * .45),
      Offset(size.width * .36, size.height * .60),
      Offset(size.width * .54, size.height * .65),
      Offset(size.width * .72, size.height * .20),
      Offset(size.width * .98, size.height * .22),
    ];

    // 영역 채움
    final areaPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.black.withOpacity(.05), Colors.transparent],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    // 라인
    final line = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
