import 'package:flutter/material.dart';
import 'package:kivu_haqms/core/widgets/placeholder_page.dart';

/// Placeholder schedule tab — Naillah will implement appointments + queue tracker.
class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Schedule',
      subtitle: 'Appointments & queue — Naillah',
    );
  }
}
