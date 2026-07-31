import 'package:equatable/equatable.dart';

/// Extended user profile — auth fields plus Firestore and local preferences.
class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.userId,
    required this.displayName,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.pushNotificationsEnabled = true,
    this.appointmentRemindersEnabled = true,
  });

  final String userId;
  final String displayName;
  final String? email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final bool pushNotificationsEnabled;
  final bool appointmentRemindersEnabled;

  ProfileEntity copyWith({
    String? displayName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? emergencyContactName,
    String? emergencyContactPhone,
    bool? pushNotificationsEnabled,
    bool? appointmentRemindersEnabled,
    bool clearDateOfBirth = false,
    bool clearEmergencyContactName = false,
    bool clearEmergencyContactPhone = false,
    bool clearPhoneNumber = false,
  }) {
    return ProfileEntity(
      userId: userId,
      displayName: displayName ?? this.displayName,
      email: email,
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      emergencyContactName: clearEmergencyContactName
          ? null
          : (emergencyContactName ?? this.emergencyContactName),
      emergencyContactPhone: clearEmergencyContactPhone
          ? null
          : (emergencyContactPhone ?? this.emergencyContactPhone),
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      appointmentRemindersEnabled:
          appointmentRemindersEnabled ?? this.appointmentRemindersEnabled,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        email,
        phoneNumber,
        dateOfBirth,
        emergencyContactName,
        emergencyContactPhone,
        pushNotificationsEnabled,
        appointmentRemindersEnabled,
      ];
}
