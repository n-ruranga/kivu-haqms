# KIVU — Appointment Booking & Firestore CRUD

**Module:** Appointment booking · **Owner:** Kethia
**Branch:** `appointment_booking`

Companion document: [database-design-erd.md](database-design-erd.md)

---

## 1. What was built

| Deliverable | Where |
|-------------|-------|
| Booking screen (department, doctor, date, time) | `lib/features/appointments/presentation/pages/book_appointment_page.dart` |
| Confirmation screen | `lib/features/appointments/presentation/pages/booking_confirmation_page.dart` |
| Appointment list with cancel / reschedule | `lib/features/appointments/presentation/widgets/my_appointments_view.dart` (embedded in the Schedule tab) |
| Firestore CRUD | `lib/features/appointments/data/repositories/firestore_appointment_repository.dart` |
| Department / doctor directory | `lib/features/doctors/` |
| ERD & database design | `docs/database-design-erd.md` |
| Tests | `test/booking_cubit_test.dart`, `test/appointment_model_test.dart` |

---

## 2. Architecture

The feature follows the same Clean Architecture the rest of the app uses, with
**Cubit** (`flutter_bloc`) for state — no `setState` anywhere in the feature.

```
features/appointments/
├── domain/                         ← pure Dart, no Flutter, no Firebase
│   ├── entities/
│   │   ├── appointment_entity.dart
│   │   └── appointment_status.dart
│   └── repositories/
│       └── appointment_repository.dart      ← the CRUD contract
├── data/                           ← Firebase lives here and nowhere else
│   ├── models/appointment_model.dart        ← Firestore ⇄ domain mapping
│   └── repositories/firestore_appointment_repository.dart
└── presentation/
    ├── cubit/                      ← BookingCubit, MyAppointmentsCubit, RescheduleCubit
    ├── pages/
    └── widgets/
```

The dependency rule points inward: `presentation` → `domain` ← `data`. Pages
never import `cloud_firestore`; they hold a `BookingCubit`, which holds an
`AppointmentRepository` *interface*. That is what makes the cubit tests able to
run with no Firebase at all.

Repositories are provided once at the root in `lib/app.dart` via
`MultiRepositoryProvider`, and cubits are created per screen with
`context.read<AppointmentRepository>()`.

---

## 3. The booking flow

Four dependent steps on one scrolling screen, each invalidating the ones after
it — picking a new department clears the doctor, date and slot.

```
Home / Schedule "＋"
      │
      ▼
BookAppointmentPage
  1. Department   → getDepartments()
  2. Doctor       → getDoctorsByDepartment(departmentId)
  3. Date         → next 14 days the doctor actually works
  4. Time         → doctor's slots − already-booked − times past today
  5. Reason (optional)
      │  Confirm booking
      ▼
BookingCubit.submitBooking()  →  createAppointment()
      │
      ▼
BookingConfirmationPage  →  Schedule tab
```

Details worth noting:

- **Step 3 is computed, not stored.** `selectableDates` filters the next 14
  days through the doctor's `availableDays`, so a Mon/Wed/Fri doctor never
  offers a Tuesday.
- **Past times disappear.** If the selected date is today, slots earlier than
  `DateTime.now()` are filtered out.
- **Taken slots are visible but disabled** — struck through, not hidden, so the
  patient can see the doctor is busy rather than wondering why 09:00 vanished.
- **Selecting a doctor auto-selects their next working day**, so the slot grid
  is never empty when it first appears.
- The Confirm button stays disabled until all four steps are complete
  (`BookingState.canSubmit`).

---

## 4. Firestore CRUD

All four operations sit behind `AppointmentRepository`. Collection:
`appointments`.

### CREATE — `createAppointment`

```dart
final taken = await getBookedSlots(doctorId: ..., date: ...);
if (taken.contains(appointment.timeSlot)) {
  throw Exception('That slot has just been taken. Please pick another time.');
}
final doc = await _appointments.add(model.toMap());
return appointment.copyWith(id: doc.id);
```

Called from `BookingCubit.submitBooking()`. New appointments are always written
with `status: pending` — the hospital confirms them, the patient does not
confirm their own booking. The generated document id is copied back onto the
returned entity so the confirmation screen can show it.

### READ — four shapes, each matching a screen

| Method | Query | Used by |
|--------|-------|---------|
| `getDepartments()` | `departments` ordered by name | Booking step 1 |
| `getDoctorsByDepartment()` | `departmentId ==` + `isAcceptingPatients == true` | Booking step 2 |
| `getBookedSlots()` | `doctorId ==` + `scheduledAt` within the day | Booking step 4 |
| `watchAppointmentsForPatient()` | `patientId ==`, ordered by `scheduledAt` desc, **live** | Schedule |

`watchAppointmentsForPatient` returns a `Stream` from `.snapshots()`, so when a
status changes — from this app, another device, or the hospital's console — the
list updates with no pull-to-refresh. `MyAppointmentsCubit` subscribes to it and
cancels the subscription in `close()`.

`getBookedSlots` filters cancelled appointments **in Dart** rather than adding a
third `where` clause, which keeps the query to a single composite index and
means a cancelled slot automatically becomes bookable again.

### UPDATE — status transitions

```dart
await _appointments.doc(appointmentId).update({
  'status': status.name,
  'updatedAt': Timestamp.fromDate(DateTime.now()),
});
```

The lifecycle:

```
        ┌─────────► cancelled
        │
pending ─────────► confirmed ─────────► completed
                        │
                        └─────────────► cancelled
```

- `pending → confirmed` — the hospital accepts the request
- `confirmed → completed` — the patient has been seen
- `→ cancelled` — from either active state, by either side

Only `pending` and `confirmed` are "active" (`AppointmentStatus.isActive`), and
only *future* active appointments show Cancel and Reschedule buttons
(`AppointmentEntity.canBeModified`). The rule lives on the entity, so the UI and
the repository cannot disagree about it.

`rescheduleAppointment` is a second update: it writes the new `scheduledAt` and
`timeSlot` and resets the status to `pending`, because a moved appointment needs
re-confirming. `RescheduleCubit` excludes the appointment's *own* current slot
from the booked list, so a patient can move it back where it was.

### DELETE — `deleteAppointment`

Implemented on the repository but not wired to a button. Cancelling is preferred
so the hospital keeps its audit trail; see §4 of the ERD document.

---

## 5. Error handling

`FirebaseException` never reaches the UI. Each repository maps the code to a
sentence a patient can act on:

| Firestore code | Message shown |
|----------------|---------------|
| `permission-denied` | "You do not have permission to …" |
| `unavailable` | "No connection to the server. Check your internet and try again." |
| `not-found` | "That appointment no longer exists." |
| `failed-precondition` | "The database is missing an index for this query." |

Cubits strip the `Exception: ` prefix and put the message in
`state.errorMessage`; the pages show it in a `SnackBar`. A failed department
load shows a full-screen retry instead, since the form is unusable without it.

---

## 6. Seeding

A fresh Firebase project has no departments or doctors, which would leave the
booking screen empty. `FirestoreDoctorRepository.getDepartments()` detects an
empty `departments` collection and writes `DirectorySeedData` (6 departments, 9
doctors, real Kigali hospitals) in a single batch, then re-reads. Seed documents
use fixed ids, so a repeat run overwrites rather than duplicates.

Appointments are **never** seeded — every one in the database was created by a
real user action.

---

## 7. Tests

`flutter test` — 23 passing, 16 of them new.

**`booking_cubit_test.dart`** (mocked repositories, no Firebase):

- departments load into `[loading, ready]`; a failure yields a readable message
- selecting a department loads that department's doctors
- selecting a doctor auto-picks the first working day and loads its slots
- changing department clears doctor, date and slot
- a booked slot cannot be selected
- a successful submit returns the stored id, trims the reason, and merges the
  date and slot into one timestamp
- submitting an incomplete form never reaches the repository
- a taken slot surfaces as a failure rather than a crash

**`appointment_model_test.dart`** (no mocks at all):

- every field maps, including `Timestamp` ⇄ `DateTime`
- an unknown or missing status falls back to `pending`
- an empty document does not throw
- `toMap` → `fromMap` round-trips to an identical entity
- status is written as its name, and the document id is never stored inside the
  document
- the `canBeModified` rules for future / past / cancelled / completed

`DocumentSnapshot` is sealed and cannot be mocked, so the mapping logic lives in
`fromMap(id, data)` with `fromFirestore(doc)` as a one-line delegate. That makes
the mapping testable with plain maps and no extra test dependency.

---

## 8. Running it

```bash
flutter pub get
flutter run          # departments seed themselves on first launch
flutter test
flutter analyze
```

Deploy the rules and indexes before the demo:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

---

## 9. Handover notes for the team

- **Naillah** — the Schedule tab renders `MyAppointmentsView`; the queue tracker
  can sit above or below it in `schedule_page.dart`. `queueNumber` is already
  reserved on the appointment document.
- **Duke** — `patientId` is `AuthCubit`'s `user.id` (the Firebase Auth UID); no
  extra mapping is needed.
- **Jabes** — two repositories were added to `MultiRepositoryProvider` in
  `app.dart`; the booking routes were already registered and now point at
  `features/appointments/`.
