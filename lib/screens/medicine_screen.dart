import 'package:flutter/material.dart';

import '../widgets/placeholder_screen.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Medicine',
      icon: Icons.medical_services_rounded,
      message: 'Your TB medication tracker will live here.',
    );
  }
}
