import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/features/auth/domain/entities/user_entity.dart';
import 'package:kivu_haqms/features/profile/domain/entities/profile_entity.dart';
import 'package:kivu_haqms/features/profile/domain/repositories/profile_repository.dart';
import 'package:kivu_haqms/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileInitial());

  final ProfileRepository _repository;

  Future<void> loadProfile(UserEntity authUser) async {
    emit(const ProfileLoading());
    try {
      final profile = await _repository.getProfile(authUser);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> updateProfile(ProfileEntity profile) async {
    final previous = _currentProfile;
    emit(ProfileSaving(previous ?? profile));
    try {
      final updated = await _repository.updateProfile(profile);
      emit(ProfileSaved(updated));
      emit(ProfileLoaded(updated));
    } catch (e) {
      emit(ProfileFailure(e.toString(), previousProfile: previous));
      if (previous != null) {
        emit(ProfileLoaded(previous));
      }
    }
  }

  Future<void> updatePushNotifications({
    required String userId,
    required bool enabled,
  }) async {
    await _updatePreference(
      userId: userId,
      pushNotificationsEnabled: enabled,
    );
  }

  Future<void> updateAppointmentReminders({
    required String userId,
    required bool enabled,
  }) async {
    await _updatePreference(
      userId: userId,
      appointmentRemindersEnabled: enabled,
    );
  }

  Future<void> _updatePreference({
    required String userId,
    bool? pushNotificationsEnabled,
    bool? appointmentRemindersEnabled,
  }) async {
    final previous = _currentProfile;
    if (previous == null) return;

    final optimistic = previous.copyWith(
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? previous.pushNotificationsEnabled,
      appointmentRemindersEnabled:
          appointmentRemindersEnabled ?? previous.appointmentRemindersEnabled,
    );
    emit(ProfileLoaded(optimistic));

    try {
      final updated = await _repository.updatePreferences(
        userId: userId,
        pushNotificationsEnabled: pushNotificationsEnabled,
        appointmentRemindersEnabled: appointmentRemindersEnabled,
      );
      emit(ProfileLoaded(updated));
    } catch (e) {
      emit(ProfileFailure(e.toString(), previousProfile: previous));
      emit(ProfileLoaded(previous));
    }
  }

  ProfileEntity? get _currentProfile {
    final state = this.state;
    return switch (state) {
      ProfileLoaded(:final profile) => profile,
      ProfileSaving(:final profile) => profile,
      ProfileSaved(:final profile) => profile,
      ProfileFailure(:final previousProfile) => previousProfile,
      _ => null,
    };
  }
}
