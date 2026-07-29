import 'package:equatable/equatable.dart';

/// A doctor a patient can book an appointment with.
///
/// [availableDays] holds weekday numbers using `DateTime.monday`..`DateTime.sunday`
/// (1-7). [availableSlots] holds 24h `HH:mm` strings, e.g. `'09:30'`.
class DoctorEntity extends Equatable {
  const DoctorEntity({
    required this.id,
    required this.fullName,
    required this.departmentId,
    required this.specialty,
    required this.hospital,
    required this.availableDays,
    required this.availableSlots,
    this.rating = 0,
    this.yearsExperience = 0,
    this.consultationFee = 0,
    this.isAcceptingPatients = true,
  });

  final String id;
  final String fullName;
  final String departmentId;
  final String specialty;
  final String hospital;
  final List<int> availableDays;
  final List<String> availableSlots;
  final double rating;
  final int yearsExperience;
  final int consultationFee;
  final bool isAcceptingPatients;

  /// Initials for the avatar placeholder, e.g. "Dr. Aline Uwase" -> "AU".
  String get initials => fullName
      .replaceAll('Dr. ', '')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .take(2)
      .map((word) => word[0])
      .join()
      .toUpperCase();

  bool worksOn(DateTime date) => availableDays.contains(date.weekday);

  @override
  List<Object?> get props => [
        id,
        fullName,
        departmentId,
        specialty,
        hospital,
        availableDays,
        availableSlots,
        rating,
        yearsExperience,
        consultationFee,
        isAcceptingPatients,
      ];
}
