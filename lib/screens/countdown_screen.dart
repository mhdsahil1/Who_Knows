import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../widgets/countdown_dial.dart';
import '../widgets/responsive_scaffold.dart';

/// Screen — Countdown: Dramatic 3-2-1 transition before Discussion begins.
class CountdownScreen extends StatelessWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = context.read<GameEngine>();

    return PopScope(
      canPop: false,
      child: ResponsiveScaffold(
        child: CountdownDial(
          onComplete: () {
            engine.completeCountdown();
          },
        ),
      ),
    );
  }
}
