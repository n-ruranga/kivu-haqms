import 'package:flutter/material.dart';

/// Maps the `iconKey` stored on a department document to a Material icon.
///
/// Keeping the lookup in the presentation layer means Firestore only ever
/// stores a plain string and the domain never imports Flutter.
abstract final class DepartmentIcons {
  static const Map<String, IconData> _icons = {
    'general': Icons.medical_services_outlined,
    'cardiology': Icons.favorite_outline,
    'pediatrics': Icons.child_care_outlined,
    'maternity': Icons.pregnant_woman_outlined,
    'dentistry': Icons.medication_outlined,
    'ophthalmology': Icons.visibility_outlined,
    'orthopedics': Icons.accessibility_new_outlined,
    'dermatology': Icons.healing_outlined,
  };

  static IconData forKey(String iconKey) =>
      _icons[iconKey] ?? Icons.local_hospital_outlined;
}
