import 'package:flutter/material.dart';
import '../theme/wk_colors.dart';

/// Wraps game screens to ensure a centered, mobile-first experience
/// on wide tablet and desktop/web screens without stretching.
class ResponsiveScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final double maxWidth;

  const ResponsiveScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.maxWidth = 480.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WKColors.black,
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: WKColors.black,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}
