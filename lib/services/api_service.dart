import 'dart:convert';

// Uncomment when wiring a real backend:
// import 'package:http/http.dart' as http;

/// Parsed response from the cough-prediction backend.
class PredictionResult {
  final String status;
  final String prediction;
  final double confidence;

  const PredictionResult({
    required this.status,
    required this.prediction,
    required this.confidence,
  });

  /// True if the model flagged the sample as TB-positive.
  bool get isPositive => prediction == 'TB_POSITIVE';

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      status: json['status'] as String,
      prediction: json['prediction'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

/// Wraps the prediction backend. Currently returns a mocked response so the
/// UI flow can be exercised end-to-end without a live server.
class ApiService {
  // static const String _endpoint = 'https://your-backend.example.com/predict';

  /// Uploads the recorded cough audio at [filePath] and returns the model's
  /// prediction. The mock implementation waits 2s and returns a hardcoded
  /// TB_POSITIVE result; swap in the real block below to hit your API.
  Future<PredictionResult> uploadCoughAudio(String filePath) async {
    // --- MOCK IMPLEMENTATION ---------------------------------------------
    await Future.delayed(const Duration(seconds: 2));
    const mockBody =
        '{"status":"success","prediction":"TB_POSITIVE","confidence":0.89}';
    final json = jsonDecode(mockBody) as Map<String, dynamic>;
    return PredictionResult.fromJson(json);

    // --- REAL IMPLEMENTATION (uncomment + replace mock above) ------------
    // final request = http.MultipartRequest('POST', Uri.parse(_endpoint))
    //   ..files.add(await http.MultipartFile.fromPath('audio', filePath));
    // final streamed = await request.send();
    // final response = await http.Response.fromStream(streamed);
    // if (response.statusCode != 200) {
    //   throw Exception('Prediction request failed: HTTP ${response.statusCode}');
    // }
    // final json = jsonDecode(response.body) as Map<String, dynamic>;
    // return PredictionResult.fromJson(json);
  }
}
