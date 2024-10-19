import 'package:flutter/material.dart';
import 'dart:math';

class BackgroundWithIcons extends StatelessWidget {
  final List<IconData> icons = [
    Icons.shopping_bag,
    Icons.attach_money,
    Icons.local_mall,
    Icons.style,
    Icons.local_offer,
  ];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BackgroundPainter(icons),
      child: Container(), // Empty container to hold the background
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final List<IconData> icons;
  final Random random = Random();
  
  // Stores the positions and rotations of the icons (calculated once)
  List<_IconDataWithPosition> iconPositions = [];

  BackgroundPainter(this.icons) {
    // Generate positions and rotations for the icons once
    _generateIconPositions();
  }

  // Generates random positions, sizes, and rotations for the icons
  void _generateIconPositions() {
    for (int i = 0; i < 30; i++) {
      final icon = icons[random.nextInt(icons.length)];
      final size = random.nextDouble() * 40 + 20; // Random size between 20 and 60
      final position = Offset(
        random.nextDouble(), // X position (0.0 to 1.0)
        random.nextDouble(), // Y position (0.0 to 1.0)
      );
      final rotation = random.nextDouble() * 2 * pi; // Random rotation (0 to 360 degrees)

      iconPositions.add(_IconDataWithPosition(icon, size, position, rotation));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var iconData in iconPositions) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(iconData.icon.codePoint),
          style: TextStyle(
            fontSize: iconData.size,
            color: Colors.black.withOpacity(0.1), // Transparent color
            fontFamily: iconData.icon.fontFamily,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final x = iconData.position.dx * size.width;  // Convert relative X position to absolute
      final y = iconData.position.dy * size.height; // Convert relative Y position to absolute

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(iconData.rotation); // Apply random rotation
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Prevents repainting and keeps icons fixed
  }
}

// Class to hold the icon, its size, position, and rotation
class _IconDataWithPosition {
  final IconData icon;
  final double size;
  final Offset position;
  final double rotation;

  _IconDataWithPosition(this.icon, this.size, this.position, this.rotation);
}