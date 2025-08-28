import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class EnrollmentService {
  final Dio dio;
  EnrollmentService(this.dio);

  /// Obtiene la URL pública de enrollment para pacientes y la abre.
  Future<void> openPatientEnrollment() async {
    final r = await dio.get('/api/v1/public/identity/patient/enrollment-url');
    final url = (r.data is Map && r.data['url'] is String) ? r.data['url'] as String : '';
    if (url.isEmpty) throw Exception('No se recibió URL de enrollment');
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok) { throw Exception('No se pudo abrir el navegador'); }
  }
}
