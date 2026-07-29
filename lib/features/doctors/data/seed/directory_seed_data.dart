import 'package:kivu_haqms/features/doctors/domain/entities/department_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';

/// Reference data written to Firestore the first time the app finds the
/// `departments` collection empty, so a fresh Firebase project is demo-ready.
///
/// This is *reference* data only — appointments are always created by the user.
abstract final class DirectorySeedData {
  static const List<String> morningSlots = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
  ];

  static const List<String> afternoonSlots = [
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
  ];

  static const List<String> fullDaySlots = [
    ...morningSlots,
    ...afternoonSlots,
  ];

  /// Monday - Friday.
  static const List<int> weekdays = [1, 2, 3, 4, 5];

  /// Monday, Wednesday, Friday.
  static const List<int> altWeekdays = [1, 3, 5];

  /// Tuesday, Thursday, Saturday.
  static const List<int> midWeekdays = [2, 4, 6];

  static const List<DepartmentEntity> departments = [
    DepartmentEntity(
      id: 'general',
      name: 'General Medicine',
      description: 'Consultations, check-ups and referrals',
      iconKey: 'general',
      doctorCount: 2,
    ),
    DepartmentEntity(
      id: 'cardiology',
      name: 'Cardiology',
      description: 'Heart and blood vessel care',
      iconKey: 'cardiology',
      doctorCount: 2,
    ),
    DepartmentEntity(
      id: 'pediatrics',
      name: 'Pediatrics',
      description: 'Healthcare for children under 16',
      iconKey: 'pediatrics',
      doctorCount: 2,
    ),
    DepartmentEntity(
      id: 'maternity',
      name: 'Maternity',
      description: 'Antenatal, delivery and postnatal care',
      iconKey: 'maternity',
      doctorCount: 1,
    ),
    DepartmentEntity(
      id: 'dentistry',
      name: 'Dentistry',
      description: 'Dental check-ups and oral surgery',
      iconKey: 'dentistry',
      doctorCount: 1,
    ),
    DepartmentEntity(
      id: 'ophthalmology',
      name: 'Ophthalmology',
      description: 'Eye tests and vision care',
      iconKey: 'ophthalmology',
      doctorCount: 1,
    ),
  ];

  static const List<DoctorEntity> doctors = [
    DoctorEntity(
      id: 'doc-nsengimana',
      fullName: 'Dr. Eric Nsengimana',
      departmentId: 'cardiology',
      specialty: 'Cardiology Specialist',
      hospital: 'Kigali Central Hospital',
      availableDays: weekdays,
      availableSlots: fullDaySlots,
      rating: 4.8,
      yearsExperience: 12,
      consultationFee: 15000,
    ),
    DoctorEntity(
      id: 'doc-mukamana',
      fullName: 'Dr. Alice Mukamana',
      departmentId: 'cardiology',
      specialty: 'Interventional Cardiologist',
      hospital: 'King Faisal Hospital',
      availableDays: altWeekdays,
      availableSlots: morningSlots,
      rating: 4.6,
      yearsExperience: 9,
      consultationFee: 20000,
    ),
    DoctorEntity(
      id: 'doc-habimana',
      fullName: 'Dr. Jean Habimana',
      departmentId: 'general',
      specialty: 'General Practitioner',
      hospital: 'Kibagabaga Hospital',
      availableDays: weekdays,
      availableSlots: fullDaySlots,
      rating: 4.5,
      yearsExperience: 7,
      consultationFee: 8000,
    ),
    DoctorEntity(
      id: 'doc-uwase',
      fullName: 'Dr. Aline Uwase',
      departmentId: 'general',
      specialty: 'Family Medicine',
      hospital: 'Masaka District Hospital',
      availableDays: midWeekdays,
      availableSlots: afternoonSlots,
      rating: 4.7,
      yearsExperience: 10,
      consultationFee: 8000,
    ),
    DoctorEntity(
      id: 'doc-ingabire',
      fullName: 'Dr. Claudine Ingabire',
      departmentId: 'pediatrics',
      specialty: 'Pediatrician',
      hospital: 'Kigali Central Hospital',
      availableDays: weekdays,
      availableSlots: morningSlots,
      rating: 4.9,
      yearsExperience: 14,
      consultationFee: 12000,
    ),
    DoctorEntity(
      id: 'doc-rwigema',
      fullName: 'Dr. Patrick Rwigema',
      departmentId: 'pediatrics',
      specialty: 'Neonatologist',
      hospital: 'Rwanda Military Hospital',
      availableDays: altWeekdays,
      availableSlots: fullDaySlots,
      rating: 4.4,
      yearsExperience: 6,
      consultationFee: 12000,
    ),
    DoctorEntity(
      id: 'doc-umutoni',
      fullName: 'Dr. Grace Umutoni',
      departmentId: 'maternity',
      specialty: 'Obstetrician & Gynecologist',
      hospital: 'King Faisal Hospital',
      availableDays: weekdays,
      availableSlots: fullDaySlots,
      rating: 4.8,
      yearsExperience: 11,
      consultationFee: 18000,
    ),
    DoctorEntity(
      id: 'doc-kagabo',
      fullName: 'Dr. Samuel Kagabo',
      departmentId: 'dentistry',
      specialty: 'Dental Surgeon',
      hospital: 'Kibagabaga Hospital',
      availableDays: midWeekdays,
      availableSlots: morningSlots,
      rating: 4.3,
      yearsExperience: 8,
      consultationFee: 10000,
    ),
    DoctorEntity(
      id: 'doc-niyonsaba',
      fullName: 'Dr. Diane Niyonsaba',
      departmentId: 'ophthalmology',
      specialty: 'Ophthalmologist',
      hospital: 'Kigali Central Hospital',
      availableDays: altWeekdays,
      availableSlots: afternoonSlots,
      rating: 4.6,
      yearsExperience: 9,
      consultationFee: 14000,
    ),
  ];
}
