import 'package:flutter/material.dart';
import 'package:my_app/showcase/showcase_preferences.dart';

/// Widget que muestra el progreso de los tutoriales completados
class ShowCaseProgressWidget extends StatelessWidget {
  final bool showCompletionBadge;
  final VoidCallback? onTap;

  const ShowCaseProgressWidget({
    super.key,
    this.showCompletionBadge = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ShowCasePreferences.getProgressInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final info = snapshot.data!;
        final completed = info['completed'] as int;
        final total = info['total'] as int;
        final percentage = info['percentage'] as int;
        final isCompleted = info['is_completed'] as bool;

        // No mostrar si ya completó todos
        if (isCompleted && !showCompletionBadge) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? Colors.green.withOpacity(0.1)
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted 
                    ? Colors.green
                    : Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.school,
                  color: isCompleted 
                      ? Colors.green
                      : Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isCompleted 
                      ? '¡Tutoriales completados! 🎉'
                      : 'Tutoriales: $completed/$total ($percentage%)',
                  style: TextStyle(
                    color: isCompleted 
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (!isCompleted) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: completed / total,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Diálogo que muestra información detallada del progreso de tutoriales
class ShowCaseProgressDialog extends StatelessWidget {
  const ShowCaseProgressDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ShowCaseProgressDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: ShowCasePreferences.getAllShowCaseStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final status = snapshot.data!;
        final showcases = [
          {'id': 'home', 'name': 'Inicio', 'icon': Icons.home, 'emoji': '🏠'},
          {'id': 'library', 'name': 'Biblioteca', 'icon': Icons.library_books, 'emoji': '📚'},
          {'id': 'forum', 'name': 'Foro', 'icon': Icons.forum, 'emoji': '💬'},
          {'id': 'habits', 'name': 'Hábitos', 'icon': Icons.check_circle, 'emoji': '✅'},
          {'id': 'mental_balance', 'name': 'Equilibrio Mental', 'icon': Icons.spa, 'emoji': '🧘'},
          {'id': 'profile', 'name': 'Perfil', 'icon': Icons.person, 'emoji': '👤'},
        ];

        final completedCount = showcases.where((s) => status[s['id']] == true).length;
        final progress = completedCount / showcases.length;

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                completedCount == showcases.length 
                    ? Icons.emoji_events 
                    : Icons.school,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Progreso de Tutoriales'),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra de progreso
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progreso Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$completedCount/${showcases.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toInt()}% completado',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tutoriales disponibles:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // Lista de showcases
                ...showcases.map((showcase) {
                  final isCompleted = status[showcase['id']] ?? false;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : Icons.circle_outlined,
                          color: isCompleted ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${showcase['emoji']} ${showcase['name']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isCompleted ? Colors.black87 : Colors.grey.shade600,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                if (completedCount == showcases.length) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '¡Felicitaciones! Has completado todos los tutoriales 🎉',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (completedCount < showcases.length)
              TextButton(
                onPressed: () async {
                  await ShowCasePreferences.resetAllShowCases();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tutoriales reiniciados'),
                      ),
                    );
                  }
                },
                child: const Text('Reiniciar Tutoriales'),
              ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}