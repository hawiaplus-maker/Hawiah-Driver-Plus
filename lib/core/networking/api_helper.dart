import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/routes/app_routers_import.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/login-screen.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../extension/context_extension.dart';

enum ResponseState {
  sleep,
  offline,
  loading,
  pagination,
  complete,
  error,
  unauthorized,
  badRequest
}

class ApiResponse {
  ResponseState state;
  dynamic data;
  ApiResponse({required this.state, required this.data});
}

class ApiHelper {
  static ApiHelper? _instance;
  ApiHelper._();
  static ApiHelper get instance => _instance ??= ApiHelper._();

  MediaType appMediaType(String filePath) {
    var list = "${lookupMimeType(filePath)}".split('/');
    return MediaType(list.firstOrNull ?? 'application', list.lastOrNull ?? 'octet-stream');
  }

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 12),
      sendTimeout: Duration(seconds: 12),
    ),
  )..interceptors.addAll(
      kDebugMode
          ? [
              PrettyDioLogger(
                  request: true,
                  requestHeader: true,
                  requestBody: true,
                  responseBody: true,
                  responseHeader: false,
                  compact: false)
            ]
          : [],
    );

  Options _options(Map<String, String>? headers, bool hasToken) => Options(
        contentType: 'application/json',
        followRedirects: true,
        validateStatus: (_) => true,
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Accept-Language': HiveMethods.getLang(),
          if (HiveMethods.getToken() != null && hasToken)
            'Authorization': "Bearer ${HiveMethods.getToken()}",
          ...?headers,
        },
      );

  Map<String, String> _offlineMessage() => {
        'message': AppRouters.navigatorKey.currentContext!.apiTr(
          ar: "تأكد من الاتصال بالإنترنت",
          en: "Make sure you are connected to the internet",
        ),
      };

  Map<String, String> _errorMessage() => {
        'message': AppRouters.navigatorKey.currentContext!.apiTr(
          ar: "حدث خطأ",
          en: "An error occurred",
        ),
      };

  Future<ApiResponse> _run(Future<Response> Function() request, {void Function()? onFinish}) async {
    try {
      final response = await request();
      Future.delayed(Duration.zero, onFinish);
      return _buildResponse(response);
    } on SocketException {
      Future.delayed(Duration.zero, onFinish);
      return ApiResponse(state: ResponseState.offline, data: _offlineMessage());
    } on DioException catch (e) {
      Future.delayed(Duration.zero, onFinish);

      // === هنا التعديل ===
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        return ApiResponse(
          state: ResponseState.offline,
          data: _offlineMessage(),
        );
      }

      return ApiResponse(
        state: ResponseState.error,
        data: _errorMessage(),
      );
    } catch (_) {
      Future.delayed(Duration.zero, onFinish);
      return ApiResponse(state: ResponseState.error, data: _errorMessage());
    }
  }

  // HTTP METHODS
  Future<ApiResponse> get(String url,
          {Map<String, dynamic>? queryParameters,
          Map<String, String>? headers,
          void Function()? onFinish,
          void Function(int, int)? onReceiveProgress,
          bool hasToken = true}) async =>
      _run(
          () => _dio.get(url,
              queryParameters: queryParameters,
              options: _options(headers, hasToken),
              onReceiveProgress: onReceiveProgress),
          onFinish: onFinish);

  Future<ApiResponse> post(String url,
          {Map<String, dynamic>? queryParameters,
          dynamic body,
          Map<String, String>? headers,
          void Function()? onFinish,
          void Function(int, int)? onReceiveProgress,
          void Function(int, int)? onSendProgress,
          bool hasToken = true,
          bool isMultipart = false}) async =>
      _run(
          () => _dio.post(url,
              queryParameters: queryParameters,
              data: isMultipart ? FormData.fromMap(body) : body,
              options: _options(headers, hasToken),
              onReceiveProgress: onReceiveProgress,
              onSendProgress: onSendProgress),
          onFinish: onFinish);

  Future<ApiResponse> put(String url,
          {Map<String, dynamic>? queryParameters,
          dynamic body,
          Map<String, String>? headers,
          void Function()? onFinish,
          void Function(int, int)? onReceiveProgress,
          void Function(int, int)? onSendProgress,
          bool hasToken = true}) async =>
      _run(
          () => _dio.put(url,
              queryParameters: queryParameters,
              data: body,
              options: _options(headers, hasToken),
              onReceiveProgress: onReceiveProgress,
              onSendProgress: onSendProgress),
          onFinish: onFinish);

  Future<ApiResponse> patch(String url,
          {Map<String, dynamic>? queryParameters,
          dynamic body,
          Map<String, String>? headers,
          void Function()? onFinish,
          void Function(int, int)? onReceiveProgress,
          void Function(int, int)? onSendProgress,
          bool hasToken = true}) async =>
      _run(
          () => _dio.patch(url,
              queryParameters: queryParameters,
              data: body,
              options: _options(headers, hasToken),
              onReceiveProgress: onReceiveProgress,
              onSendProgress: onSendProgress),
          onFinish: onFinish);

  Future<ApiResponse> delete(String url,
          {Map<String, dynamic>? queryParameters,
          dynamic body,
          Map<String, String>? headers,
          void Function()? onFinish,
          bool hasToken = true}) async =>
      _run(
          () => _dio.delete(url,
              queryParameters: queryParameters, data: body, options: _options(headers, hasToken)),
          onFinish: onFinish);

  Future<ApiResponse> download(String url,
      {Map<String, dynamic>? queryParameters,
      Map<String, String>? headers,
      void Function()? onFinish,
      void Function(int, int)? onReceiveProgress,
      bool hasToken = true}) async {
    final fileName = path.basename(url);
    final savePath = await _getFilePath(fileName);
    return _run(
        () => _dio.download(url, savePath,
            queryParameters: queryParameters,
            options: _options(headers, hasToken),
            onReceiveProgress: onReceiveProgress),
        onFinish: onFinish);
  }

  ApiResponse _buildResponse(Response response) {
    final data = response.data;
    switch (response.statusCode) {
      case 200:
      case 201:
        return ApiResponse(state: ResponseState.complete, data: data);
      case 401:
        Future.delayed(Duration.zero, () {
          HiveMethods.deleteToken();
          if (!HiveMethods.isVisitor()) {
            NavigatorMethods.pushNamedAndRemoveUntil(
                AppRouters.navigatorKey.currentContext!, LoginScreen.routeName);
          }
        });
        return ApiResponse(state: ResponseState.unauthorized, data: data);
      case 400:
      case 422:
      case 403:
        return ApiResponse(state: ResponseState.error, data: data);
      case 404:
        return ApiResponse(state: ResponseState.badRequest, data: data);
      default:
        return ApiResponse(state: ResponseState.error, data: data);
    }
  }

  Future<String> _getFilePath(String fileName) async {
    Directory dir = await path_provider.getApplicationDocumentsDirectory();
    return '${dir.path}/$fileName.pdf';
  }
}
