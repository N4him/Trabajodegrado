import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/library/domain/entities/book_entity.dart';

import 'package:my_app/library/domain/entities/saved_book_entity.dart';
import 'package:my_app/library/presentation/blocs/saved_book_bloc.dart';
import 'package:my_app/library/presentation/blocs/saved_book_event.dart';

class BookCardWidget extends StatefulWidget {
  final BookEntity book;
  final VoidCallback onTap;

  const BookCardWidget({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  State<BookCardWidget> createState() => _BookCardWidgetState();
}

class _BookCardWidgetState extends State<BookCardWidget> {
  bool _isSaved = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkIfBookIsSaved();
  }

  Future<void> _checkIfBookIsSaved() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        final isSaved = await context.read<SavedBookBloc>().repository.isBookSaved(
          widget.book.id,
          userId,
        );
        if (mounted) {
          setState(() {
            _isSaved = isSaved;
          });
        }
      } catch (e) {
        // Error al verificar, continuar sin cambios
      }
    }
  }

  void _toggleSaveBook() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para guardar libros'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_isSaved) {
      // Eliminar el libro guardado
      context.read<SavedBookBloc>().add(
        DeleteSavedBookEvent(widget.book.id, userId),
      );
      setState(() => _isSaved = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Libro eliminado de guardados'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      // Guardar el libro
      final savedBook = SavedBookEntity(
        id: widget.book.id,
        title: widget.book.title,
        author: widget.book.author,
        description: widget.book.description,
        category: widget.book.category,
        coverUrl: widget.book.coverUrl,
        pages: widget.book.pages,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<SavedBookBloc>().add(
        SaveBookEvent(savedBook, userId),
      );
      setState(() => _isSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Libro guardado exitosamente'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del libro con botón de guardar
            Stack(
              children: [
                // Contenedor de la imagen
                Container(
                  width: 80,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildBookCover(),
                  ),
                ),
                // Botón de guardar (bookmark)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: _toggleSaveBook,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isSaved 
                            ? Icons.bookmark_rounded 
                            : Icons.bookmark_outline_rounded,
                        color: _isSaved 
                            ? const Color(0xFFFFB800) 
                            : Colors.grey[400],
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Información del libro
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Título
                  Text(
                    widget.book.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Autor
                  Text(
                    widget.book.author.isNotEmpty 
                        ? widget.book.author 
                        : 'Extracurricular reading / Growing motivational story book',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.5),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Footer con categoría y botón
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Categoría
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB800).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.book.category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFFFB800),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Botón "Leer"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB800),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Leer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCover() {
    // Si hay coverUrl, usar imagen normal
    if (widget.book.coverUrl.isNotEmpty) {
      return Image.network(
        widget.book.coverUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackCover();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingCover();
        },
      );
    }
    
    // Fallback con gradiente
    return _buildFallbackCover();
  }

  Widget _buildLoadingCover() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFFB800),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildFallbackCover() {
    final colors = _getGradientColors(widget.book.title);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.menu_book,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  List<Color> _getGradientColors(String title) {
    final hash = title.hashCode.abs();
    final gradients = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFF2193b0), const Color(0xFF6dd5ed)],
      [const Color(0xFFee0979), const Color(0xFFff6a00)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
      [const Color(0xFF30cfd0), const Color(0xFF330867)],
      [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
      [const Color(0xFFff9a9e), const Color(0xFFfecfef)],
      [const Color(0xFF6a11cb), const Color(0xFF2575fc)],
      [const Color(0xFFf12711), const Color(0xFFf5af19)],
    ];
    
    return gradients[hash % gradients.length];
  }
}