import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/widgets/kivu_bottom_nav.dart';

/// Scaffold wrapper for the four main tabs with bottom navigation.
class MainShellPage extends StatelessWidget {
  const MainShellPage({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: KivuBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
      ),
    );
  }
}
