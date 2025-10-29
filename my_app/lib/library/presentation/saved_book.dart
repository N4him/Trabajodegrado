import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:my_app/core/di/injector.dart';
import 'package:my_app/library/domain/entities/saved_book_entity.dart';
import 'package:my_app/library/domain/usescases/get_reading_progress_usecase.dart';
import 'package:my_app/library/presentation/blocs/saved_book_bloc.dart';
import 'package:my_app/library/presentation/blocs/saved_book_event.dart';
import 'package:my_app/library/presentation/blocs/saved_book_state.dart';
import 'package:my_app/showcase/showcase_manager.dart';
import 'package:my_app/showcase/show_keys.dart';

class SavedBooksPage extends StatefulWidget {
  final bool disableShowcase;

  const SavedBooksPage({
    super.key,
    this.disableShowcase = false,
  });

  @override
  State<SavedBooksPage> createState() => _SavedBooksPageState();
}

class _SavedBooksPageState extends State<SavedBooksPage> {
  late String _userId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  final Map<String, double> _bookProgress = {};
  final Map<String, bool> _bookCompleted = {};

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser?.uid ?? '';

    if (_userId.isNotEmpty) {
      context.read<SavedBookBloc>().add(GetUserSavedBooksEvent(_userId));
    }

    _checkAndStartShowCase();
  }

  void _checkAndStartShowCase() async {
    // Si el showcase está desactivado (por ejemplo, cuando se usa como tab), no hacer nada
    if (widget.disableShowcase) {
      print('⏭️ Showcase desactivado para este contexto');
      return;
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final showcaseManager = ShowcaseManager();

    if (showcaseManager.hasDeclinedContinuation) {
      print(
          '⏸️ Usuario declinó continuar los tutoriales. No se iniciará showcase.');
      return;
    }

    final shouldShow = await showcaseManager.shouldShowShowcase('saved_books');

    print('🔍 DEBUG - Debe mostrar Saved Books showcase: $shouldShow');

    if (shouldShow && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          print('🚀 Iniciando showcase de Saved Books...');
          ShowCaseWidget.of(context).startShowCase([
            ShowCaseKeys.savedBooksHeaderKey,
            ShowCaseKeys.savedBooksListKey,
            ShowCaseKeys.savedBooksReadKey,
            ShowCaseKeys.savedBooksDeleteKey,
          ]);
        }
      });
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Eliminar libro guardado'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar este libro de tu estantería?'),
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
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      context.read<SavedBookBloc>().add(DeleteSavedBookEvent(bookId, _userId));
      return true;
    }
    return false;
  }

  void _navigateToBookDetail(String bookId) {
    Navigator.pushNamed(context, '/book-detail', arguments: bookId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? colorScheme.background : const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Showcase(
          key: ShowCaseKeys.savedBooksHeaderKey,
          description:
              '📚 Esta es tu estantería personal donde encontrarás todos los libros que has guardado. Usa el botón de actualizar para sincronizar tu colección.',
          targetBorderRadius: BorderRadius.circular(12),
          tooltipBackgroundColor: const Color(0xFF9D6055),
          textColor: Colors.white,
          targetPadding: const EdgeInsets.all(8),
          child: Text(
            'Mi Estantería',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            onPressed: _refreshBooks,
          ),
        ],
      ),
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
    final List<List<SavedBookEntity>> shelves = [];
    for (int i = 0; i < books.length; i += 3) {
      shelves
          .add(books.sublist(i, i + 3 > books.length ? books.length : i + 3));
    }

    return Showcase(
      key: ShowCaseKeys.savedBooksListKey,
      description:
          '🪑 Tus libros están organizados en estantes, igual que en una biblioteca real. Cada estante puede contener hasta 3 libros. Desliza hacia abajo para ver más.',
      targetBorderRadius: BorderRadius.circular(16),
      tooltipBackgroundColor: const Color(0xFF9D6055),
      textColor: Colors.white,
      targetPadding: const EdgeInsets.all(12),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: shelves.length,
        itemBuilder: (context, shelfIndex) {
          return _buildShelfRow(
            shelves[shelfIndex],
            colorScheme,
            isDark,
            isFirstShelf: shelfIndex == 0,
          );
        },
      ),
    );
  }

  Widget _buildShelfRow(
    List<SavedBookEntity> booksInShelf,
    ColorScheme colorScheme,
    bool isDark, {
    bool isFirstShelf = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
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
                        isFirstBook: isFirstShelf && i == 0,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
              ],
            ),
          ),
          _buildShelfBoard(colorScheme, isDark),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < 3; i++)
                if (i < booksInShelf.length)
                  Expanded(
                    child:
                        _buildProgressBar(booksInShelf[i], colorScheme, isDark),
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
    bool isDark, {
    bool isFirstBook = false,
  }) {
    final isCompleted = _bookCompleted[book.id] ?? false;

    final bookWidget = GestureDetector(
      onTap: () => _showBookOptions(book, colorScheme, isDark),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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
                    book.coverUrl.isNotEmpty
                        ? Image.network(
                            book.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultBookCover(book, colorScheme);
                            },
                          )
                        : _buildDefaultBookCover(book, colorScheme),
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
                    if (isCompleted)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 160, 93, 85),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 14),
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

    if (isFirstBook) {
      return Showcase(
        key: ShowCaseKeys.savedBooksReadKey,
        description:
            '📖 Toca cualquier libro para ver sus opciones. Podrás leer el libro, ver tu progreso de lectura o eliminarlo de tu estantería. Los libros completados tienen una marca de verificación.',
        targetBorderRadius: BorderRadius.circular(8),
        tooltipBackgroundColor: const Color(0xFF9D6055),
        textColor: Colors.white,
        targetPadding: const EdgeInsets.all(8),
        onTargetClick: () {
          // Abrir el modal automáticamente cuando se complete este showcase
          _showBookOptions(book, colorScheme, isDark);
        },
        disposeOnTap: true,
        child: bookWidget,
      );
    }

    return bookWidget;
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
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 160, 93, 85),
                ),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isCompleted ? 'Leído' : '${progress.toInt()}%',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 160, 93, 85),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showBookOptions(
      SavedBookEntity book, ColorScheme colorScheme, bool isDark) {
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
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
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
                                    color:
                                        const Color.fromARGB(255, 160, 93, 85),
                                    child: const Icon(Icons.menu_book,
                                        color: Colors.white, size: 24),
                                  );
                                },
                              )
                            : Container(
                                color: const Color.fromARGB(255, 160, 93, 85),
                                child: const Icon(Icons.menu_book,
                                    color: Colors.white, size: 24),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                          if (hasProgress) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  isCompleted
                                      ? Icons.check_circle
                                      : Icons.auto_stories,
                                  size: 14,
                                  color: const Color.fromARGB(255, 160, 93, 85),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isCompleted
                                      ? 'Completado'
                                      : 'Progreso: ${progress.toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 160, 93, 85),
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
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9D6055).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: Color(0xFF9D6055), size: 22),
                ),
                title: Text(
                  hasProgress && !isCompleted
                      ? 'Continuar leyendo'
                      : 'Leer libro',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToBookDetail(book.id);
                },
              ),
              Showcase(
                key: ShowCaseKeys.savedBooksDeleteKey,
                description:
                    '🗑️ Si ya no quieres un libro en tu estantería, puedes eliminarlo aquí. No te preocupes, siempre podrás volver a guardarlo desde la biblioteca.',
                targetBorderRadius: BorderRadius.circular(12),
                tooltipBackgroundColor: const Color(0xFF9D6055),
                textColor: Colors.white,
                targetPadding: const EdgeInsets.all(8),
                disposeOnTap: true,
                onTargetClick: () async {
                  // Cerrar el modal primero
                  Navigator.of(context).pop();

                  // Esperar un momento para que se cierre el modal
                  await Future.delayed(const Duration(milliseconds: 300));

                  // Marcar showcase como completado
                  if (mounted) {
                    await ShowcaseManager().onShowcaseComplete(
                      context,
                      'saved_books',
                      showDialog: true,
                    );
                  }
                },
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.red, size: 22),
                  ),
                  title: const Text(
                    'Eliminar de mi estantería',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(book.id);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultBookCover(SavedBookEntity book, ColorScheme colorScheme) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9D6055), Color(0xFF9D6055)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book, color: Colors.white, size: 32),
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
                  color: Colors.white),
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
              style:
                  TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShelfBoard(ColorScheme colorScheme, bool isDark) {
    final woodColor =
        isDark ? const Color(0xFF3D2F1F) : const Color(0xFF8B4513);

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
                child:
                    Container(height: 1, color: Colors.black.withOpacity(0.1)),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child:
                    Container(height: 1, color: Colors.white.withOpacity(0.1)),
              ),
            ],
          ),
        ),
        Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: woodColor.withOpacity(0.7),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(2)),
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
                  offset: const Offset(0, 4)),
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
                    color: colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Guarda tus libros favoritos de la librería para verlos aquí en tu estantería personal',
                style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.6)),
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
      String message, ColorScheme colorScheme, bool isDark) {
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
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.error_outline_rounded,
                    size: 64, color: Colors.red.withOpacity(0.7)),
              ),
              const SizedBox(height: 24),
              Text(
                'Algo salió mal',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _refreshBooks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D6055),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Reintentar',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
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
      List<SavedBookEntity> books, ColorScheme colorScheme, bool isDark) {
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
