import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      forceMaterialTransparency: true,
      automaticallyImplyLeading: false,
      // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(
        title,
      ),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(45 + (bottom?.preferredSize.height ?? 0.0));
}
