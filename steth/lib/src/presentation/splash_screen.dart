import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../utils/size_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    for (int i = 0; i < 3; i++) {
      final delay = i * 0.2;
      final begin = 0.1;
      final end = 0.8;

      final endInterval = (delay + 0.7) > 1.0 ? 1.0 : (delay + 0.7);

      final Animation<double> sizeAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 60,
        ),
        TweenSequenceItem(tween: ConstantTween<double>(end), weight: 40),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, endInterval, curve: Curves.easeOut),
        ),
      );

      final Animation<double> opacityAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.7, end: 0.0),
          weight: 100,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, endInterval, curve: Curves.easeOut),
        ),
      );

      _animations.add(sizeAnimation);
      _animations.add(opacityAnimation);
    }

    // Start animation
    _controller.repeat();

    // Navigate to next screen after delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(AppConstants.splashDelay, () {
        context.go('/phone');
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize SizeConfig if not already done
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated waves
            ...List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width:
                        100 *
                        SizeConfig.blockSizeHorizontal *
                        _animations[index * 2].value,
                    height:
                        100 *
                        SizeConfig.blockSizeHorizontal *
                        _animations[index * 2].value,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        _animations[index * 2 + 1].value,
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),

            // Center logo container - adjusted to ensure visibility
            Container(
              width: 40 * SizeConfig.blockSizeHorizontal,
              height: 40 * SizeConfig.blockSizeHorizontal,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                // Add shadow to make it stand out more
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/Stethaim_logo.png',
                  width: 30 * SizeConfig.blockSizeHorizontal,
                  height: 30 * SizeConfig.blockSizeHorizontal,
                  // Error handling for missing asset
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading logo: $error');
                    return Icon(
                      Icons.medical_services,
                      size: 24 * SizeConfig.blockSizeHorizontal,
                      color: AppConstants.primaryColor,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
