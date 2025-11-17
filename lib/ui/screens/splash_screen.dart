import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nitrax/config/global/constants/app_constants.dart';
import 'package:nitrax/ui/screens/parent_screen.dart';

class SplashNitrax extends StatefulWidget {
  const SplashNitrax({Key? key}) : super(key: key);

  @override
  State<SplashNitrax> createState() => _SplashNitraxState();
}

class _SplashNitraxState extends State<SplashNitrax>
    with TickerProviderStateMixin {
  late final AnimationController _riseController; // background rise
  late final AnimationController _logoController; // scale + entrance
  late final AnimationController _shineController; // shine sweep
  late final AnimationController _parallaxController; // parallax movement
  late final ParticleController _particleController; // particles

  @override
  void initState() {
    super.initState();

    if (mounted) {
      Future.delayed(Duration(milliseconds: 3000), () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 1500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                ParentScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
          ),
        );
      });
    }

    _riseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _parallaxController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _particleController = ParticleController(vsync: this);
    _particleController.start();

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _logoController.forward();
    });
  }

  @override
  void dispose() {
    _riseController.dispose();
    _logoController.dispose();
    _shineController.dispose();
    _parallaxController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF050507)),

          AnimatedBuilder(
            animation: _parallaxController,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: ParallaxPainter(progress: _parallaxController.value),
              );
            },
          ),

          AnimatedBuilder(
            animation: _riseController,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_riseController.value);
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: size.height * t,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xFF021022), // very dark blue
                        AppConstants.primaryColor.withOpacity(.5), // dark teal
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          Positioned.fill(
            child: CustomPaint(
              painter: ParticlePainter(controller: _particleController),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _riseController,
                _logoController,
                _shineController,
              ]),
              builder: (context, child) {
                final rise = _riseController.value;
                final logoScale = Tween<double>(begin: 0.7, end: 1.0).transform(
                  Curves.easeOutBack.transform(_logoController.value),
                );

                return Opacity(
                  opacity: (rise * 1.4).clamp(0.0, 1.0),
                  child: Transform.scale(scale: logoScale, child: child),
                );
              },
              child: _GlassLogoCard(shineProgress: _shineController),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassLogoCard extends StatelessWidget {
  final AnimationController shineProgress;
  const _GlassLogoCard({required this.shineProgress});

  @override
  Widget build(BuildContext context) {
    final cardSize = Size(320, 270);

    return SizedBox(
      width: cardSize.width,
      height: cardSize.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: cardSize.width,
                height: cardSize.height,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.02),
                      Colors.white.withOpacity(0.01),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 28,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 127, 170, 189),
                    Color.fromARGB(255, 114, 155, 180),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.06),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.audiotrack_rounded,
                size: 52,
                color: Colors.white,
              ),
            ),
          ),

          Positioned(
            bottom: 86,
            child: AnimatedBuilder(
              animation: shineProgress,
              builder: (context, _) {
                return _ShinyText(
                  text: 'NITRAX',
                  progress: shineProgress.value,
                );
              },
            ),
          ),

          Positioned(
            bottom: 12,
            child: Column(
              children: [
                Text(
                  'Von',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
                const Text(
                  'NIMA NADERI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShinyText extends StatelessWidget {
  final String text;
  final double progress; // 0..1
  const _ShinyText({required this.text, required this.progress});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.8,
      color: Colors.white.withOpacity(0.95),
      shadows: [
        Shadow(
          color: Colors.cyanAccent.withOpacity(0.14),
          blurRadius: 18 * (0.6 + 0.4 * progress),
        ),
        Shadow(color: Colors.white.withOpacity(0.06), blurRadius: 4),
      ],
    );

    return ShaderMask(
      shaderCallback: (bounds) {
        final width = bounds.width;
        final bandWidth = width * 0.35;
        final xCenter = (progress * (width + bandWidth)) - bandWidth / 2;

        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.02),
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.02),
          ],
          stops: [
            ((xCenter - bandWidth / 2) / width).clamp(0.0, 1.0),
            (xCenter / width).clamp(0.0, 1.0),
            ((xCenter + bandWidth / 2) / width).clamp(0.0, 1.0),
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: Text(text, style: textStyle),
    );
  }
}

class ParallaxPainter extends CustomPainter {
  final double progress; // 0..1
  ParallaxPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = const Color(0xFF072033).withOpacity(0.7);
    final center1 = Offset(
      size.width * 0.2 + progress * 20,
      size.height * 0.8 - progress * 40,
    );
    canvas.drawCircle(center1, size.width * 0.55, paint1);

    final paint2 = Paint()..color = const Color(0xFF0A2A3A).withOpacity(0.55);
    final center2 = Offset(
      size.width * 0.85 - progress * 40,
      size.height * 0.7 - progress * 20,
    );
    canvas.drawCircle(center2, size.width * 0.36, paint2);

    final paint3 = Paint()..color = const Color(0xFF0E3D4B).withOpacity(0.45);
    final center3 = Offset(
      size.width * 0.5 - progress * 30,
      size.height * 0.3 + progress * 10,
    );
    canvas.drawCircle(center3, size.width * 0.18, paint3);
  }

  @override
  bool shouldRepaint(covariant ParallaxPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class ParticleController {
  final TickerProvider vsync;
  late final AnimationController _ctrl;
  final Random _rnd = Random();
  final List<Particle> particles = [];

  ParticleController({required this.vsync}) {
    _ctrl = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 9999),
    );
    for (int i = 0; i < 28; i++) {
      particles.add(_randomParticle());
    }
  }

  void start() {
    _ctrl.addListener(_tick);
    _ctrl.repeat();
  }

  void _tick() {
    for (final p in particles) {
      p.update(1 / 60);
      if (p.isDead) {
        particles[particles.indexOf(p)] = _randomParticle(spawnTop: true);
      }
    }
  }

  Particle _randomParticle({bool spawnTop = false}) {
    final size = _rnd.nextDouble() * 3 + 1.5; // small sizes
    final x = _rnd.nextDouble();
    final y = spawnTop ? -_rnd.nextDouble() * 0.1 : _rnd.nextDouble();
    final speed = 0.02 + _rnd.nextDouble() * 0.05;
    final life = 4 + _rnd.nextDouble() * 3;
    final glow = 0.12 + _rnd.nextDouble() * 0.25;
    return Particle(
      x: x,
      y: y,
      size: size,
      speed: speed,
      life: life,
      glow: glow,
    );
  }

  void dispose() {
    _ctrl.dispose();
  }
}

class Particle {
  double x; // 0..1 relative
  double y; // 0..1 relative
  final double size; // px approx
  final double speed; // relative units per second
  double life; // seconds
  final double glow;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.life,
    required this.glow,
  });

  void update(double dt) {
    y += speed * dt;
    life -= dt;
  }

  bool get isDead => life <= 0 || y > 1.15;
}

class ParticlePainter extends CustomPainter {
  final ParticleController controller;
  ParticlePainter({required this.controller})
    : super(repaint: controller._ctrl);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in controller.particles) {
      final px = p.x * size.width;
      final py = p.y * size.height;

      final paint = Paint()
        ..color = Colors.cyanAccent.withOpacity(p.glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(px, py), p.size + 1.8 * p.glow, paint);

      canvas.drawCircle(
        Offset(px, py),
        p.size * 0.6,
        Paint()..color = Colors.white.withOpacity(0.85 * p.glow),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
