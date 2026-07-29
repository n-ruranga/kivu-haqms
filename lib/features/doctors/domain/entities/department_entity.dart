import 'package:equatable/equatable.dart';

/// A hospital department a patient can book into (Cardiology, Pediatrics...).
///
/// `iconKey` is stored as a plain string in Firestore and mapped to a Material
/// icon in the presentation layer, so the domain stays free of Flutter types.
class DepartmentEntity extends Equatable {
  const DepartmentEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.iconKey,
    this.doctorCount = 0,
  });

  final String id;
  final String name;
  final String description;
  final String iconKey;
  final int doctorCount;

  @override
  List<Object?> get props => [id, name, description, iconKey, doctorCount];
}
