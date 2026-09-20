import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';

/// Vertical swipe-to-reveal interaction for secret role distribution.
///
/// The user physically swipes upward to reveal hidden content.
/// An arrow indicator transforms from ↑ to ↓ as the drag completes.
/// Content is revealed via ClipRect + vertical offset.
class RevealGesture extends StatefulWidget {
  final Widget hiddenContent;
  final VoidCallback onRevealed;
  final Color accentColor;

  const RevealGesture({
    super.key,
    required this.hiddenContent,
    required this.onRevealed,
    this.accentColor = WKColors.offWhite,
  });

  @override
  State<RevealGesture> createState() => _RevealGestureState();
}

class _RevealGestureState extends State<RevealGesture>
    with SingleTickerProviderStateMixin {
  double _dragProgress = 0.0; // 0 = hidden, 1 = fully revealed
  bool _isRevealed = false;
  late AnimationController _snapController;
  late Animation<double> _snapAnimation;
  static const double _revealThreshold = 0.45;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _snapAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOut),
    );
    _snapController.addListener(() {
      setState(() {
        _dragProgress = _snapAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isRevealed) return;
    setState(() {
      // Negative dy = upward drag → increase progress
      _dragProgress = (_dragProgress - details.primaryDelta! / 250)
          .clamp(0.0, 1.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isRevealed) return;
    if (_dragProgress >= _revealThreshold) {
      // Snap to fully revealed
      _snapAnimation = Tween<double>(
        begin: _dragProgress,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _snapController..reset(),
        curve: Curves.easeOut,
      ));
      _snapController.forward();
      _isRevealed = true;
      HapticFeedback.mediumImpact();
      widget.onRevealed();
    } else {
      // Snap back to hidden
      _snapAnimation = Tween<double>(
        begin: _dragProgress,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _snapController..reset(),
        curve: Curves.easeOut,
      ));
      _snapController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Arrow rotates from pointing up (0°) to pointing down (180°)
    final arrowRotation = _dragProgress * 3.14159;
    // Arrow opacity fades as drag completes
    final arrowOpacity = (1.0 - _dragProgress * 0.7).clamp(0.3, 1.0);
    // Arrow scale shrinks as drag progresses
    final arrowScale = 1.0 - _dragProgress * 0.3;

    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      onTap: !_isRevealed
          ? () {
              // Allow tap as fallback
              _snapAnimation = Tween<double>(
                begin: _dragProgress,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: _snapController..reset(),
                curve: Curves.easeOut,
              ));
              _snapController.forward();
              _isRevealed = true;
              HapticFeedback.mediumImpact();
              widget.onRevealed();
            }
          : null,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 220),
        decoration: BoxDecoration(
          color: WKColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.accentColor.withValues(alpha: 0.15 + _dragProgress * 0.35),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hidden content (revealed by progress)
            Opacity(
              opacity: _dragProgress,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - _dragProgress)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: widget.hiddenContent,
                ),
              ),
            ),
            // Arrow indicator overlay (fades out as content appears)
            if (!_isRevealed || _dragProgress < 1.0)
              Opacity(
                opacity: arrowOpacity,
                child: Transform.scale(
                  scale: arrowScale,
                  child: Transform.rotate(
                    angle: arrowRotation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: widget.accentColor,
                          size: 48,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isRevealed ? '' : 'SLIDE UP\nTO REVEAL',
                          style: WKTypography.label.copyWith(
                            color: widget.accentColor.withValues(alpha: 0.7),
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
