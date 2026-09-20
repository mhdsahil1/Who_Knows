import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';

/// Full-screen 3-2-1 countdown with oversized numbers,
/// scale + fade transitions, and a semi-circular arc.
class CountdownDial extends StatefulWidget {
  final VoidCallback onComplete;

  const CountdownDial({super.key, required this.onComplete});

  @override
  State<CountdownDial> createState() => _CountdownDialState();
}

class _CountdownDialState extends State<CountdownDial>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  int _currentNumber = 3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _currentNumber = i);
      _controller.reset();
      _controller.forward();
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 900));
    }
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WKColors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = Tween<double>(begin: 0.5, end: 1.2).animate(
              CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
              ),
            );
            final opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
              ),
            );

            return Opacity(
              opacity: opacity.value,
              child: Transform.scale(
                scale: scale.value,
                child: Text(
                  '$_currentNumber',
                  style: WKTypography.numberLarge.copyWith(
                    fontSize: 160,
                    color: WKColors.offWhite,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
