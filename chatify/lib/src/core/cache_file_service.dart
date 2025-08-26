import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// ignore: implementation_imports
import 'package:flutter_cache_manager/src/web/mime_converter.dart';
import 'package:http/http.dart' as http;

class CustomFileService extends HttpFileService {
  final _httpClient = http.Client();

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final req = http.Request('GET', Uri.parse(url));
    if (headers != null) {
      req.headers.addAll(headers);
    }
    final httpResponse = await _httpClient.send(req);

    return _CustomHttpGetResponse(httpResponse);
  }
}

class _CustomHttpGetResponse extends HttpGetResponse {
  _CustomHttpGetResponse(this._response) : super(_response);

  final http.StreamedResponse _response;

  @override
  String get fileExtension {
    if (_response.request?.url
            .toString()
            .contains('firebasestorage.googleapis.com') ??
        false) {
      final path = _response.request!.url.path;
      final extension = path.split('.').last;
      if (extension.length > 1 && mimeTypes.values.contains('.$extension')) {
        return '.$extension';
      }
    }

    return super.fileExtension;
  }
}
