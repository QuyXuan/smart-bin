import 'package:dio/dio.dart';
import 'package:eco_app/common/services/store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  late Dio _dio;
  static const String baseURL = '';

  ApiService() {
    _dio = Dio();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: ((options, handler) {
          Store.getToken().then((token) {
            options.headers['Content-Type'] = 'application/json';
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }).then((_) => handler.next(options));
        }),
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            Store.clearToken();
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }
}
