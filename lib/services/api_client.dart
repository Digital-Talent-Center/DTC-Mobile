import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'session.dart';

/// Error terstruktur dari API. `message` aman ditampilkan ke user,
/// `errors` berisi error validasi per-field (jika ada).
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, List<String>> errors;

  ApiException(this.statusCode, this.message, [this.errors = const {}]);

  /// Pesan validasi pertama (berguna untuk SnackBar).
  String get firstError {
    if (errors.isNotEmpty) {
      final first = errors.values.first;
      if (first.isNotEmpty) return first.first;
    }
    return message;
  }

  @override
  String toString() => message;
}

/// Wrapper HTTP tipis di atas package `http`.
/// - Menyisipkan header `Authorization: Bearer <token>` otomatis.
/// - Mem-parse format respons standar Laravel `{ data, message, pagination }`.
/// - Melempar [ApiException] untuk status non-2xx.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  Map<String, String> _headers({bool json = true}) {
    final h = <String, String>{'Accept': 'application/json'};
    if (json) h['Content-Type'] = 'application/json';
    final token = Session.instance.token;
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(ApiConfig.apiUrl(path));
    if (query == null || query.isEmpty) return base;
    final qp = <String, String>{};
    query.forEach((k, v) {
      if (v != null && '$v'.isNotEmpty) qp[k] = '$v';
    });
    return base.replace(queryParameters: {...base.queryParameters, ...qp});
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers());
    return _decode(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await http.post(_uri(path),
        headers: _headers(), body: body == null ? null : jsonEncode(body));
    return _decode(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await http.put(_uri(path),
        headers: _headers(), body: body == null ? null : jsonEncode(body));
    return _decode(res);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final res = await http.patch(_uri(path),
        headers: _headers(), body: body == null ? null : jsonEncode(body));
    return _decode(res);
  }

  Future<dynamic> delete(String path, {Object? body}) async {
    final res = await http.delete(_uri(path),
        headers: _headers(), body: body == null ? null : jsonEncode(body));
    return _decode(res);
  }

  /// Upload multipart (file). [fields] = field teks biasa,
  /// [fileField]/[filePath] = berkas yang diunggah.
  Future<dynamic> multipart(
    String path, {
    required String method,
    Map<String, String> fields = const {},
    String? fileField,
    String? filePath,
  }) async {
    final req = http.MultipartRequest(method, _uri(path));
    req.headers.addAll(_headers(json: false));
    req.fields.addAll(fields);
    if (fileField != null && filePath != null && filePath.isNotEmpty) {
      req.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    dynamic json;
    if (res.body.isNotEmpty) {
      try {
        json = jsonDecode(res.body);
      } catch (_) {
        json = null;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json;
    }

    // Bentuk error standar Laravel: { message, errors: { field: [..] } }
    String message = 'Terjadi kesalahan (${res.statusCode}).';
    final errors = <String, List<String>>{};
    if (json is Map) {
      if (json['message'] is String) message = json['message'] as String;
      if (json['errors'] is Map) {
        (json['errors'] as Map).forEach((k, v) {
          if (v is List) errors['$k'] = v.map((e) => '$e').toList();
        });
      }
    }
    if (res.statusCode == 401) {
      message = json is Map && json['message'] is String
          ? json['message'] as String
          : 'Sesi berakhir. Silakan login kembali.';
    }
    throw ApiException(res.statusCode, message, errors);
  }
}
