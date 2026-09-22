import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/game_constants.dart';
import '../game/game_engine.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/leave_game_dialog.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/setup_progress.dart';
import 'game_mode_screen.dart';

/// Setup Step 1/5 — WHO'S PLAYING?
class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addPlayer(GameEngine engine) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final success = engine.addPlayer(name);
    if (success) {
      _nameController.clear();
      _focusNode.requestFocus();
      setState(() => _errorText = null);
    } else {
      setState(() {
        if (engine.isNameTaken(name)) {
          _errorText = 'Name already taken';
        } else if (engine.state.players.length >= GameConstants.maxPlayers) {
          _errorText = 'Maximum ${GameConstants.maxPlayers} players';
        } else {
          _errorText = 'Invalid name';
        }
      });
    }
  }

  Future<void> _onLeave(GameEngine engine) async {
    final confirmed = await LeaveGameDialog.show(context);
    if (confirmed && mounted) {
      engine.leaveGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final players = engine.state.players;
    final canProceed = players.length >= GameConstants.minPlayers;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onLeave(engine);
      },
      child: ResponsiveScaffold(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _onLeave(engine),
                      child: const Icon(
                        Icons.close_rounded,
                        color: WKColors.textMuted,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    const SetupProgress(step: 1, total: 5),
                    const Spacer(),
                    const SizedBox(width: 24), // balance
                  ],
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  "WHO'S\nPLAYING?",
                  style: WKTypography.displayMedium.copyWith(
                    height: 0.95,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PLAYERS ${players.length} / ${GameConstants.maxPlayers}',
                  style: WKTypography.label.copyWith(
                    color: WKColors.textMuted,
                  ),
                ),
                const SizedBox(height: 20),
                // Player list
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      final number = (index + 1).toString().padLeft(2, '0');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: WKColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: WKColors.blackMedium),
                          ),
                          child: Row(
                            children: [
                              Text(
                                number,
                                style: WKTypography.number.copyWith(
                                  fontSize: 14,
                                  color: WKColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: WKColors.playerAccent(index)
                                      .withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    player.name[0].toUpperCase(),
                                    style: WKTypography.headingSmall.copyWith(
                                      fontSize: 14,
                                      color: WKColors.playerAccent(index),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  player.name.toUpperCase(),
                                  style: WKTypography.headingSmall.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  engine.removePlayer(player.id);
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: WKColors.textMuted,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Add player input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        focusNode: _focusNode,
                        textCapitalization: TextCapitalization.words,
                        style: WKTypography.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Player name...',
                          hintStyle: WKTypography.bodyMedium.copyWith(
                            color: WKColors.textMuted,
                          ),
                          errorText: _errorText,
                          filled: true,
                          fillColor: WKColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: WKColors.blackMedium),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: WKColors.blackMedium),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: WKColors.yellow,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _addPlayer(engine),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _addPlayer(engine),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: WKColors.yellow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: WKColors.black,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // NEXT button
                PrimaryButton(
                  text: 'NEXT',
                  onPressed: canProceed
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: engine,
                                child: const GameModeScreen(),
                              ),
                            ),
                          );
                        }
                      : null,
                ),
                if (!canProceed) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Need at least ${GameConstants.minPlayers} players',
                    style: WKTypography.bodySmall.copyWith(
                      color: WKColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
