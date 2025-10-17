import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/config/app_router.dart';
import '../blocs/habit_bloc.dart';
import '../blocs/habit_event.dart';
import '../blocs/habit_state.dart';

class HabitCreationScreen extends StatefulWidget {
  const HabitCreationScreen({super.key});

  @override
  State<HabitCreationScreen> createState() => _HabitCreationScreenState();
}

class _HabitCreationScreenState extends State<HabitCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reminderTimeController = TextEditingController();

  int _frequencyDays = 7; // Valor por defecto: diario
  DateTime _startDate = DateTime.now();
  TimeOfDay? _reminderTime;

  @override
  void dispose() {
    _nameController.dispose();
    _reminderTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectReminderTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
        _reminderTimeController.text = _reminderTime!.format(context);
      });
    }
  }

  void _dispatchCreateEvent(BuildContext context) {
    print('>>> 1. Función _dispatchCreateEvent INICIADA.');

    // 1. OBTENER EL USER ID
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print('>>> 2. Usuario actual ID: $userId');

    // 2. MANEJO DE ERROR CRÍTICO: Usuario no autenticado
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión expirada. Por favor, inicia sesión de nuevo.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.login,
        (Route<dynamic> route) => false,
      );
      return;
    }

    // 3. Verificación de Datos Mínimos
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un nombre para el hábito.')),
      );
      return;
    }

    // 4. Preparar reminderTime en formato String (HH:mm AM/PM)
    String? reminderTimeString;
    if (_reminderTime != null) {
      reminderTimeString = _reminderTime!.format(context);
    }

    // 5. Despachar el evento con todos los campos
    context.read<HabitBloc>().add(
      CreateHabitStarted(
        name: _nameController.text.trim(),
        frequencyDays: _frequencyDays,
        userId: userId,
        startDate: _startDate,
        reminderTime: reminderTimeString,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Hábito')),
      body: BlocListener<HabitBloc, HabitState>(
        listener: (context, state) {
          if (state is HabitActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Limpiar formulario después de éxito
            _nameController.clear();
            _reminderTimeController.clear();
            setState(() {
              _frequencyDays = 7;
              _startDate = DateTime.now();
              _reminderTime = null;
            });
          } else if (state is HabitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo: Nombre del Hábito
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Hábito',
                  hintText: 'Ej: Hacer ejercicio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Frecuencia
              const Text(
                'Frecuencia',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _frequencyDays,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 7, child: Text('Diario (7 días/semana)')),
                  DropdownMenuItem(value: 5, child: Text('5 veces por semana')),
                  DropdownMenuItem(value: 3, child: Text('3 veces por semana')),
                  DropdownMenuItem(value: 2, child: Text('2 veces por semana')),
                  DropdownMenuItem(value: 1, child: Text('1 vez por semana')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _frequencyDays = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de Inicio
              const Text(
                'Fecha de Inicio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectStartDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Hora de Recordatorio (Opcional)
              const Text(
                'Hora de Recordatorio (Opcional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectReminderTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                    hintText: 'Seleccionar hora',
                  ),
                  child: Text(
                    _reminderTime != null
                        ? _reminderTime!.format(context)
                        : 'Sin recordatorio',
                    style: TextStyle(
                      fontSize: 16,
                      color: _reminderTime != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de Guardar
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<HabitBloc, HabitState>(
                  builder: (context, state) {
                    if (state is HabitLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: () => _dispatchCreateEvent(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Guardar Hábito',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}