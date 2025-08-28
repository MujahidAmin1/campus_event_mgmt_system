import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/models/user.dart';
import 'package:campus_event_mgmt_system/core/services/api_service.dart';
import 'package:campus_event_mgmt_system/core/services/jwt_service.dart';
import 'package:campus_event_mgmt_system/core/providers.dart';

class AuthController extends StateNotifier<AsyncValue<AuthResponse?>> {
  final ApiService _apiService;
  final JwtService _jwtService;
  final Ref _ref;

  AuthController(this._apiService, this._jwtService, this._ref) : super(const AsyncValue.data(null));

  // Initialize auth state from stored token
  Future<void> initializeAuth() async {
    try {
      print('Initializing auth...');
      final token = await _jwtService.getToken();
      print('Token retrieved: ${token != null ? 'exists' : 'null'}');
      
      if (token != null && !_jwtService.isTokenExpired(token)) {
        print('Token is valid, retrieving user data...');
        final userData = await _jwtService.getUser();
        if (userData != null) {
          print('User data found, setting up authentication...');
          final user = User.fromJson(userData);
          _ref.read(authTokenProvider.notifier).state = token;
          _ref.read(apiServiceProvider).setAuthToken(token);
          _ref.read(isAuthenticatedProvider.notifier).state = true;
          _ref.read(currentUserProvider.notifier).state = user;
          final role = user.role.toLowerCase() == 'admin' ? UserRole.admin : UserRole.student;
          _ref.read(userRoleProvider.notifier).state = role;
          print('Authentication initialized successfully');
        } else {
          print('No user data found, clearing token');
          await _jwtService.clearAll();
        }
      } else {
        print('Token is null or expired, clearing stored data');
        await _jwtService.clearAll();
      }
    } catch (error, stackTrace) {
      print('Error during auth initialization: $error');
      print('Stack trace: $stackTrace');
      // Clear any corrupted data
      await _jwtService.clearAll();
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      print('Attempting login for user: $username');
      final request = LoginRequest(username: username, password: password);
      final response = await _apiService.login(request);
      
      print('Login successful, storing user data...');
      // Store token and user data securely
      await _jwtService.storeToken(response.token);
      await _jwtService.storeUser(response.user.toJson());
      
      // Set authentication state
      _ref.read(authTokenProvider.notifier).state = response.token;
      _ref.read(apiServiceProvider).setAuthToken(response.token);
      _ref.read(isAuthenticatedProvider.notifier).state = true;
      
      _ref.read(currentUserProvider.notifier).state = response.user;
      final role = response.user.role.toLowerCase() == 'admin' ? UserRole.admin : UserRole.student;
      _ref.read(userRoleProvider.notifier).state = role;
      
      print('Login completed successfully');
      state = AsyncValue.data(response);
    } catch (error, stack) {
      print('Login error: $error');
      print('Login error stack: $stack');
      
      // Handle specific error types
      if (error.toString().contains('aborted') || error.toString().contains('canceled')) {
        state = AsyncValue.error('Request was cancelled. Please try again.', stack);
      } else if (error.toString().contains('timeout')) {
        state = AsyncValue.error('Request timed out. Please check your internet connection.', stack);
      } else if (error.toString().contains('connection')) {
        state = AsyncValue.error('No internet connection. Please check your network.', stack);
      } else {
        state = AsyncValue.error(error, stack);
      }
    }
  }

  Future<void> register(String username, String email, String password, String? role) async {
    state = const AsyncValue.loading();
    try {
      print('Attempting registration for user: $username');
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
        role: role,
      );
      final response = await _apiService.register(request);
      
      print('Registration successful, storing user data...');
      // Store token and user data securely
      await _jwtService.storeToken(response.token);
      await _jwtService.storeUser(response.user.toJson());
      
      // Set authentication state
      _ref.read(authTokenProvider.notifier).state = response.token;
      _ref.read(apiServiceProvider).setAuthToken(response.token);
      _ref.read(isAuthenticatedProvider.notifier).state = true;
      
      _ref.read(currentUserProvider.notifier).state = response.user;
      final userRole = response.user.role.toLowerCase() == 'admin' ? UserRole.admin : UserRole.student;
      _ref.read(userRoleProvider.notifier).state = userRole;
      
      print('Registration completed successfully');
      state = AsyncValue.data(response);
    } catch (error, stack) {
      print('Registration error: $error');
      print('Registration error stack: $stack');
      
      // Handle specific error types
      if (error.toString().contains('aborted') || error.toString().contains('canceled')) {
        state = AsyncValue.error('Request was cancelled. Please try again.', stack);
      } else if (error.toString().contains('timeout')) {
        state = AsyncValue.error('Request timed out. Please check your internet connection.', stack);
      } else if (error.toString().contains('connection')) {
        state = AsyncValue.error('No internet connection. Please check your network.', stack);
      } else {
        state = AsyncValue.error(error, stack);
      }
    }
  }

  Future<void> logout() async {
    // Clear stored data
    await _jwtService.clearAll();
    
    // Clear state
    _ref.read(authTokenProvider.notifier).state = null;
    _ref.read(currentUserProvider.notifier).state = null;
    _ref.read(isAuthenticatedProvider.notifier).state = false;
    _ref.read(apiServiceProvider).clearAuthToken();
    _ref.read(userRoleProvider.notifier).state = UserRole.student;
    state = const AsyncValue.data(null);
  }

  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }
}

var authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<AuthResponse?>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final jwtService = ref.read(jwtServiceProvider);
  return AuthController(apiService, jwtService, ref);
});
