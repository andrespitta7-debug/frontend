import 'dart:async';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';

/// Widget que representa a un luchador (jugador o enemigo) con animación de idle/run,
/// arma pixel art y animación de ataque con embestida (lunge) e impacto sincronizado.
class BattleFighterWidget extends StatefulWidget {
  final String characterPrefix;
  final String? weaponSprite;
  final bool isEnemy;
  final double scale;
  final bool forceRun;

  const BattleFighterWidget({
    super.key,
    required this.characterPrefix,
    this.weaponSprite,
    this.isEnemy = false,
    this.scale = 1.0,
    this.forceRun = false,
  });

  @override
  State<BattleFighterWidget> createState() => BattleFighterWidgetState();
}

class BattleFighterWidgetState extends State<BattleFighterWidget>
    with SingleTickerProviderStateMixin {
  SpriteAnimation? _idleAnimation;
  SpriteAnimationTicker? _idleTicker;
  SpriteAnimation? _runAnimation;
  SpriteAnimationTicker? _runTicker;

  late AnimationController _attackController;
  late Animation<double> _lungeAnimation;
  late Animation<double> _swordAnimation;

  Timer? _impactTimer;
  bool _isAttacking = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _cargarSprites();
  }

  void _initAnimations() {
    // Animación de ataque de 320 ms
    _attackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    // Embestida hacia adelante (0ms a 128ms) y vuelta a la posición base (128ms a 320ms)
    // 128ms / 320ms = 40% del tiempo total
    _lungeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 36.0)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 36.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 60,
      ),
    ]).animate(_attackController);

    // Giro/tajo del arma
    _swordAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 60,
      ),
    ]).animate(_attackController);

    _attackController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isAttacking = false;
          });
        }
      }
    });
  }

  Future<void> _cargarSprites() async {
    try {
      Flame.images.prefix = 'assets/sprites/';
      final idleFrames = await Future.wait([
        Flame.images.load('frames/${widget.characterPrefix}_idle_anim_f0.png'),
        Flame.images.load('frames/${widget.characterPrefix}_idle_anim_f1.png'),
        Flame.images.load('frames/${widget.characterPrefix}_idle_anim_f2.png'),
        Flame.images.load('frames/${widget.characterPrefix}_idle_anim_f3.png'),
      ]);
      final runFrames = await Future.wait([
        Flame.images.load('frames/${widget.characterPrefix}_run_anim_f0.png'),
        Flame.images.load('frames/${widget.characterPrefix}_run_anim_f1.png'),
        Flame.images.load('frames/${widget.characterPrefix}_run_anim_f2.png'),
        Flame.images.load('frames/${widget.characterPrefix}_run_anim_f3.png'),
      ]);

      if (!mounted) return;
      final idleAnim = SpriteAnimation.spriteList(
        idleFrames.map((f) => Sprite(f)).toList(),
        stepTime: 0.15,
        loop: true,
      );
      final runAnim = SpriteAnimation.spriteList(
        runFrames.map((f) => Sprite(f)).toList(),
        stepTime: 0.10,
        loop: true,
      );

      setState(() {
        _idleAnimation = idleAnim;
        _idleTicker = idleAnim.createTicker();
        _runAnimation = runAnim;
        _runTicker = runAnim.createTicker();
      });
    } catch (_) {
      // Fallback para entornos de test o cuando Flame no puede decodificar imágenes nativas
    }
  }

  /// Ejecuta la animación de ataque de 320ms y dispara [onImpactMoment] a los 128ms.
  void playAttack({required VoidCallback onImpactMoment}) {
    if (!mounted) return;
    _impactTimer?.cancel();
    setState(() {
      _isAttacking = true;
    });

    _impactTimer = Timer(const Duration(milliseconds: 128), () {
      if (mounted) {
        onImpactMoment();
      }
    });

    _attackController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(covariant BattleFighterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.characterPrefix != widget.characterPrefix) {
      _cargarSprites();
    }
  }

  @override
  void dispose() {
    _impactTimer?.cancel();
    _attackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool useRun =
        (_isAttacking || widget.forceRun) && _runAnimation != null;
    final activeAnim = useRun ? _runAnimation : _idleAnimation;
    final activeTicker = useRun ? _runTicker : _idleTicker;

    return AnimatedBuilder(
      animation: _attackController,
      builder: (context, _) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(
            widget.isEnemy ? -1.0 : 1.0,
            1.0,
            1.0,
          )..setTranslationRaw(_lungeAnimation.value, 0.0, 0.0),
          child: SizedBox(
            width: 48,
            height: 68,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Contenedor del personaje con FittedBox(fit: BoxFit.contain)
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: activeAnim != null && activeTicker != null
                        ? SizedBox(
                            width: 56,
                            height: 56,
                            child: SpriteAnimationWidget(
                              animation: activeAnim,
                              animationTicker: activeTicker,
                            ),
                          )
                        : Image.asset(
                            'assets/sprites/frames/${widget.characterPrefix}_idle_anim_f0.png',
                            scale: 0.25,
                            filterQuality: FilterQuality.none,
                            errorBuilder: (_, _, _) => Text(
                              widget.isEnemy ? '👾' : '🧙',
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                  ),
                ),

                // Arma equipada en SizedBox(width: 18, height: 34) con BoxFit.contain y FilterQuality.none, right: 0, bottom: 8
                if (widget.weaponSprite != null)
                  Positioned(
                    right: 0,
                    bottom: 8,
                    child: Transform.rotate(
                      angle: _swordAnimation.value,
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(
                        width: 18,
                        height: 34,
                        child: Image.asset(
                          'assets/sprites/frames/${widget.weaponSprite}',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
