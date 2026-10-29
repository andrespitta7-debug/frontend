import 'package:flutter/material.dart';

/// Widget para renderizar iconos pixel art de 16 bits sin distorsión (filterQuality: none).
class PixelIcon extends StatelessWidget {
  final String fileName;
  final double size;
  final Color? color;

  const PixelIcon({
    super.key,
    required this.fileName,
    this.size = 24.0,
    this.color,
  });

  String _resolveAssetPath(String path) {
    if (path.startsWith('assets/')) return path;
    if (path.startsWith('frames/')) return 'assets/sprites/$path';
    return 'assets/sprites/frames/$path';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        _resolveAssetPath(fileName),
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        color: color,
        errorBuilder: (_, _, _) => Icon(
          Icons.broken_image,
          size: size,
          color: color,
        ),
      ),
    );
  }
}

