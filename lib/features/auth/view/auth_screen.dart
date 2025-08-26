import 'package:campus_event_mgmt_system/core/providers.dart';
import 'package:campus_event_mgmt_system/core/utils/kTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../events/view/events_screen.dart';
import '../../events/view/admin_events_screen.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isSignUp = ref.watch(accountStateProvider);
    var selectedRole = ref.watch(userRoleProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildAuthForm(context, ref, isSignUp, selectedRole),
              const SizedBox(height: 24),
              _buildSocialLoginSection(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.event,
            size: 48,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Campus Events',
          style: kTextStyle(size: 28, isBold: true),
        ),
        const SizedBox(height: 8),
        Text(
          'Discover and manage campus events',
          style: kTextStyle(size: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAuthForm(BuildContext context, WidgetRef ref, bool isSignUp, UserRole selectedRole) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormHeader(isSignUp),
          const SizedBox(height: 32),
          _buildRoleSelection(ref, selectedRole),
          const SizedBox(height: 24),
          _buildFormFields(isSignUp),
          const SizedBox(height: 24),
          _buildSubmitButton(context, ref, isSignUp, selectedRole),
          const SizedBox(height: 16),
          _buildToggleButton(ref, isSignUp),
        ],
      ),
    );
  }

  Widget _buildFormHeader(bool isSignUp) {
    return Column(
      children: [
        Text(
          isSignUp ? 'Create Account' : 'Welcome Back',
          style: kTextStyle(size: 24, isBold: true),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isSignUp 
              ? 'Join the campus community today'
              : 'Sign in to your account',
          style: kTextStyle(size: 14, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleSelection(WidgetRef ref, UserRole selectedRole) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Role',
          style: kTextStyle(size: 16, isBold: true),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRoleChip(
                ref,
                UserRole.student,
                selectedRole,
                'Student',
                Icons.school,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleChip(
                ref,
                UserRole.admin,
                selectedRole,
                'Admin',
                Icons.admin_panel_settings,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleChip(WidgetRef ref, UserRole role, UserRole selectedRole, String label, IconData icon, Color color) {
    final isSelected = selectedRole == role;
    return InkWell(
      onTap: () => setUserRole(ref, role),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: kTextStyle(
                size: 14,
                isBold: isSelected,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(bool isSignUp) {
    return Column(
      children: [
        if (isSignUp) ...[
          _buildTextField('Full Name', Icons.person_outline),
          const SizedBox(height: 16),
        ],
        _buildTextField('Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildTextField('Password', Icons.lock_outline, isPassword: true),
        if (!isSignUp) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Forgot Password?',
                style: kTextStyle(size: 14, color: Colors.blue[700]),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: isPassword ? Icon(Icons.visibility_off_outlined, color: Colors.grey[600]) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      obscureText: isPassword,
      keyboardType: keyboardType,
    );
  }

  Widget _buildSubmitButton(BuildContext context, WidgetRef ref, bool isSignUp, UserRole selectedRole) {
    return ElevatedButton(
      onPressed: () => _handleSubmit(context, ref, selectedRole),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        isSignUp ? 'Create Account' : 'Sign In',
        style: kTextStyle(size: 16, isBold: true, color: Colors.white),
      ),
    );
  }

  Widget _buildToggleButton(WidgetRef ref, bool isSignUp) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isSignUp 
              ? 'Already have an account? '
              : "Don't have an account? ",
          style: kTextStyle(size: 14, color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () => toggle(ref, !isSignUp),
          child: Text(
            isSignUp ? 'Sign In' : 'Sign Up',
            style: kTextStyle(size: 14, isBold: true, color: Colors.blue[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: Colors.grey[300]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: kTextStyle(size: 12, color: Colors.grey[500]),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.grey[300]),
            ),
          ],
        ),
      ],
    );
  }

  void _handleSubmit(BuildContext context, WidgetRef ref, UserRole selectedRole) {
    // Mock authentication - in real app, this would validate credentials
    if (selectedRole == UserRole.admin) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => const AdminEventsScreen(),
      ));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => const EventsScreen(),
      ));
    }
  }
}