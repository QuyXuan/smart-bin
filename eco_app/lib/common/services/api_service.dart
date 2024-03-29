import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eco_app/common/services/dio_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  late Dio _dio;
  static const String baseURL = 'https://smart-bin-suxu.onrender.com';

  ApiService() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  Future<Map<String, dynamic>> dioPredictImage(String imageBase64) async {
    try {
      final response = await _dio.post(
        '$baseURL/predict-img',
        data: {'image': imageBase64},
      );
      if (response.statusCode == 200) {
        return json.decode(response.data);
      } else {
        return {
          'success': false,
          'error': 'Failed to predict image',
        };
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
