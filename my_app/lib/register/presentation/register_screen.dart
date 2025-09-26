import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:my_app/register/domain/usecases/register_user.dart';
import 'package:my_app/widgets/custom_snackbar.dart';
import 'blocs/register_bloc.dart';
import 'blocs/register_event.dart';
import 'blocs/register_state.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc(
        registerUser: GetIt.instance<RegisterUser>(), // ✅ caso de uso inyectado
    ),
    child: _RegisterScreenBody(),
  );
}

}

class _RegisterScreenBody extends StatefulWidget {
  @override
  _RegisterScreenBodyState createState() => _RegisterScreenBodyState();
}

class _RegisterScreenBodyState extends State<_RegisterScreenBody> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String? _selectedGenero;
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildGenderOption({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
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
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 60,
          margin: EdgeInsets.symmetric(horizontal: 4),
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
            color: isSelected ? null : Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Color(0xFFE9ECEF),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.2)
                      : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 20,
                ),
              ),
              SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF495057),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is RegisterFailure) {
            CustomSnackBar.showError(
              context: context,
              message: state.error,
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4CAF50), // Verde principal
                Color(0xFF66BB6A),
                Color(0xFF81C784),
                Color(0xFF9CCC65),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Avatar superior
                Container(
                  height: 100,
                  width: 100,
                  margin: EdgeInsets.only(top: 16, bottom: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                          SizedBox(height: 50),
                Container(
                  child: Container(
                    width: double.infinity,
                    
                    padding: EdgeInsets.all(24),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Título
                          Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),

                          // Campo Nombre
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextFormField(
                              controller: _nameController,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2D2D2D),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Tu nombre completo',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontSize: 16,
                                ),
                                prefixIcon: Container(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: Color(0xFF4CAF50),
                                    size: 20,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu nombre';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 16),

                          // Campo Email
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2D2D2D),
                              ),
                              decoration: InputDecoration(
                                hintText: 'tu@email.com',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontSize: 16,
                                ),
                                prefixIcon: Container(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.alternate_email,
                                    color: Color(0xFF4CAF50),
                                    size: 20,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
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
                          ),
                          SizedBox(height: 16),

                          // Campo Password
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2D2D2D),
                              ),
                              decoration: InputDecoration(
                                hintText: '••••••••••••',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontSize: 16,
                                ),
                                prefixIcon: Container(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF4CAF50),
                                    size: 20,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Color(0xFF9E9E9E),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
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
                          ),

                          SizedBox(height: 16),

                          // Sección de Género Mejorada
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Género',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D2D2D),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildGenderOption(
                                    value: "boy",
                                    label: "Masculino",
                                    icon: Icons.male_rounded,
                                    color: Color(0xFF2196F3),
                                  ),
                                  _buildGenderOption(
                                    value: "girl",
                                    label: "Femenino",
                                    icon: Icons.female_rounded,
                                    color: Color(0xFFE91E63),
                                  ),
                                ],
                              ),
                              if (_selectedGenero == null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Selecciona tu género',
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Botón Crear Cuenta
                          BlocBuilder<RegisterBloc, RegisterState>(
                            builder: (context, state) {
                              return Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF4CAF50),
                                      Color(0xFF2E7D32),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF4CAF50).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: state is RegisterLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate() && _selectedGenero != null) {
                                            context.read<RegisterBloc>().add(
                                                  RegisterSubmitted(
                                                    email: _emailController.text
                                                        .trim(),
                                                    password:
                                                        _passwordController
                                                            .text,
                                                    name: _nameController.text
                                                        .trim(),
                                                    gender: _selectedGenero!,
                                                  ),
                                                );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: state is RegisterLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Crear Cuenta',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20),

                          // Link a Login - Dentro de la card
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "¿Ya tienes cuenta? ",
                                style: TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/login');
                                },
                                child: Text(
                                  "Inicia Sesión",
                                  style: TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            )],
            ),
          ),
        ),
      ),
    );
  }
}