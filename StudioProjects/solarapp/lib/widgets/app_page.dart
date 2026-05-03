import 'package:flutter/material.dart';

import 'app_spacing.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.child,
    this.padding = AppInsets.page,
    this.maxWidth = AppBreakpoints.ultraWide,
    this.scroll = false,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final EdgeInsets padding;
  final double maxWidth;
  final bool scroll;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final effectiveMaxWidth = constraints.maxWidth > maxWidth
              ? maxWidth
              : double.infinity;

          final content = Align(
            alignment: alignment,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
              child: Padding(padding: padding, child: child),
            ),
          );

          if (!scroll) return content;

          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: content,
          );
        },
      ),
    );
  }
}
