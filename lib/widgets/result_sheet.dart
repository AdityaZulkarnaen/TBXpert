import 'package:flutter/material.dart';

import '../services/api_service.dart';

/// Bottom sheet that renders a prediction result + the mandatory disclaimer.
class ResultSheet extends StatelessWidget {
  final PredictionResult result;
  final VoidCallback onTryAgain;

  const ResultSheet({
    super.key,
    required this.result,
    required this.onTryAgain,
  });

  static const String _disclaimer =
      'Disclaimer: This app is for screening purposes only and does not '
      'replace a professional medical diagnosis. Please consult a doctor '
      'for accurate medical advice.';

  @override
  Widget build(BuildContext context) {
    final bool positive = result.isPositive;
    final Color color =
        positive ? Colors.red.shade700 : Colors.green.shade700;
    final IconData icon =
        positive ? Icons.warning_amber_rounded : Icons.check_circle;
    final String heading =
        positive ? 'High Risk of TB' : 'Normal / Low Risk';
    final String confidencePct =
        (result.confidence * 100).toStringAsFixed(0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: color),
            const SizedBox(height: 16),
            Text(
              heading,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Model confidence: $confidencePct%',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onTryAgain,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Try Again'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _disclaimer,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
