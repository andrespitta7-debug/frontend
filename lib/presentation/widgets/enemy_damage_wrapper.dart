import 'dart:math';
import 'package:flutter/material.dart';

/// Envuelve al enemigo para aplicar feedback visual de impacto (daño) y animación de muerte.
/// - [isHit]: Produce un destello blanco (`BlendMode.srcATop`) durante 180ms y sacudida horizontal.
/// - [isDead]: Produce aplastamiento vertical (squash a 0), parpadeo y posterior sustitución por `skull.png`.
class EnemyDamageAndDeathWrapper extends StatefulWidget {
  final Widget child;
  final bool isHit;
  final bool isDead;

  const EnemyDamageAndDeathWrapper({
    super.key,
    required this.child,
    this.isHit = false,
    this.isDead = false,
  });

  @override
  State<EnemyDamageAndDeathWrapper> createState() =>
      _EnemyDamageAndDeathWrapperState();
}

class _EnemyDamageAndDeathWrapperState extends State<EnemyDamageAndDeathWrapper>
    with TickerProviderStateMixin {
  late AnimationController _hitController;
  late AnimationController _deathController;
  late Animation<double> _squashAnimation;

  bool _flashWhite = false;

  @override
  void initState() {
    super.initState();

    _hitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _hitController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _flashWhite = false;
          });
        }
      }
    });

    _deathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _squashAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _deathController,
        curve: Curves.easeInBack,
      ),
    );

    if (widget.isHit) {
      _triggerHit();
    }
    if (widget.isDead) {
      _deathController.value = 1.0;
    }
  }

  void _triggerHit() {
    _flashWhite = true;
    _hitController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(covariant EnemyDamageAndDeathWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHit && !oldWidget.isHit) {
      _triggerHit();
    }

    if (widget.isDead && !oldWidget.isDead) {
      _deathController.forward(from: 0.0);
    } else if (!widget.isDead && oldWidget.isDead) {
      _deathController.reset();
    }
  }

  @override
  void dispose() {
    _hitController.dispose();
    _deathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_hitController, _deathController]),
      builder: (context, _) {
        // Cuando la muerte ha concluido, se muestra la calavera fija
        if (_deathController.isCompleted) {
          return SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: Image.asset(
                'assets/sprites/frames/skull.png',
                scale: 0.25,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, _, _) =>
                    const Text('💀', style: TextStyle(fontSize: 28)),
              ),
            ),
          );
        }

        // Sacudida horizontal del golpe durante 180ms
        final shakeOffset = _hitController.isAnimating
            ? sin(_hitController.value * pi * 8) * 5.0
            : 0.0;

        // Efecto de aplastamiento y parpadeo durante la animación de muerte
        final scaleY =
            widget.isDead ? _squashAnimation.value.clamp(0.0, 1.0) : 1.0;
        final blinkOpacity = widget.isDead
            ? (sin(_deathController.value * pi * 10) > 0 ? 1.0 : 0.2)
            : 1.0;

        Widget content = Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.diagonal3Values(1.0, scaleY, 1.0),
            child: Opacity(
              opacity: blinkOpacity,
              child: widget.child,
            ),
          ),
        );

        if (_flashWhite) {
          content = ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcATop,
            ),
            child: content,
          );
        }

        return content;
      },
    );
  }
}
