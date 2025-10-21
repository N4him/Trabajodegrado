import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/core/di/injector.dart';
import 'package:my_app/library/domain/entities/saved_book_entity.dart';
import 'package:my_app/library/domain/usescases/get_reading_progress_usecase.dart';
import 'package:my_app/library/presentation/blocs/saved_book_bloc.dart';
import 'package:my_app/library/presentation/blocs/saved_book_event.dart';
import 'package:my_app/library/presentation/blocs/saved_book_state.dart';

class SavedBooksPage extends StatefulWidget {
  const SavedBooksPage({super.key});

  @override
  State<SavedBooksPage> createState() => _SavedBooksPageState();
}

class _SavedBooksPageState extends State<SavedBooksPage> {
  late String _userId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  
  // Map para almacenar el progreso de cada libro
  final Map<String, double> _bookProgress = {};
  final Map<String, bool> _bookCompleted = {};

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser?.uid ?? '';
    
    if (_userId.isNotEmpty) {
      context.read<SavedBookBloc>().add(GetUserSavedBooksEvent(_userId));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBookProgress(String bookId) async {
    if (_userId.isEmpty) return;
    
    try {
      final getProgressUseCase = getIt<GetReadingProgressUseCase>();
      final result = await getProgressUseCase(bookId, _userId);
      
      result.fold(
        (failure) => null,
        (progress) {
          if (progress != null && mounted) {
            setState(() {
              _bookProgress[bookId] = progress.progressPercentage;
              _bookCompleted[bookId] = progress.isCompleted;
            });
          }
        },
      );
    } catch (e) {
      // Error al cargar progreso
    }
  }

  Future<void> _refreshBooks() async {
    if (_userId.isNotEmpty) {
      // Limpiar el cache de progreso
      setState(() {
        _bookProgress.clear();
        _bookCompleted.clear();
      });
      
      context.read<SavedBookBloc>().add(RefreshSavedBooksEvent(_userId));
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<bool> _confirmDelete(String bookId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Eliminar libro guardado'),
          content: const Text('¿Estás seguro de que deseas eliminar este libro de tu estantería?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      // ignore: use_build_context_synchronously
      context.read<SavedBookBloc>().add(
        DeleteSavedBookEvent(bookId, _userId),
      );
      return true;
    }
    return false;
  }

  void _navigateToBookDetail(String bookId) {
    Navigator.pushNamed(
      context,
      '/book-detail',
      arguments: bookId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.background : const Color(0xFFFAF9F6),
      body: BlocBuilder<SavedBookBloc, SavedBookState>(
        builder: (context, state) {
          if (state is SavedBookLoading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(60.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF9D6055),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando tu estantería...',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is SavedBooksLoaded) {
            if (state.books.isEmpty) {
              return _buildEmptyState(colorScheme, isDark);
            }

            // Cargar el progreso de todos los libros
            for (var book in state.books) {
              _loadBookProgress(book.id);
            }

            return SafeArea(
              child: RefreshIndicator(
                onRefresh: _refreshBooks,
                color: const Color(0xFF9D6055),
                child: _buildBookshelf(state.books, colorScheme, isDark),
              ),
            );
          } else if (state is SavedBookError) {
            return _buildErrorState(state.message, colorScheme, isDark);
          } else if (state is SavedBookUpdating) {
            return _buildUpdatingState(state.books, colorScheme, isDark);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildBookshelf(
    List<SavedBookEntity> books,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    // Dividir los libros en grupos de 3
    final List<List<SavedBookEntity>> shelves = [];
    for (int i = 0; i < books.length; i += 3) {
      shelves.add(
        books.sublist(i, i + 3 > books.length ? books.length : i + 3),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      itemCount: shelves.length,
      itemBuilder: (context, shelfIndex) {
        return _buildShelfRow(shelves[shelfIndex], colorScheme, isDark);
      },
    );
  }

  Widget _buildShelfRow(
    List<SavedBookEntity> booksInShelf,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          // Los libros en la estantería
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < 3; i++)
                  if (i < booksInShelf.length)
                    Expanded(
                      child: _buildBookOnShelf(
                        booksInShelf[i],
                        colorScheme,
                        isDark,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
              ],
            ),
          ),
          // El estante (tabla)
          _buildShelfBoard(colorScheme, isDark),
          // Barras de progreso debajo del estante
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < 3; i++)
                if (i < booksInShelf.length)
                  Expanded(
                    child: _buildProgressBar(
                      booksInShelf[i],
                      colorScheme,
                      isDark,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookOnShelf(
    SavedBookEntity book,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final isCompleted = _bookCompleted[book.id] ?? false;

    return GestureDetector(
      onTap: () => _showBookOptions(book, colorScheme, isDark),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Portada del libro
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen de portada
                    book.coverUrl.isNotEmpty
                        ? Image.network(
                            book.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultBookCover(book, colorScheme);
                            },
                          )
                        : _buildDefaultBookCover(book, colorScheme),
                    
                    // Lomo del libro (efecto lateral)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Badge de completado en la esquina superior
                    if (isCompleted)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const  Color.fromARGB(255, 160, 93, 85),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    SavedBookEntity book,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final progress = _bookProgress[book.id] ?? 0.0;
    final isCompleted = _bookCompleted[book.id] ?? false;
    final hasProgress = _bookProgress.containsKey(book.id);

    if (!hasProgress) {
      return const SizedBox(height: 24);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          // Barra de progreso
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.grey[800] 
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted
                      ? Color.fromARGB(255, 160, 93, 85)
                      : const Color.fromARGB(255, 160, 93, 85),
                ),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Texto de porcentaje
          Text(
            isCompleted ? 'Leído' : '${progress.toInt()}%',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isCompleted
                  ? Color.fromARGB(255, 160, 93, 85)
                  : const Color.fromARGB(255, 160, 93, 85),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showBookOptions(SavedBookEntity book, ColorScheme colorScheme, bool isDark) {
    final progress = _bookProgress[book.id] ?? 0.0;
    final isCompleted = _bookCompleted[book.id] ?? false;
    final hasProgress = _bookProgress.containsKey(book.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Indicador de arrastre
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Información del libro
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Portada pequeña
                    Container(
                      width: 60,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: book.coverUrl.isNotEmpty
                            ? Image.network(
                                book.coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color.fromARGB(255, 160, 93, 85),
                                    child: const Icon(
                                      Icons.menu_book,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: const Color.fromARGB(255, 160, 93, 85),
                                child: const Icon(
                                  Icons.menu_book,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Información
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          // Progreso
                          if (hasProgress) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  isCompleted ? Icons.check_circle : Icons.auto_stories,
                                  size: 14,
                                  color: isCompleted
                                      ? const Color.fromARGB(255, 160, 93, 85)
                                      : const Color.fromARGB(255, 160, 93, 85),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isCompleted 
                                      ? 'Completado' 
                                      : 'Progreso: ${progress.toInt()}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isCompleted
                                        ? const Color.fromARGB(255, 160, 93, 85)
                                        : const Color.fromARGB(255, 160, 93, 85),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const Divider(height: 1),
              
              // Opciones
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9D6055).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF9D6055),
                    size: 22,
                  ),
                ),
                title: Text(
                  hasProgress && !isCompleted ? 'Continuar leyendo' : 'Leer libro',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToBookDetail(book.id);
                },
              ),
              
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Eliminar de mi estantería',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(book.id);
                },
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultBookCover(SavedBookEntity book, ColorScheme colorScheme) {
    final colors = [
      [const Color(0xFF9D6055), const Color(0xFF9D6055)],
    ];
    
    final colorIndex = book.title.length % colors.length;
    final bookColors = colors[colorIndex];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bookColors,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.menu_book,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              book.title,
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              book.author,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShelfBoard(ColorScheme colorScheme, bool isDark) {
    final woodColor = isDark ? const Color(0xFF3D2F1F) : const Color(0xFF8B4513);
    
    return Column(
      children: [
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: woodColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 4,
                child: Container(
                  height: 1,
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: woodColor.withOpacity(0.7),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF9D6055).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bookmark_outline_rounded,
                  size: 80,
                  color: const Color(0xFF9D6055).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Estantería vacía',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Guarda tus libros favoritos de la librería para verlos aquí en tu estantería personal',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    String message,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Algo salió mal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _refreshBooks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D6055),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Reintentar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdatingState(
    List<SavedBookEntity> books,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return SafeArea(
      child: Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: _buildBookshelf(books, colorScheme, isDark),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                color: Color(0xFF9D6055),
                strokeWidth: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}