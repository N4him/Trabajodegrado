import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: colorScheme.onBackground,
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
            _buildSettingItem(
              context,
              icon: Icons.language,
              iconColor: Color(0xFFFFBE0B),
              iconBackgroundColor: Color(0xFFFFBE0B).withOpacity(0.1),
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: () => _showLanguageDialog(),
              showArrow: true,
            ),
            
            SizedBox(height: 16),
            
            _buildSettingItem(
              context,
              icon: Icons.dark_mode,
              iconColor: Color(0xFF6C63FF),
              iconBackgroundColor: Color(0xFF6C63FF).withOpacity(0.1),
              title: 'Dark Mode',
              subtitle: isDarkMode ? 'On' : 'Off',
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  if (value) {
                    AdaptiveTheme.of(context).setDark();
                  } else {
                    AdaptiveTheme.of(context).setLight();
                  }
                },
                activeColor: Color(0xFF6C63FF),
                activeTrackColor: Color(0xFF6C63FF).withOpacity(0.3),
              ),
              showArrow: false,
              onTap: () {},
            ),
            
            SizedBox(height: 16),
            
            _buildSettingItem(
              context,
              icon: Icons.help_center,
              iconColor: Color(0xFFFF6B6B),
              iconBackgroundColor: Color(0xFFFF6B6B).withOpacity(0.1),
              title: 'Help',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening Help section')),
                );
              },
              showArrow: true,
            ),
            
            SizedBox(height: 16),
            
            _buildSettingItem(
              context,
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
            
            _buildSettingItem(
              context,
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

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback? onTap,
    required bool showArrow,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.08),
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
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.6),
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
                color: colorScheme.onSurface.withOpacity(0.4),
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Select Language',
            style: TextStyle(color: colorScheme.onSurface),
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Logout',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _performLogout(),
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    // Cerrar el diálogo
    Navigator.pop(context);

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF6C63FF)),
              SizedBox(height: 16),
              Text(
                'Cerrando sesión...',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Cerrar sesión en Firebase
      await FirebaseAuth.instance.signOut();

      // Cerrar el diálogo de carga
      if (mounted) Navigator.pop(context);

      // Navegar a la pantalla de login y limpiar el stack
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Cerrar el diálogo de carga
      if (mounted) Navigator.pop(context);

      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}