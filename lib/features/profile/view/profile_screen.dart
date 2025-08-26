import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/core/providers.dart';
import 'package:campus_event_mgmt_system/core/utils/kTextStyle.dart';
import 'package:campus_event_mgmt_system/features/auth/view/auth_screen.dart';
import 'package:campus_event_mgmt_system/features/profile/view/notification_settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(userRole),
            const SizedBox(height: 24),
            _buildProfileOptions(context, ref, userRole),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Profile', style: kTextStyle(size: 20, isBold: true)),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader(UserRole userRole) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileAvatar(userRole),
          const SizedBox(height: 16),
          Text(
            userRole == UserRole.admin ? 'Admin User' : 'Student User',
            style: kTextStyle(size: 24, isBold: true),
          ),
          const SizedBox(height: 8),
          Text(
            userRole == UserRole.admin ? 'Event Administrator' : 'Campus Student',
            style: kTextStyle(size: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          _buildRoleBadge(userRole),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(UserRole userRole) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: userRole == UserRole.admin ? Colors.blue[100] : Colors.green[100],
        shape: BoxShape.circle,
        border: Border.all(
          color: userRole == UserRole.admin ? Colors.blue[300]! : Colors.green[300]!,
          width: 3,
        ),
      ),
      child: Icon(
        userRole == UserRole.admin ? Icons.admin_panel_settings : Icons.school,
        size: 48,
        color: userRole == UserRole.admin ? Colors.blue[700] : Colors.green[700],
      ),
    );
  }

  Widget _buildRoleBadge(UserRole userRole) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: userRole == UserRole.admin ? Colors.blue[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: userRole == UserRole.admin ? Colors.blue[200]! : Colors.green[200]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            userRole == UserRole.admin ? Icons.admin_panel_settings : Icons.school,
            size: 16,
            color: userRole == UserRole.admin ? Colors.blue[700] : Colors.green[700],
          ),
          const SizedBox(width: 6),
          Text(
            userRole == UserRole.admin ? 'Administrator' : 'Student',
            style: kTextStyle(
              size: 14,
              isBold: true,
              color: userRole == UserRole.admin ? Colors.blue[700] : Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, WidgetRef ref, UserRole userRole) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        children: [
          _buildProfileOption(
            context,
            Icons.person_outline,
            'Personal Information',
            'View and edit your profile details',
            () => _handlePersonalInfo(context),
          ),
          _buildDivider(),
          _buildProfileOption(
            context,
            Icons.notifications_outlined,
            'Notifications',
            'Manage your notification preferences',
            () => _handleNotifications(context),
          ),
          _buildDivider(),
          _buildProfileOption(
            context,
            Icons.security_outlined,
            'Privacy & Security',
            'Manage your privacy settings',
            () => _handlePrivacy(context),
          ),
          _buildDivider(),
          _buildProfileOption(
            context,
            Icons.help_outline,
            'Help & Support',
            'Get help and contact support',
            () => _handleHelp(context),
          ),
          _buildDivider(),
          _buildProfileOption(
            context,
            Icons.info_outline,
            'About',
            'App version and information',
            () => _handleAbout(context),
          ),
          _buildDivider(),
          _buildProfileOption(
            context,
            Icons.logout,
            'Logout',
            'Sign out of your account',
            () => _handleLogout(context, ref),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red[600] : Colors.grey[600],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: kTextStyle(
          size: 16,
          isBold: true,
          color: isDestructive ? Colors.red[600] : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: kTextStyle(size: 14, color: Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 56,
    );
  }

  void _handlePersonalInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Personal Information - Coming Soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleNotifications(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => const NotificationSettingsScreen(),
    ));
  }

  void _handlePrivacy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy & Security - Coming Soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help & Support - Coming Soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About', style: kTextStyle(size: 18, isBold: true)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campus Event Management System',
              style: kTextStyle(size: 16, isBold: true),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: kTextStyle(size: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'A comprehensive platform for managing campus events, designed to connect students and administrators.',
              style: kTextStyle(size: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: kTextStyle(size: 14, color: Colors.blue[700])),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: kTextStyle(size: 18, isBold: true)),
        content: Text(
          'Are you sure you want to logout? You will need to sign in again to access your account.',
          style: kTextStyle(size: 14, color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: kTextStyle(size: 14, color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text('Logout', style: kTextStyle(size: 14, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context, WidgetRef ref) {
    // Reset user role to default
    setUserRole(ref, UserRole.student);
    
    // Navigate to auth screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
    
    // Show logout confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully logged out'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
