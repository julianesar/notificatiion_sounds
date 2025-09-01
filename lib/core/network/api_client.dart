import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: '${AppConstants.baseUrl}/${AppConstants.apiVersion}',
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Key': AppConstants.apiKey,
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add authentication token if available
          // options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          final customError = _handleError(error);
          handler.reject(customError);
        },
      ),
    );
    
    // Add logging interceptor in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }
  
  DioError _handleError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectionTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return DioError(
          requestOptions: error.requestOptions,
          error: const NetworkException('Connection timeout'),
          type: error.type,
        );
      case DioErrorType.badResponse:
        return _handleServerError(error);
      case DioErrorType.cancel:
        return DioError(
          requestOptions: error.requestOptions,
          error: const NetworkException('Request cancelled'),
          type: error.type,
        );
      case DioErrorType.unknown:
        return DioError(
          requestOptions: error.requestOptions,
          error: const NetworkException('Network error occurred'),
          type: error.type,
        );
      default:
        return error;
    }
  }
  
  DioError _handleServerError(DioError error) {
    final statusCode = error.response?.statusCode;
    final message = error.response?.data?['message'] ?? 'Server error';
    
    switch (statusCode) {
      case 400:
        return DioError(
          requestOptions: error.requestOptions,
          error: ServerException('Bad request: $message'),
          type: error.type,
          response: error.response,
        );
      case 401:
        return DioError(
          requestOptions: error.requestOptions,
          error: const ServerException('Unauthorized'),
          type: error.type,
          response: error.response,
        );
      case 403:
        return DioError(
          requestOptions: error.requestOptions,
          error: const ServerException('Forbidden'),
          type: error.type,
          response: error.response,
        );
      case 404:
        return DioError(
          requestOptions: error.requestOptions,
          error: const ServerException('Not found'),
          type: error.type,
          response: error.response,
        );
      case 500:
        return DioError(
          requestOptions: error.requestOptions,
          error: const ServerException('Internal server error'),
          type: error.type,
          response: error.response,
        );
      default:
        return DioError(
          requestOptions: error.requestOptions,
          error: ServerException('Server error: $message'),
          type: error.type,
          response: error.response,
        );
    }
  }
  
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> download<T>(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return await _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }
}