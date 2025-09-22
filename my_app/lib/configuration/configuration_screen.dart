import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Language Setting
            _buildSettingItem(
              icon: Icons.language,
              iconColor: Color(0xFFFFBE0B),
              iconBackgroundColor: Color(0xFFFFBE0B).withOpacity(0.1),
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: () => _showLanguageDialog(),
              showArrow: true,
            ),
            
            SizedBox(height: 16),
            
            // Notifications Setting
            _buildSettingItem(
              icon: Icons.notifications,
              iconColor: Color(0xFF4ECDC4),
              iconBackgroundColor: Color(0xFF4ECDC4).withOpacity(0.1),
              title: 'Notifications',
              onTap: () {
                // Navigate to notifications settings
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navigating to Notifications settings')),
                );
              },
              showArrow: true,
            ),
            
            SizedBox(height: 16),
            
            // Dark Mode Setting
            _buildSettingItem(
              icon: Icons.dark_mode,
              iconColor: Color(0xFF6C63FF),
              iconBackgroundColor: Color(0xFF6C63FF).withOpacity(0.1),
              title: 'Dark Mode',
              subtitle: _darkMode ? 'On' : 'Off',
              trailing: Switch(
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
                activeColor: Color(0xFF6C63FF),
                activeTrackColor: Color(0xFF6C63FF).withOpacity(0.3),
              ),
              showArrow: false, onTap: () {  },
            ),
            
            SizedBox(height: 16),
            
            // Help Setting
            _buildSettingItem(
              icon: Icons.help_center,
              iconColor: Color(0xFFFF6B6B),
              iconBackgroundColor: Color(0xFFFF6B6B).withOpacity(0.1),
              title: 'Help',
              onTap: () {
                // Navigate to help section
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening Help section')),
                );
              },
              showArrow: true,
            ),
            
                        SizedBox(height: 16),

            
            // Privacy Setting
            _buildSettingItem(
              icon: Icons.privacy_tip,
              iconColor: Color(0xFF9C27B0),
              iconBackgroundColor: Color(0xFF9C27B0).withOpacity(0.1),
              title: 'Privacy & Security',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening Privacy settings')),
                );
              },
              showArrow: true,
            ),
            
            SizedBox(height: 16),
            
            // About Setting
            _buildSettingItem(
              icon: Icons.info,
              iconColor: Color(0xFF4CAF50),
              iconBackgroundColor: Color(0xFF4CAF50).withOpacity(0.1),
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () {
                _showAboutDialog();
              },
              showArrow: true,
            ),
            
            SizedBox(height: 16),
            
            // Logout Setting
            _buildSettingItem(
              icon: Icons.logout,
              iconColor: Color(0xFFFF5722),
              iconBackgroundColor: Color(0xFFFF5722).withOpacity(0.1),
              title: 'Logout',
              onTap: () {
                _showLogoutDialog();
              },
              showArrow: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback? onTap,
    required bool showArrow,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing,
            ] else if (showArrow) ...[
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English'),
              _buildLanguageOption('Spanish'),
              _buildLanguageOption('French'),
              _buildLanguageOption('German'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language),
      trailing: _selectedLanguage == language 
          ? Icon(Icons.check, color: Color(0xFFFFBE0B))
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Learning App',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Color(0xFF6C63FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.school,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        Text('A modern learning application designed to help you achieve your educational goals.'),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Implement logout logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged out successfully')),
                );
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}