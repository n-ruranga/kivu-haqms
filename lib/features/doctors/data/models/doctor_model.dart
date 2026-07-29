import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';

/// Firestore <-> domain mapping for a `doctors/{doctorId}` document.
class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.fullName,
    required super.departmentId,
    required super.specialty,
    required super.hospital,
    required super.availableDays,
    required super.availableSlots,
    super.rating,
    super.yearsExperience,
    super.consultationFee,
    super.isAcceptingPatients,
  });

  factory DoctorModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return DoctorModel.fromMap(doc.id, doc.data());
  }

  /// Testable mapping — see `AppointmentModel.fromMap`.
  factory DoctorModel.fromMap(String id, Map<String, dynamic>? raw) {
    final data = raw ?? const <String, dynamic>{};

    return DoctorModel(
      id: id,
      fullName: data['fullName'] as String? ?? 'Unknown doctor',
      departmentId: data['departmentId'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      hospital: data['hospital'] as String? ?? '',
      availableDays: (data['availableDays'] as List<dynamic>? ?? const [])
          .map((day) => (day as num).toInt())
          .toList(),
      availableSlots: (data['availableSlots'] as List<dynamic>? ?? const [])
          .map((slot) => slot as String)
          .toList(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      yearsExperience: (data['yearsExperience'] as num?)?.toInt() ?? 0,
      consultationFee: (data['consultationFee'] as num?)?.toInt() ?? 0,
      isAcceptingPatients: data['isAcceptingPatients'] as bool? ?? true,
    );
  }

  factory DoctorModel.fromEntity(DoctorEntity entity) {
    return DoctorModel(
      id: entity.id,
      fullName: entity.fullName,
      departmentId: entity.departmentId,
      specialty: entity.specialty,
      hospital: entity.hospital,
      availableDays: entity.availableDays,
      availableSlots: entity.availableSlots,
      rating: entity.rating,
      yearsExperience: entity.yearsExperience,
      consultationFee: entity.consultationFee,
      isAcceptingPatients: entity.isAcceptingPatients,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'departmentId': departmentId,
      'specialty': specialty,
      'hospital': hospital,
      'availableDays': availableDays,
      'availableSlots': availableSlots,
      'rating': rating,
      'yearsExperience': yearsExperience,
      'consultationFee': consultationFee,
      'isAcceptingPatients': isAcceptingPatients,
    };
  }
}
