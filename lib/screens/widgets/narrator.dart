import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

const narratorAsset = 'assets/images/narrator.png';
const narratorName = 'Meena';

// width / height of the narrator image.
const double _aspect = 1140 / 1380;

/// Full-screen overlay: the host stands large at the bottom-left of the
/// screen and speaks through a speech bubble. Use inside showDialog.
class NarratorDialog extends StatelessWidget {
  const NarratorDialog({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  final String title;
  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final pad = mq.padding;
    final wide = size.width > 700;

    // Host size: big, like a game character, but never taller than half the screen.
    final w = math.min(
      math.max(170.0, math.min(380.0, size.width * (wide ? 0.30 : 0.64))),
      size.height * 0.5,
    );
    final h = w / _aspect;
    final bottom = pad.bottom + 4;

    final double bubbleLeft;
    final double bubbleWidth;
    final double bubbleBottom;
    if (wide) {
      bubbleLeft = w * 0.82;
      bubbleWidth = math.min(560.0, size.width - bubbleLeft - 24);
      bubbleBottom = bottom + h * 0.35;
    } else {
      bubbleLeft = 12;
      bubbleWidth = size.width - 24;
      bubbleBottom = bottom + h * 0.97;
    }
    final maxH = math.max(120.0, size.height - pad.top - bubbleBottom - 14);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The host slides in from the left.
          Positioned(
            left: -w * 0.06,
            bottom: bottom,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (c, t, child) =>
                  Transform.translate(offset: Offset(-(1 - t) * w, 0), child: child),
              child: Image.asset(
                narratorAsset,
                width: w,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (c, e, s) => SizedBox(
                  width: w,
                  height: h,
                  child: const Icon(Icons.person, size: 90, color: AppColors.maroon),
                ),
              ),
            ),
          ),
          Positioned(
            left: bubbleLeft,
            bottom: bubbleBottom,
            width: bubbleWidth,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: _Bubble(title: title, actions: actions, body: body),
            ),
          ),
          // Little tail pointing at the host.
          if (wide)
            Positioned(
              left: bubbleLeft - 13,
              bottom: bubbleBottom + 36,
              width: 16,
              height: 24,
              child: CustomPaint(painter: _TailPainter(pointLeft: true)),
            )
          else
            Positioned(
              left: w * 0.42,
              bottom: bubbleBottom - 14,
              width: 26,
              height: 17,
              child: CustomPaint(painter: _TailPainter(pointLeft: false)),
            ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.title, required this.body, required this.actions});

  final String title;
  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.maroon, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            narratorName,
            style: TextStyle(
                color: AppColors.terracotta,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.6),
          ),
          Text(
            title,
            style: const TextStyle(
                color: AppColors.maroon, fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: DefaultTextStyle.merge(
                style: const TextStyle(color: AppColors.brown, fontSize: 14.5, height: 1.4),
                child: body,
              ),
            ),
          ),
          if (actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
            ),
        ],
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  _TailPainter({required this.pointLeft});
  final bool pointLeft;

  @override
  void paint(Canvas canvas, Size s) {
    final edge = Path();
    if (pointLeft) {
      edge
        ..moveTo(s.width, 0)
        ..lineTo(0, s.height / 2)
        ..lineTo(s.width, s.height);
    } else {
      edge
        ..moveTo(0, 0)
        ..lineTo(s.width / 2, s.height)
        ..lineTo(s.width, 0);
    }
    final fill = Path.from(edge)..close();
    canvas.drawPath(fill, Paint()..color = AppColors.cream);
    canvas.drawPath(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.maroon,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
