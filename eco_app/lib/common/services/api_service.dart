import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:eco_app/common/services/dio_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  late Dio _dio;
  // static const String baseURL = 'https://pbl-5-smart-bin.azurewebsites.net';
  static const String baseURL = 'http://192.168.1.6:8000';

  ApiService() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  Future<Map<String, dynamic>> dioPredictImage(String imageBase64) async {
    try {
      final response = await _dio.post(
        '$baseURL/predict_img',
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

  Future<void> dioRegisterDeviceToken(String deviceToken) async {
    try {
      await _dio.post(
        '$baseURL/register_device',
        data: {'token': deviceToken},
      );
    } catch (e) {
      log(e.toString());
    }
  }
}
