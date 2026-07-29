import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kivu_haqms/core/constants/firebase_constants.dart';
import 'package:kivu_haqms/features/auth/domain/entities/user_entity.dart';
import 'package:kivu_haqms/features/auth/domain/repositories/auth_repository.dart';
import 'package:kivu_haqms/features/profile/data/datasources/profile_preferences_local_data_source.dart';
import 'package:kivu_haqms/features/profile/data/models/profile_model.dart';
import 'package:kivu_haqms/features/profile/domain/entities/profile_entity.dart';
import 'package:kivu_haqms/features/profile/domain/repositories/profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({
    required this.authRepository,
    FirebaseFirestore? firestore,
    ProfilePreferencesLocalDataSource? preferencesDataSource,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _preferencesDataSource =
            preferencesDataSource ?? ProfilePreferencesLocalDataSource();

  final AuthRepository authRepository;
  final FirebaseFirestore _firestore;
  final ProfilePreferencesLocalDataSource _preferencesDataSource;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(FirebaseConstants.usersCollection);

  @override
  Future<ProfileEntity> getProfile(UserEntity authUser) async {
    final doc = await _usersCollection.doc(authUser.id).get();
    final pushNotificationsEnabled =
        await _preferencesDataSource.getPushNotificationsEnabled(authUser.id);
    final appointmentRemindersEnabled =
        await _preferencesDataSource.getAppointmentRemindersEnabled(authUser.id);

    return ProfileModel.fromAuthUser(
      authUser,
      firestoreData: doc.data(),
      pushNotificationsEnabled: pushNotificationsEnabled,
      appointmentRemindersEnabled: appointmentRemindersEnabled,
    );
  }

  @override
  Future<ProfileEntity> updateProfile(ProfileEntity profile) async {
    if (profile.displayName.trim().isEmpty) {
      throw Exception('Display name cannot be empty.');
    }

    final updatedAuthUser = await authRepository.updateUserProfile(
      displayName: profile.displayName.trim(),
    );

    final model = ProfileModel(
      userId: profile.userId,
      displayName: updatedAuthUser.displayName,
      email: updatedAuthUser.email,
      phoneNumber: profile.phoneNumber?.trim().isEmpty ?? true
          ? null
          : profile.phoneNumber?.trim(),
      dateOfBirth: profile.dateOfBirth,
      emergencyContactName: profile.emergencyContactName?.trim().isEmpty ?? true
          ? null
          : profile.emergencyContactName?.trim(),
      emergencyContactPhone:
          profile.emergencyContactPhone?.trim().isEmpty ?? true
              ? null
              : profile.emergencyContactPhone?.trim(),
      pushNotificationsEnabled: profile.pushNotificationsEnabled,
      appointmentRemindersEnabled: profile.appointmentRemindersEnabled,
    );

    await _usersCollection
        .doc(profile.userId)
        .set(model.toFirestoreMap(), SetOptions(merge: true));

    return model;
  }

  @override
  Future<ProfileEntity> updatePreferences({
    required String userId,
    bool? pushNotificationsEnabled,
    bool? appointmentRemindersEnabled,
  }) async {
    final authUser = await authRepository.getCurrentUser();
    if (authUser == null || authUser.id != userId) {
      throw Exception('You must be signed in to update preferences.');
    }

    if (pushNotificationsEnabled != null) {
      await _preferencesDataSource.setPushNotificationsEnabled(
        userId,
        pushNotificationsEnabled,
      );
    }

    if (appointmentRemindersEnabled != null) {
      await _preferencesDataSource.setAppointmentRemindersEnabled(
        userId,
        appointmentRemindersEnabled,
      );
    }

    return getProfile(authUser);
  }
}
