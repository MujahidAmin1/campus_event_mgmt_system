import 'package:dio/dio.dart';
import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:campus_event_mgmt_system/models/user.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Dio? _dio;
  String? _authToken;
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) {
      print('ApiService already initialized, skipping...');
      return;
    }
    
    print('Initializing ApiService...');
    _dio = Dio(BaseOptions(
      baseUrl: 'https://event-management-gcpg.onrender.com/api',
      connectTimeout: const Duration(seconds: 60), // Increased timeout
      receiveTimeout: const Duration(seconds: 60), // Increased timeout
      sendTimeout: const Duration(seconds: 60), // Added send timeout
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        return status != null && status < 500; // Accept all status codes less than 500
      },
    ));

    // Add interceptors for logging and auth token
    _dio!.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('DIO: $obj'),
      error: true,
    ));

    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('Making request to: ${options.uri}');
        print('Request method: ${options.method}');
        print('Request headers: ${options.headers}');
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response received: ${response.statusCode}');
        print('Response data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('API Error Type: ${error.type}');
        print('API Error Message: ${error.message}');
        print('API Error Response: ${error.response?.data}');
        print('API Error Status: ${error.response?.statusCode}');
        handler.next(error);
      },
    ));
    
    _isInitialized = true;
    print('ApiService initialized successfully');
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // Authentication endpoints
  Future<AuthResponse> login(LoginRequest request) async {
    if (_dio == null) {
      throw Exception('ApiService not initialized. Call initialize() first.');
    }
    try {
      final response = await _dio!.post('/login/', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    if (_dio == null) {
      throw Exception('ApiService not initialized. Call initialize() first.');
    }
    try {
      final response = await _dio!.post('/register/', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Events endpoints
  Future<List<Event>> getEvents() async {
    if (_dio == null) {
      throw Exception('ApiService not initialized. Call initialize() first.');
    }
    try {
      final response = await _dio!.get('/events/');
      final List<dynamic> eventsJson = response.data;
      return eventsJson.map((json) => Event.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Event> createEvent(Map<String, dynamic> eventData) async {
    if (_dio == null) {
      throw Exception('ApiService not initialized. Call initialize() first.');
    }
    try {
      final response = await _dio!.post('/events/', data: eventData);
      return Event.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Event> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    if (_dio == null) {
      throw Exception('ApiService not initialized. Call initialize() first.');
    }
    try {
      final response = await _dio!.put('/events/$eventId/', data: eventData);
      return Event.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    if (_dio == null) {
      throw Exception('ApiService not initialized. Call initialize() first.');
    }
    try {
      await _dio!.delete('/events/$eventId/');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Error handling
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? error.response?.data?['detail'] ?? 'Unknown error';
        
        switch (statusCode) {
          case 400:
            return 'Bad request: $message';
          case 401:
            return 'Unauthorized: Please login again.';
          case 403:
            return 'Forbidden: You don\'t have permission to perform this action.';
          case 404:
            return 'Not found: The requested resource was not found.';
          case 500:
            return 'Server error: Please try again later.';
          default:
            return 'Error $statusCode: $message';
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
