import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloaderService {
  final Dio dio = Dio();

  bool looksLikeUrl(String s) {
    final uri = Uri.tryParse(s);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https')) && uri.host.isNotEmpty;
  }

  bool isDirectMp4(String s) {
    return s.toLowerCase().endsWith('.mp4');
  }

  Future<String> downloadFile({
    required String url,
    required void Function(int received, int total) onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final path = '${dir.path}/$filename';

    await dio.download(
      url,
      path,
      onReceiveProgress: onProgress,
      options: Options(
        followRedirects: true,
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
        responseType: ResponseType.bytes,
      ),
    );

    return path;
  }
}
