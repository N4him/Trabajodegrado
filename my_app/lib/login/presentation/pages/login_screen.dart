import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/login/presentation/blocs/login_state.dart';
import 'package:my_app/login/presentation/blocs/login_event.dart';
import 'package:my_app/widgets/custom_snackbar.dart';
import '../blocs/login_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreenContent();
  }
}

class LoginScreenContent extends StatefulWidget {
  const LoginScreenContent({super.key});

  @override
  State<LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<LoginScreenContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // Paleta de colores coherente
  static const Color primaryColor = Color(0xFF82A69F); // Verde-gris principal
  static const Color primaryDark = Color(0xFF5A7A73); // Verde-gris oscuro
  static const Color backgroundColor = Color.fromARGB(255, 236, 232, 227); // Beige muy claro

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginBloc>().add(
            LoginSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    } else {
      CustomSnackBar.showWarning(
        context: context,
        message: 'Por favor, completa todos los campos correctamente',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocListener<LoginBloc, LoginState>(
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
                        SizedBox(height: isSmallScreen ? 8 : 60),
                        _buildIllustration(context, isSmallScreen),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        _buildTitle(isSmallScreen),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        _buildLoginForm(isSmallScreen),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        _buildOrDivider(),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        _buildCreateAccountTextLink(),
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

  void _handleStateChanges(BuildContext context, LoginState state) {
    if (state is LoginSuccess) {
      CustomSnackBar.showSuccess(
        context: context,
        message: '¡Bienvenido de vuelta!',
        duration: const Duration(seconds: 2),
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (state is LoginFailure) {
      CustomSnackBar.showError(
        context: context,
        message: state.error,
        actionLabel: 'Reintentar',
        onActionPressed: () {
          context.read<LoginBloc>().add(LoginReset());
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

    return SizedBox(
      height: illustrationSize,
      width: illustrationSize,
      child: Image.asset(
        'assets/images/ajolote_signin.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle(bool isSmallScreen) {
    return Text(
      '¡Bienvenido de vuelta!',
      style: TextStyle(
        fontSize: isSmallScreen ? 26 : 32,
        fontWeight: FontWeight.bold,
        color: primaryDark,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginForm(bool isSmallScreen) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(),
          SizedBox(height: isSmallScreen ? 10 : 14),
          _buildPasswordField(),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildLoginButton(),
        ],
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
            color: primaryColor.withOpacity(0.12),
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
          hintText: 'johnsondoe@nomail.com',
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 12),
            child: Icon(
              Icons.person_outline,
              color: primaryColor,
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
            color: primaryColor.withOpacity(0.12),
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
              color: primaryColor,
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
                color: primaryColor,
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

  Widget _buildLoginButton() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 56,
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.95),
                primaryDark.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: state is LoginLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: state is LoginLoading
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
                        'Continuar',
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
                    primaryColor.withOpacity(0),
                    primaryColor.withOpacity(0.3),
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
                color: primaryColor.withOpacity(0.7),
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
                    primaryColor.withOpacity(0.3),
                    primaryColor.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAccountTextLink() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 15,
            color: primaryDark,
          ),
          children: [
            const TextSpan(
              text: '¿No tienes una cuenta? ',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: 'Crea una aquí',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: primaryColor,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).pushNamed('/register');
                },
            ),
          ],
        ),
      ),
    );
  }
}