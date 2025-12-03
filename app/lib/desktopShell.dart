import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

class DesktopShell extends StatelessWidget {
  final Widget child;

  const DesktopShell({super.key, this.child = const SizedBox.shrink()});

  bool get _isDesktopLike => UniversalPlatform.isDesktop || UniversalPlatform.isWeb;

  @override
  Widget build(BuildContext context) {
    if (!_isDesktopLike) {
      return child;
    }

    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SizedBox.expand(child: child),
        ),
      ),
    );
  }
}
