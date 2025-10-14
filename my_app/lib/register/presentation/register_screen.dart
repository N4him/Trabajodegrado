import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:my_app/register/domain/usecases/register_user.dart';
import 'package:my_app/widgets/custom_snackbar.dart';
import 'blocs/register_bloc.dart';
import 'blocs/register_event.dart';
import 'blocs/register_state.dart';
import 'package:flutter/gestures.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc(
        registerUser: GetIt.instance<RegisterUser>(),
      ),
      child: const _RegisterScreenBody(),
    );
  }
}

class _RegisterScreenBody extends StatefulWidget {
  const _RegisterScreenBody();

  @override
  State<_RegisterScreenBody> createState() => _RegisterScreenBodyState();
}

class _RegisterScreenBodyState extends State<_RegisterScreenBody> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedGenero;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate() && _selectedGenero != null) {
      context.read<RegisterBloc>().add(
            RegisterSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              name: _nameController.text.trim(),
              gender: _selectedGenero!,
            ),
          );
    } else if (_selectedGenero == null) {
      CustomSnackBar.showWarning(
        context: context,
        message: 'Por favor selecciona tu género',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    
    return Scaffold(
      backgroundColor: const Color(0xFFE8DFE3),
      body: BlocListener<RegisterBloc, RegisterState>(
        listener: _handleStateChanges,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: isSmallScreen ? 8 : 12,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        _buildIllustration(context, isSmallScreen),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        _buildTitle(isSmallScreen),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        _buildRegisterForm(isSmallScreen),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        _buildOrDivider(),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        _buildLoginTextLink(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, RegisterState state) {
    if (state is RegisterSuccess) {
      CustomSnackBar.showSuccess(
        context: context,
        message: '¡Cuenta creada exitosamente!',
        duration: const Duration(seconds: 2),
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (state is RegisterFailure) {
      CustomSnackBar.showError(
        context: context,
        message: state.error,
        actionLabel: 'Reintentar',
        onActionPressed: () {
          // Limpiar campos si es necesario
        },
      );
    }
  }

  Widget _buildIllustration(BuildContext context, bool isSmallScreen) {
    final size = MediaQuery.of(context).size;
    
    double illustrationSize;
    if (size.height < 600) {
      illustrationSize = size.width * 0.3;
    } else if (isSmallScreen) {
      illustrationSize = size.width * 0.38;
    } else {
      illustrationSize = size.width * 0.55;
    }
    
    illustrationSize = illustrationSize.clamp(100.0, 280.0);
    
    return Container(
      height: illustrationSize,
      width: illustrationSize,
      child: Image.asset(
        'assets/images/ajolote_register.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle(bool isSmallScreen) {
    return Text(
      '¡Crea una cuenta!',
      style: TextStyle(
        fontSize: isSmallScreen ? 26 : 32,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF6B5B5A),
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRegisterForm(bool isSmallScreen) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildNameField(),
          SizedBox(height: isSmallScreen ? 10 : 14),
          _buildEmailField(),
          SizedBox(height: isSmallScreen ? 10 : 14),
          _buildPasswordField(),
          SizedBox(height: isSmallScreen ? 14 : 18),
          _buildGenderSection(isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _nameController,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF2D2D2D),
        ),
        decoration: InputDecoration(
          hintText: 'Tu nombre completo',
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 12),
            child: Icon(
              Icons.person_outline,
              color: Colors.grey.shade700,
              size: 22,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 22,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa tu nombre';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF2D2D2D),
        ),
        decoration: InputDecoration(
          hintText: 'tu@email.com',
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 12),
            child: Icon(
              Icons.alternate_email,
              color: Colors.grey.shade700,
              size: 22,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 22,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa tu email';
          }
          if (!value.contains('@')) {
            return 'Por favor ingresa un email válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF2D2D2D),
        ),
        decoration: InputDecoration(
          hintText: '••••••••••••••••',
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 12),
            child: Icon(
              Icons.lock_outline,
              color: Colors.grey.shade700,
              size: 22,
            ),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade600,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 22,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa tu contraseña';
          }
          if (value.length < 6) {
            return 'La contraseña debe tener al menos 6 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenderSection(bool isSmallScreen) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'Género',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B5B5A),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Row(
            children: [
              _buildGenderOption(
                value: "boy",
                label: "Masculino",
                icon: Icons.male_rounded,
                color: const Color(0xFFB8956A),
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(width: 12),
              _buildGenderOption(
                value: "girl",
                label: "Femenino",
                icon: Icons.female_rounded,
                color: const Color(0xFFC4937A),
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSmallScreen,
  }) {
    final isSelected = _selectedGenero == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGenero = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: isSmallScreen ? 54 : 60,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      color.withOpacity(0.8),
                      color,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: isSmallScreen ? 18 : 20,
                ),
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF495057),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 56,
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFB8956A).withOpacity(0.9),
                const Color(0xFFA6825C).withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB8956A).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: state is RegisterLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: state is RegisterLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildOrDivider() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6B5B5A).withOpacity(0),
                    const Color(0xFF6B5B5A).withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'O',
              style: TextStyle(
                color: const Color(0xFF6B5B5A).withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6B5B5A).withOpacity(0.5),
                    const Color(0xFF6B5B5A).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginTextLink() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6B5B5A),
              ),
              children: [
                const TextSpan(
                  text: '¿Ya tienes una cuenta? ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: 'Inicia sesión aquí',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB8956A),
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}