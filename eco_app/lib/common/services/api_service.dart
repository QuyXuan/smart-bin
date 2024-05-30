import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:eco_app/common/constants.dart';
import 'package:eco_app/common/services/dio_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  late Dio _dio;
  static const String baseURL = 'https://pbl-5-smart-bin.azurewebsites.net';

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

  Future<void> dioSetFlash(bool flashState) async {
    try {
      await _dio.get(
        '${Constants.localUrl}/control?var=led_intensity&val=${flashState ? 100 : 0}',
      );
    } catch (e) {
      log(e.toString());
    }
  }
}
