import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/constants/app_routes.dart';
import 'package:kivu_haqms/core/constants/app_strings.dart';
import 'package:kivu_haqms/core/theme/theme_cubit.dart';
import 'package:kivu_haqms/core/theme/theme_state.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_state.dart';
import 'package:kivu_haqms/features/profile/domain/entities/profile_entity.dart';
import 'package:kivu_haqms/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:kivu_haqms/features/profile/presentation/cubit/profile_state.dart';
import 'package:kivu_haqms/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:kivu_haqms/features/profile/presentation/widgets/profile_info_row.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileCubit>().loadProfile(authState.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return switch (state) {
              ProfileInitial() || ProfileLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              ProfileLoaded(:final profile) ||
              ProfileSaving(:final profile) ||
              ProfileSaved(:final profile) =>
                _ProfileContent(profile: profile, isSaving: state is ProfileSaving),
              ProfileFailure(:final previousProfile) when previousProfile != null =>
                _ProfileContent(profile: previousProfile),
              ProfileFailure() => _ProfileError(onRetry: _loadProfile),
            };
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.profile,
    this.isSaving = false,
  });

  final ProfileEntity profile;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final dateFormat = MaterialLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.profileTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton.icon(
                onPressed: isSaving
                    ? null
                    : () => context.push(AppRoutes.profileEdit),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text(AppStrings.editProfile),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                ProfileAvatar(name: profile.displayName),
                const SizedBox(height: 16),
                Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                if (profile.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.email!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.personalInfo,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _ProfileCard(
            child: Column(
              children: [
                ProfileInfoRow(
                  icon: Icons.phone_outlined,
                  label: AppStrings.phoneNumber,
                  value: profile.phoneNumber ?? AppStrings.notProvided,
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                ProfileInfoRow(
                  icon: Icons.cake_outlined,
                  label: AppStrings.dateOfBirth,
                  value: profile.dateOfBirth != null
                      ? dateFormat.formatMediumDate(profile.dateOfBirth!)
                      : AppStrings.notProvided,
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                ProfileInfoRow(
                  icon: Icons.contact_emergency_outlined,
                  label: AppStrings.emergencyContact,
                  value: _formatEmergencyContact(profile),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.preferences,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _ProfileCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.pushNotifications),
                  subtitle: Text(
                    AppStrings.pushNotificationsDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  value: profile.pushNotificationsEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: isSaving
                      ? null
                      : (value) => context
                          .read<ProfileCubit>()
                          .updatePushNotifications(
                            userId: profile.userId,
                            enabled: value,
                          ),
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.appointmentReminders),
                  subtitle: Text(
                    AppStrings.appointmentRemindersDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  value: profile.appointmentRemindersEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: isSaving
                      ? null
                      : (value) => context
                          .read<ProfileCubit>()
                          .updateAppointmentReminders(
                            userId: profile.userId,
                            enabled: value,
                          ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.appearance,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _ProfileCard(
            child: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text(AppStrings.theme),
                  subtitle: Text(
                    AppStrings.themeDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _themeModeLabel(themeState.themeMode),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  onTap: () => _showThemePicker(context, themeState.themeMode),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.account,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _ProfileCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_reset_outlined),
                  title: const Text(AppStrings.resetPassword),
                  subtitle: Text(
                    AppStrings.resetPasswordDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  onTap: profile.email == null
                      ? null
                      : () => _sendPasswordReset(context, profile.email!),
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text(
                    AppStrings.signOut,
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () => context.read<AuthCubit>().signOut(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatEmergencyContact(ProfileEntity profile) {
    if (profile.emergencyContactName == null &&
        profile.emergencyContactPhone == null) {
      return AppStrings.notProvided;
    }

    final parts = <String>[
      if (profile.emergencyContactName != null) profile.emergencyContactName!,
      if (profile.emergencyContactPhone != null) profile.emergencyContactPhone!,
    ];
    return parts.join(' · ');
  }

  Future<void> _sendPasswordReset(BuildContext context, String email) async {
    await context.read<AuthCubit>().sendPasswordResetEmail(email);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.resetPasswordSent(email))),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => AppStrings.themeLight,
      ThemeMode.dark => AppStrings.themeDark,
      ThemeMode.system => AppStrings.themeSystem,
    };
  }

  Future<void> _showThemePicker(BuildContext context, ThemeMode current) async {
    final options = <(ThemeMode, String)>[
      (ThemeMode.light, AppStrings.themeLight),
      (ThemeMode.dark, AppStrings.themeDark),
      (ThemeMode.system, AppStrings.themeSystem),
    ];

    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.theme,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              for (final (mode, label) in options)
                ListTile(
                  title: Text(label),
                  trailing: current == mode
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(context, mode),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected != null && context.mounted) {
      await context.read<ThemeCubit>().setThemeMode(selected);
    }
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dividerColor),
      ),
      child: child,
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              AppStrings.profileLoadError,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(AppStrings.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
