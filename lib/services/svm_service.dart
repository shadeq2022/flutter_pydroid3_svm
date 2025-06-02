import 'package:http/http.dart' as http;
import 'dart:convert';

class SVMService {
  final String baseUrl;

  SVMService({this.baseUrl = 'http://172.16.1.15:8080'}); // Sesuaikan dengan IP Pydroid Anda

  Future<String> classifyData(double bpm, double angle) async {
    try {
      final url = '$baseUrl/predict';
      print('🔄 Memulai klasifikasi SVM');
      print('📡 URL: $url');
      print('📤 Data: BPM=$bpm, Angle=$angle');      
      
      // Konversi BPM ke integer dan angle ke float dengan 2 decimal places
      final bpmValue = bpm.round();
      final angleValue = double.parse(angle.toStringAsFixed(2));
      
      print('📤 Data setelah konversi: BPM=$bpmValue, Angle=$angleValue');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'BPM': bpmValue,
          'Kemiringan': angleValue
        }),
      );

      print('📥 Status Response: ${response.statusCode}');
      print('📥 Headers: ${response.headers}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final label = result['label'];
        final code = result['code'];
        print('✅ Hasil Klasifikasi: $label (Kode: $code)');
        if (label == null) {
          return 'Error: Hasil klasifikasi kosong';
        }
        return label.toString();
      } else {
        final errorBody = response.body;
        print('❌ Error HTTP: ${response.statusCode}');
        print('❌ Error Body: $errorBody');
        try {
          final errorJson = jsonDecode(errorBody);
          return 'Error: ${errorJson['error'] ?? 'Unknown error'}';
        } catch (_) {
          return 'Error: HTTP ${response.statusCode}';
        }
      }
    } catch (e, stackTrace) {
      print('❌ Exception: $e');
      print('📋 Stack trace: $stackTrace');
      return 'Error: $e';
    }
  }
}
