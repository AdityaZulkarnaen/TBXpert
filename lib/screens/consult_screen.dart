import 'package:flutter/material.dart';

import '../widgets/placeholder_screen.dart';

class ConsultScreen extends StatelessWidget {
  const ConsultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Consult',
      icon: Icons.chat_bubble_rounded,
      message: 'Chat with a doctor — coming in a future release.',
    );
  }
}
