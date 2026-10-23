import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../constants.dart';

class HnAuthException implements Exception {
  HnAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthResult {
  const AuthResult.success(this.username) : success = true, error = null;
  const AuthResult.failure(this.error) : success = false, username = null;

  final bool success;
  final String? username;
  final String? error;
}

/// Talks to the HTML endpoints that still power Hacker News account actions.
class HnAuthService {
  HnAuthService({Dio? dio}) {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: AppConstants.hnWebUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
                  '(KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36',
            },
            followRedirects: true,
            maxRedirects: 5,
          ),
        );
    _dio.interceptors.add(CookieManager(CookieJar()));
  }

  late final Dio _dio;

  Future<AuthResult> login({
    required String username,
    required String password,
    bool createAccount = false,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{
        'acct': username,
        'pw': password,
        if (createAccount) 'creating': 't',
        if (createAccount && email != null && email.isNotEmpty) 'email': email,
        'goto': 'news',
      };
      final response = await _dio.post<String>(
        '/login',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );
      final body = response.data ?? '';
      final authenticated =
          body.contains('user?id=$username') || body.contains('logout');
      if (!authenticated) {
        return const AuthResult.failure('Invalid username or password');
      }
      return AuthResult.success(username);
    } on DioException catch (error) {
      return AuthResult.failure(error.message ?? 'Network error');
    }
  }

  Future<bool> vote({
    required String username,
    required String password,
    required int itemId,
  }) async {
    return _postAction('/vote', {
      'acct': username,
      'pw': password,
      'id': '$itemId',
      'how': 'up',
      'goto': 'item?id=$itemId',
    });
  }

  Future<bool> comment({
    required String username,
    required String password,
    required int parentId,
    required String text,
  }) async {
    return _postAction('/comment', {
      'acct': username,
      'pw': password,
      'parent': '$parentId',
      'text': text,
      'goto': 'item?id=$parentId',
    });
  }

  Future<bool> submit({
    required String username,
    required String password,
    required String title,
    String? url,
    String? text,
  }) async {
    try {
      // Fetch the submit page to obtain the short-lived fnid token.
      final page = await _dio.post<String>(
        '/submit',
        data: {'acct': username, 'pw': password, 'goto': 'news'},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );
      final body = page.data ?? '';
      final match = RegExp(r'''name=["']fnid["']\s+value=["']([^"']+)''')
          .firstMatch(body);
      final fnid = match?.group(1);
      if (fnid == null) return false;

      final response = await _dio.post<String>(
        '/r',
        data: {
          'fnid': fnid,
          'fnop': 'submit-page',
          'title': title,
          if (url != null && url.isNotEmpty) 'url': url,
          if (text != null && text.isNotEmpty) 'text': text,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );
      final result = response.data ?? '';
      return !result.contains('fnid') && !result.contains('unknown');
    } on DioException {
      return false;
    }
  }

  Future<bool> _postAction(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post<String>(
        path,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );
      final body = response.data ?? '';
      return response.statusCode == 200 &&
          !body.contains('Unknown user') &&
          !body.contains('bad login') &&
          !body.contains('Bad login');
    } on DioException {
      return false;
    }
  }
}
