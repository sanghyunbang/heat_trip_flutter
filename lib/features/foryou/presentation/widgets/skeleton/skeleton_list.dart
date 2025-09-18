// features/foryou/presentation/widgets/skeleton/skeleton_list.dart
import 'package:flutter/material.dart';

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 6});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const _ShimmerStripe(),
        ),
      ),
    );
  }
}

class _ShimmerStripe extends StatefulWidget {
  const _ShimmerStripe();

  @override
  State<_ShimmerStripe> createState() => _ShimmerStripeState();
}

class _ShimmerStripeState extends State<_ShimmerStripe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return CustomPaint(
          painter: _StripePainter(progress: _c.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()..color = const Color(0xFFF3F4F7);
    final highlight = Paint()..color = const Color(0xFFE9EBF2);

    // base fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      base,
    );

    // moving highlight stripe
    final stripeWidth = size.width * 0.35;
    final x = (size.width + stripeWidth) * progress - stripeWidth;
    final rect = Rect.fromLTWH(x, 0, stripeWidth, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    canvas.drawRRect(rrect, highlight);
  }

  @override
  bool shouldRepaint(covariant _StripePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
