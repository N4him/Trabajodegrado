import 'package:flutter/material.dart';
import 'dart:math';

class EditProfileDialog extends StatefulWidget {
  final String currentName;
  final String currentPhotoUrl;
  final String gender; // Agregar parámetro de género
  final Function(String name, String? password, String photoUrl) onSave;

  const EditProfileDialog({
    super.key,
    required this.currentName,
    required this.currentPhotoUrl,
    required this.gender, // Requerido
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();

  static Future<void> show(
    BuildContext context, {
    required String currentName,
    required String currentPhotoUrl,
    required String gender, // Agregar parámetro
    required Function(String name, String? password, String photoUrl) onSave,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EditProfileDialog(
          currentName: currentName,
          currentPhotoUrl: currentPhotoUrl,
          gender: gender, // Pasar el género
          onSave: onSave,
        );
      },
    );
  }
}

class _EditProfileDialogState extends State<EditProfileDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _photoUrlController;
  late AnimationController _rotationController;
  
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGeneratingAvatar = false;
  String _previewAvatarUrl = '';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.currentName);
    _passwordController = TextEditingController();
    _photoUrlController = TextEditingController(text: widget.currentPhotoUrl);
    _previewAvatarUrl = widget.currentPhotoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _photoUrlController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _generateRandomAvatar() async {
    if (_isGeneratingAvatar) return;
    
    setState(() {
      _isGeneratingAvatar = true;
    });

    try {
      // Animación de rotación
      await _rotationController.forward();
      
      // Generar número aleatorio basado en el género
      final random = Random();
      int randomId;
      
      if (widget.gender.toLowerCase() == 'boy') {
        // Para hombres: números del 1 al 50
        randomId = random.nextInt(50) + 1;
      } else {
        // Para mujeres: números del 51 al 100
        randomId = random.nextInt(50) + 51;
      }
      
      final newAvatarUrl = 'https://avatar.iran.liara.run/public/$randomId';
      
      // Actualizar inmediatamente en el backend
      widget.onSave(
        _nameController.text.trim(),
        null, // No cambiar contraseña
        newAvatarUrl,
      );
      
      // Limpiar el campo URL y actualizar preview
      _photoUrlController.clear();
      _previewAvatarUrl = newAvatarUrl;
      
      // Reset de la animación
      _rotationController.reset();
      
      // Mostrar feedback visual
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Avatar actualizado exitosamente'),
            backgroundColor: const Color(0xFF7C4DFF),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar avatar: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingAvatar = false;
        });
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final password = _passwordController.text.trim().isEmpty 
          ? null 
          : _passwordController.text.trim();
      
      widget.onSave(
        _nameController.text.trim(),
        password,
        _photoUrlController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error al actualizar el perfil: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildProfilePictureSection(),
              const SizedBox(height: 24),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Editar Perfil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        IconButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          icon: Icon(Icons.close, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProfilePictureSection() {
    String displayUrl = _previewAvatarUrl.isNotEmpty 
        ? _previewAvatarUrl 
        : _photoUrlController.text;

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: displayUrl.isNotEmpty
                ? NetworkImage(displayUrl)
                : null,
            child: displayUrl.isEmpty
                ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                : null,
          ),
          _buildRefreshButton(),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onTap: _isGeneratingAvatar || _isLoading ? null : _generateRandomAvatar,
        child: Container(
          decoration: BoxDecoration(
            color: _isGeneratingAvatar 
                ? Colors.grey[400] 
                : const Color(0xFF7C4DFF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: Icon(
                  Icons.refresh,
                  size: 16,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return _buildFieldSection(
      label: 'Nombre de usuario',
      child: TextFormField(
        controller: _nameController,
        enabled: !_isLoading,
        decoration: _buildInputDecoration(
          hintText: 'Ingresa tu nombre',
          prefixIcon: Icons.person_outline,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El nombre es requerido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return _buildFieldSection(
      label: 'Nueva contraseña',
      child: TextFormField(
        controller: _passwordController,
        enabled: !_isLoading,
        obscureText: _obscurePassword,
        decoration: _buildInputDecoration(
          hintText: 'Deja vacío para mantener actual',
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword 
                  ? Icons.visibility_outlined 
                  : Icons.visibility_off_outlined,
              color: Colors.grey[600],
            ),
            onPressed: _isLoading ? null : _togglePasswordVisibility,
          ),
        ),
        validator: (value) {
          if (value != null && value.isNotEmpty && value.length < 6) {
            return 'La contraseña debe tener al menos 6 caracteres';
          }
          return null;
        },
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldSection({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF7C4DFF)),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}