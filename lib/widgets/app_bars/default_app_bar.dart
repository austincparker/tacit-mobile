import 'package:flutter/material.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget> actions;

  const DefaultAppBar({
    super.key,
    this.title = '',
    this.centerTitle = true,
    this.actions = const [],
  });

  static const double appBarHeight = 60;

  @override
  Size get preferredSize => const Size.fromHeight(appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Semantics(
        header: true,
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black,
              ),
        ),
      ),
      actions: actions,
      centerTitle: centerTitle,
    );
  }
}
