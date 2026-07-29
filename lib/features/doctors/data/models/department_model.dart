import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/department_entity.dart';

/// Firestore <-> domain mapping for a `departments/{departmentId}` document.
class DepartmentModel extends DepartmentEntity {
  const DepartmentModel({
    required super.id,
    required super.name,
    required super.description,
    required super.iconKey,
    super.doctorCount,
  });

  factory DepartmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return DepartmentModel.fromMap(doc.id, doc.data());
  }

  /// Testable mapping — see `AppointmentModel.fromMap`.
  factory DepartmentModel.fromMap(String id, Map<String, dynamic>? raw) {
    final data = raw ?? const <String, dynamic>{};

    return DepartmentModel(
      id: id,
      name: data['name'] as String? ?? 'Unknown department',
      description: data['description'] as String? ?? '',
      iconKey: data['iconKey'] as String? ?? 'general',
      doctorCount: (data['doctorCount'] as num?)?.toInt() ?? 0,
    );
  }

  factory DepartmentModel.fromEntity(DepartmentEntity entity) {
    return DepartmentModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      iconKey: entity.iconKey,
      doctorCount: entity.doctorCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'iconKey': iconKey,
      'doctorCount': doctorCount,
    };
  }
}
