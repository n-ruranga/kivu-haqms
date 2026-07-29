import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kivu_haqms/core/constants/firebase_constants.dart';
import 'package:kivu_haqms/features/doctors/data/models/department_model.dart';
import 'package:kivu_haqms/features/doctors/data/models/doctor_model.dart';
import 'package:kivu_haqms/features/doctors/data/seed/directory_seed_data.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/department_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/repositories/doctor_repository.dart';

/// Reads the department / doctor directory from Cloud Firestore.
///
/// On the very first call the `departments` collection is usually empty on a
/// fresh Firebase project, so we write [DirectorySeedData] once in a batch and
/// carry on. Every later launch is a plain read.
class FirestoreDoctorRepository implements DoctorRepository {
  FirestoreDoctorRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  bool _seedChecked = false;

  CollectionReference<Map<String, dynamic>> get _departments =>
      _firestore.collection(FirebaseConstants.departmentsCollection);

  CollectionReference<Map<String, dynamic>> get _doctors =>
      _firestore.collection(FirebaseConstants.doctorsCollection);

  @override
  Future<List<DepartmentEntity>> getDepartments() async {
    try {
      var snapshot = await _departments.orderBy('name').get();

      if (snapshot.docs.isEmpty) {
        await _seedDirectoryIfNeeded();
        snapshot = await _departments.orderBy('name').get();
      }

      return snapshot.docs.map(DepartmentModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'load departments'));
    }
  }

  @override
  Future<List<DoctorEntity>> getDoctorsByDepartment(String departmentId) async {
    try {
      final snapshot = await _doctors
          .where('departmentId', isEqualTo: departmentId)
          .where('isAcceptingPatients', isEqualTo: true)
          .get();

      final doctors = snapshot.docs.map(DoctorModel.fromFirestore).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));

      return doctors;
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'load doctors'));
    }
  }

  @override
  Future<DoctorEntity?> getDoctorById(String doctorId) async {
    try {
      final doc = await _doctors.doc(doctorId).get();
      if (!doc.exists) return null;
      return DoctorModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'load that doctor'));
    }
  }

  /// Writes departments + doctors in a single batch. Safe to call twice: the
  /// documents use fixed IDs, so a repeat run overwrites rather than duplicates.
  Future<void> _seedDirectoryIfNeeded() async {
    if (_seedChecked) return;
    _seedChecked = true;

    final batch = _firestore.batch();

    for (final department in DirectorySeedData.departments) {
      batch.set(
        _departments.doc(department.id),
        DepartmentModel.fromEntity(department).toMap(),
      );
    }

    for (final doctor in DirectorySeedData.doctors) {
      batch.set(
        _doctors.doc(doctor.id),
        DoctorModel.fromEntity(doctor).toMap(),
      );
    }

    await batch.commit();
    debugPrint('Seeded ${DirectorySeedData.departments.length} departments and '
        '${DirectorySeedData.doctors.length} doctors into Firestore.');
  }

  String _mapFirestoreError(FirebaseException e, String action) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to $action.';
      case 'unavailable':
        return 'No connection to the server. Check your internet and try again.';
      case 'failed-precondition':
        return 'The database is missing an index for this query. '
            'Open the link in the console log to create it.';
      default:
        return e.message ?? 'Could not $action. Please try again.';
    }
  }
}
