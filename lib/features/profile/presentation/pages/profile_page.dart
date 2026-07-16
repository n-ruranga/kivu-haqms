import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/core/widgets/placeholder_page.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';

/// Placeholder profile screen — Naillah will implement view/edit + preferences.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Profile',
      subtitle: 'Profile & preferences — Naillah',
      actionLabel: 'Sign out',
      onAction: () => context.read<AuthCubit>().signOut(),
    );
  }
}
