import 'package:flutter/material.dart';
import 'package:lab1/widgets/theme_toggle_button.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final List<Widget>? actions;

  const AppScaffold({
    this.title,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.scrollable = false,
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appBar = title != null
        ? AppBar(
            title: Text(title!),
            actions: [
              if (actions != null) ...actions!,
              const ThemeToggleButton(),
            ],
          )
        : null;

    final body = Padding(padding: padding, child: child);

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: scrollable ? SingleChildScrollView(child: body) : body,
      ),
    );
  }
}
