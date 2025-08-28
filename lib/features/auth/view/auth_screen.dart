import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/core/providers.dart';
import 'package:campus_event_mgmt_system/core/utils/kTextStyle.dart';
import 'package:campus_event_mgmt_system/features/events/view/events_screen.dart';
import 'package:campus_event_mgmt_system/features/events/view/admin_events_screen.dart';
import 'package:campus_event_mgmt_system/features/auth/controller/auth_controller.dart';
import 'package:campus_event_mgmt_system/models/user.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider); // AsyncValue<User?>
    final userRole = ref.watch(userRoleProvider);

    // Listen for auth changes inside build
    ref.listen<AsyncValue<User?>>(authControllerProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          _navigateAfterAuth(ref.read(userRoleProvider));
          _showSuccessSnackBar(_isLogin ? 'Login successful!' : 'Registration successful!');
        }
      });

      next.whenOrNull(
        error: (error, stack) {
          _showErrorSnackBar(_getErrorMessage(error));
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildAuthForm(),
                const SizedBox(height: 24),
                if (!_isLogin) _buildRoleSelection(),
                if (!_isLogin) const SizedBox(height: 32),
                _buildSubmitButton(authState), // pass User? state
                const SizedBox(height: 16),
                _buildToggleButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateAfterAuth(UserRole role) {
    if (role == UserRole.admin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminEventsScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EventsScreen()),
      );
    }
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.event, size: 40, color: Colors.blue[700]),
        ),
        const SizedBox(height: 16),
        Text('Campus Events', style: kTextStyle(size: 28, isBold: true)),
        const SizedBox(height: 8),
        Text(
          _isLogin ? 'Welcome back!' : 'Create your account',
          style: kTextStyle(size: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    return Column(
      children: [
        if (!_isLogin)
          _buildTextField(
            controller: _usernameController,
            label: 'Username',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your username';
              return null;
            },
          ),
        if (!_isLogin) const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your email';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock,
          isPassword: true,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your password';
            if (!_isLogin && value.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Role', style: kTextStyle(size: 16, isBold: true)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildRoleChip(UserRole.student)),
            const SizedBox(width: 12),
            Expanded(child: _buildRoleChip(UserRole.admin)),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleChip(UserRole role) {
    final isSelected = _selectedRole == role;
    final isStudent = role == UserRole.student;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? (isStudent ? Colors.green : Colors.grey[400]) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? (isStudent ? Colors.green : Colors.grey[400]!) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            isStudent ? 'Student' : 'Admin',
            style: kTextStyle(
              size: 16,
              isBold: isSelected,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AsyncValue<User?> authState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: authState.isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: authState.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : Text(_isLogin ? 'Login' : 'Register', style: kTextStyle(size: 16, isBold: true, color: Colors.white)),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? 'Don\'t have an account? ' : 'Already have an account? ',
          style: kTextStyle(size: 14, color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () => setState(() {
            _isLogin = !_isLogin;
            // Clear form when switching modes
            _formKey.currentState?.reset();
            _usernameController.clear();
            _emailController.clear();
            _passwordController.clear();
          }),
          child: Text(_isLogin ? 'Register' : 'Login', style: kTextStyle(size: 14, isBold: true, color: Colors.blue[700])),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final authController = ref.read(authControllerProvider.notifier);
      if (_isLogin) {
        authController.login(_emailController.text.trim(), _passwordController.text);
      } else {
        authController.register(
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _selectedRole == UserRole.admin ? 'admin' : 'student',
        );
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return error.message ?? 'An authentication error occurred.';
      }
    }
    return error.toString();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green, duration: const Duration(seconds: 2)));
    }
  }
}