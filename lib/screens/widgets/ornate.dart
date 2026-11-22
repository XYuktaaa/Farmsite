import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../game/art/folk_art.dart';

/// Cream pill with a maroon border, used for HUD chips and panels.
BoxDecoration folkPill({double radius = 22}) => BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF3D6), Color(0xFFF2D58F)],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.maroon, width: 2.5),
      boxShadow: const [
        BoxShadow(color: Color(0x55000000), blurRadius: 6, offset: Offset(0, 3)),
      ],
    );

class LotusIcon extends StatelessWidget {
  const LotusIcon({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _LotusPainter());
}

class _LotusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) =>
      drawLotus(canvas, Offset(s.width / 2, s.height * 0.95), s.height * 0.95);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Maroon ribbon title with a lotus on each side.
class TitleBanner extends StatelessWidget {
  const TitleBanner(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.maroon,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.turmeric, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Color(0x44000000), blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LotusIcon(size: 22),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.turmeric,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          const LotusIcon(size: 22),
        ],
      ),
    );
  }
}

class RupeeCoin extends StatelessWidget {
  const RupeeCoin({super.key, this.size = 26});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(colors: [Color(0xFFFFE680), Color(0xFFE9A823)]),
        border: Border.all(color: AppColors.brown, width: 2),
      ),
      child: Text('₹',
          style: TextStyle(
              color: AppColors.brown, fontWeight: FontWeight.w900, fontSize: size * 0.58)),
    );
  }
}

/// Simple illustrated farmer portrait.
class FarmerAvatar extends StatelessWidget {
  const FarmerAvatar({super.key, this.size = 52});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.turmeric, width: 3),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: ClipOval(child: CustomPaint(painter: _AvatarPainter())),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final r = s.width / 2;
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFFFC857));
    // sari shoulders
    canvas.drawOval(
        Rect.fromCenter(center: c.translate(0, r * 0.95), width: r * 1.8, height: r * 0.9),
        Paint()..color = const Color(0xFFC62828));
    // hair
    canvas.drawCircle(c.translate(0, -r * 0.05), r * 0.62, Paint()..color = const Color(0xFF2B1B17));
    // face
    canvas.drawOval(
        Rect.fromCenter(center: c.translate(0, r * 0.1), width: r * 0.95, height: r * 1.1),
        Paint()..color = const Color(0xFFD99A6C));
    // fringe
    canvas.drawArc(
      Rect.fromCenter(center: c.translate(0, -r * 0.2), width: r * 1.0, height: r * 0.7),
      3.3,
      2.6,
      true,
      Paint()..color = const Color(0xFF2B1B17),
    );
    final dark = Paint()..color = const Color(0xFF2B1B17);
    canvas.drawOval(Rect.fromCenter(center: c.translate(-r * 0.2, r * 0.05), width: r * 0.16, height: r * 0.09), dark);
    canvas.drawOval(Rect.fromCenter(center: c.translate(r * 0.2, r * 0.05), width: r * 0.16, height: r * 0.09), dark);
    canvas.drawCircle(c.translate(0, -r * 0.12), r * 0.06, Paint()..color = const Color(0xFFD32F2F));
    canvas.drawArc(
      Rect.fromCenter(center: c.translate(0, r * 0.3), width: r * 0.4, height: r * 0.25),
      0.2,
      2.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..color = const Color(0xFF8E2A2A),
    );
    // marigold in the hair
    canvas.drawCircle(c.translate(-r * 0.5, -r * 0.35), r * 0.17, Paint()..color = const Color(0xFFFF9800));
    canvas.drawCircle(c.translate(-r * 0.5, -r * 0.35), r * 0.07, Paint()..color = const Color(0xFFFFEB3B));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Maroon bottom bar with a scalloped top edge.
class FolkNavBar extends StatelessWidget {
  const FolkNavBar({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 74,
      child: CustomPaint(
        painter: _NavPainter(),
        child: Row(children: children),
      ),
    );
  }
}

class _NavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final bg = Paint()..color = AppColors.maroon;
    canvas.drawRect(Rect.fromLTWH(0, 10, s.width, s.height - 10), bg);
    final gold = Paint()..color = AppColors.turmeric;
    for (double x = 9; x < s.width + 9; x += 18) {
      canvas.drawCircle(Offset(x, 10), 9, bg);
      canvas.drawCircle(Offset(x, 11), 2.2, gold);
    }
    canvas.drawLine(
      Offset(0, 25),
      Offset(s.width, 25),
      Paint()
        ..color = AppColors.turmeric
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    if (highlight) {
      return Expanded(
        child: Center(
          child: Transform.translate(
            offset: const Offset(0, -14),
            child: InkWell(
              onTap: onTap,
              child: Container(
                width: 72,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.turmeric, AppColors.saffron],
                  ),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(36), bottom: Radius.circular(10)),
                  border: Border.all(color: AppColors.deepMaroon, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.eco, color: AppColors.leafDark, size: 30),
                    Text(label,
                        style: const TextStyle(
                            color: AppColors.deepMaroon,
                            fontWeight: FontWeight.w800,
                            fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 22),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFFFE08A), size: 26),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.cream, fontWeight: FontWeight.w700, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
