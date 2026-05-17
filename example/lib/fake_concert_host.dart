import 'dart:io';

import 'package:concert_mini_app/concert_mini_app.dart';
import 'package:dio/dio.dart';

/// Stand-in for the Core App's host while developing the Mini App alone.
/// It logs in once as user1 and reuses that token, which is enough for local
/// development against the mock server.
class FakeConcertHost implements ConcertHost {
  FakeConcertHost() {
    _dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _token ??= await _login();
          options.headers['Authorization'] = 'Bearer $_token';
          handler.next(options);
        },
      ),
    );
  }

  late final Dio _dio;
  String? _token;

  @override
  String get apiBaseUrl =>
      Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';

  @override
  Dio get httpClient => _dio;

  @override
  void onExit() => exit(0);

  Future<String> _login() async {
    final res = await Dio().post<Map<String, dynamic>>(
      '$apiBaseUrl/auth/login',
      data: <String, dynamic>{'username': 'user1', 'password': 'password'},
    );
    return res.data!['accessToken'] as String;
  }
}
