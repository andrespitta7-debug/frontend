import 'package:flutter/material.dart';

/// Widget para renderizar iconos pixel art de 16 bits sin distorsión (filterQuality: none).
class PixelIcon extends StatelessWidget {
  final String fileName;
  final double size;
  final double? width;
  final double? height;
  final Color? color;

  const PixelIcon({
    super.key,
    required this.fileName,
    this.size = 24.0,
    this.width,
    this.height,
    this.color,
  });

  String _resolveAssetPath(String path) {
    if (path.startsWith('assets/')) return path;
    if (path.startsWith('frames/')) return 'assets/sprites/$path';
    return 'assets/sprites/frames/$path';
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;

    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: Image.asset(
        _resolveAssetPath(fileName),
        width: effectiveWidth,
        height: effectiveHeight,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        color: color,
        errorBuilder: (_, _, _) => Icon(
          Icons.broken_image,
          size: effectiveWidth < effectiveHeight ? effectiveWidth : effectiveHeight,
          color: color,
        ),
      ),
    );
  }
}

