import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kivu_haqms/features/auth/domain/entities/user_entity.dart';
import 'package:kivu_haqms/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.userId,
    required super.displayName,
    super.email,
    super.phoneNumber,
    super.dateOfBirth,
    super.emergencyContactName,
    super.emergencyContactPhone,
    super.pushNotificationsEnabled,
    super.appointmentRemindersEnabled,
  });

  factory ProfileModel.fromAuthUser(
    UserEntity authUser, {
    Map<String, dynamic>? firestoreData,
    bool pushNotificationsEnabled = true,
    bool appointmentRemindersEnabled = true,
  }) {
    final data = firestoreData ?? const <String, dynamic>{};

    return ProfileModel(
      userId: authUser.id,
      displayName: authUser.displayName,
      email: authUser.email,
      phoneNumber: data['phoneNumber'] as String? ?? authUser.phoneNumber,
      dateOfBirth: _parseDate(data['dateOfBirth']),
      emergencyContactName: data['emergencyContactName'] as String?,
      emergencyContactPhone: data['emergencyContactPhone'] as String?,
      pushNotificationsEnabled: pushNotificationsEnabled,
      appointmentRemindersEnabled: appointmentRemindersEnabled,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
