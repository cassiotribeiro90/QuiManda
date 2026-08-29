import 'package:flutter/material.dart';
import '../modules/home/views/home_view.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.automaticallyImplyLeading = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: titleWidget ?? (title != null 
          ? Text(
              title!,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
          : null),
      leading: leading ?? (!isDesktop
          ? IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                HomeView.scaffoldKey.currentState?.openDrawer();
              },
            )
          : null),
      actions: actions,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
