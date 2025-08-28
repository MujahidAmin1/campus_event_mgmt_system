import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/core/providers.dart';
import 'package:campus_event_mgmt_system/features/auth/view/auth_screen.dart';
import 'package:campus_event_mgmt_system/features/events/view/events_screen.dart';
import 'package:campus_event_mgmt_system/features/events/view/admin_events_screen.dart';
import 'package:campus_event_mgmt_system/core/services/notification_service.dart';
import 'package:campus_event_mgmt_system/core/services/api_service.dart';
import 'package:campus_event_mgmt_system/features/auth/controller/auth_controller.dart';
import 'package:campus_event_mgmt_system/core/widgets/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services with error handling
  try {
    print('Initializing notification service...');
    await NotificationService().initialize();
    print('Notification service initialized successfully');
  } catch (error) {
    print('Error initializing notification service: $error');
  }
  
  try {
    print('Initializing API service...');
    ApiService().initialize();
    print('API service initialized successfully');
  } catch (error) {
    print('Error initializing API service: $error');
  }
  
  print('Starting app...');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
    
    // Fallback: if initialization takes too long, proceed anyway
    Future.delayed(const Duration(seconds: 15), () {
      if (!_isInitialized) {
        print('Forcing initialization after timeout');
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  Future<void> _initializeAuth() async {
    try {
      print('Starting auth initialization...');
      final authController = ref.read(authControllerProvider.notifier);
      
      // Add timeout to prevent hanging
      await authController.initializeAuth().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Auth initialization timed out, proceeding without auth');
          return;
        },
      );
      
      print('Auth initialization completed');
      setState(() {
        _isInitialized = true;
      });
    } catch (error, stackTrace) {
      print('Error in _initializeAuth: $error');
      print('Stack trace: $stackTrace');
      // Set initialized to true even if there's an error to prevent infinite loading
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: const LoadingScreen(
          message: 'Initializing Campus Event Management System...',
          subtitle: 'Please wait while we set up your experience',
        ),
      );
    }

    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final userRole = ref.watch(userRoleProvider);

    return MaterialApp(
      title: 'Campus Event Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: isAuthenticated
          ? (userRole == UserRole.admin ? const AdminEventsScreen() : const EventsScreen())
          : const AuthScreen(),
    );
  }
}

