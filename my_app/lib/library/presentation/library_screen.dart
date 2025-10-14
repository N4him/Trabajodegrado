import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:my_app/core/di/injector.dart';
import 'package:my_app/library/presentation/blocs/library_bloc.dart';
import 'package:my_app/library/presentation/blocs/library_event.dart';
import 'package:my_app/library/presentation/blocs/library_state.dart';
import 'package:my_app/library/presentation/blocs/saved_book_bloc.dart';
import 'package:my_app/library/presentation/blocs/saved_book_event.dart';
import 'package:my_app/config/app_router.dart';
import 'package:my_app/library/presentation/saved_book.dart';

import '../../widgets/book_card_widget.dart';
import '../../widgets/category_chip_widget.dart';
import '../../widgets/search_bar_widget.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late LibraryBloc _libraryBloc;

  final ScrollController _scrollController = ScrollController();
  String selectedCategory = 'Todos';
  String currentSearchQuery = '';
  int _currentIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  
  late String _userId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variables para lazy loading
  int _displayedBooksCount = 3;
  final int _booksPerPage = 3;
  bool _isLoadingMore = false;
  List<dynamic> _allBooks = [];
  final Set<String> _loadedBookIds = {}; // Track loaded books

  @override
  void initState() {
    super.initState();
    
    _userId = _auth.currentUser?.uid ?? '';
    _libraryBloc = getIt<LibraryBloc>();
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeAnimationController.forward();
    });

    _libraryBloc.add(GetBooksEvent());
    
    if (_userId.isNotEmpty) {
      context.read<SavedBookBloc>().add(GetUserSavedBooksEvent(_userId));
    }

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMoreBooks();
    }
  }

  void _loadMoreBooks() {
    if (!_isLoadingMore && _displayedBooksCount < _allBooks.length) {
      setState(() {
        _isLoadingMore = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _displayedBooksCount += _booksPerPage;
          if (_displayedBooksCount > _allBooks.length) {
            _displayedBooksCount = _allBooks.length;
          }
          _isLoadingMore = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _fadeAnimationController.dispose();
    _scrollController.dispose();
    _libraryBloc.close();
    super.dispose();
  }

  Future<void> _refreshLibrary() async {
    if (currentSearchQuery.isNotEmpty) {
      _libraryBloc.add(SearchBooksEvent(currentSearchQuery));
    } else if (selectedCategory != 'Todos') {
      _libraryBloc.add(GetBooksByCategoryEvent(selectedCategory));
    } else {
      _libraryBloc.add(GetBooksEvent());
    }
    setState(() {
      _displayedBooksCount = 3;
      _loadedBookIds.clear();
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _handleSearch(String query) {
    setState(() {
      currentSearchQuery = query.trim();
      _displayedBooksCount = 3;
      _loadedBookIds.clear();
      if (query.trim().isNotEmpty) {
        selectedCategory = 'Todos';
      }
    });

    if (query.trim().isEmpty) {
      _libraryBloc.add(GetBooksEvent());
    } else {
      _libraryBloc.add(SearchBooksEvent(query.trim()));
    }
  }

  void _handleCategoryChange(String category) {
    setState(() {
      selectedCategory = category;
      currentSearchQuery = '';
      _displayedBooksCount = 3;
      _loadedBookIds.clear();
    });

    if (category == 'Todos') {
      _libraryBloc.add(GetBooksEvent());
    } else {
      _libraryBloc.add(GetBooksByCategoryEvent(category));
    }
  }

  void _clearSearch() {
    setState(() {
      currentSearchQuery = '';
      selectedCategory = 'Todos';
      _displayedBooksCount = 3;
      _loadedBookIds.clear();
    });
    _libraryBloc.add(GetBooksEvent());
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BlocProvider<LibraryBloc>.value(
      value: _libraryBloc,
      child: Scaffold(
        backgroundColor: isDark ? colorScheme.background : const Color(0xFFFAF9F6),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildLibraryView(colorScheme, isDark),
            const SavedBooksPage(),
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: _currentIndex,
          height: 60.0,
          items: const <Widget>[
            Icon(Icons.book_rounded, size: 30, color: Colors.white),
            Icon(Icons.bookmark_rounded, size: 30, color: Colors.white),
          ],
          color: const Color.fromARGB(255, 160, 93, 85),
          buttonBackgroundColor: const Color.fromARGB(255, 192, 113, 104),
          backgroundColor: Colors.transparent,
          animationCurve: Curves.linearToEaseOut,
          animationDuration: const Duration(milliseconds: 300),
          onTap: _onNavBarTap,
        ),
      ),
    );
  }

  Widget _buildLibraryView(ColorScheme colorScheme, bool isDark) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshLibrary,
        color: const Color(0xFF9D6055),
        backgroundColor: colorScheme.surface,
        strokeWidth: 3,
        displacement: 40,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildFeaturedBannerWithSearch(),
            
            if (currentSearchQuery.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CategoryChipWidget(
                  selectedCategory: selectedCategory,
                  onCategoryChanged: _handleCategoryChange,
                ),
              ),
            
            if (currentSearchQuery.isEmpty) const SizedBox(height: 24),
            
            BlocConsumer<LibraryBloc, LibraryState>(
              listener: (context, state) {
                if (state is LibraryLoaded) {
                  _allBooks = state.books;
                }
              },
              builder: (context, state) {
                if (state is LibraryLoading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(60.0),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF9D6055),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cargando libros...',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is LibraryLoaded) {
                  if (state.books.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _buildEmptyState(),
                    );
                  }

                  final displayedBooks = state.books.take(_displayedBooksCount).toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayedBooks.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final book = displayedBooks[index];
                            return LazyBookCard(
                              key: ValueKey(book.id),
                              book: book,
                              bookId: book.id,
                              isLoaded: _loadedBookIds.contains(book.id),
                              onVisibilityChanged: (isVisible) {
                                if (isVisible) {
                                  setState(() {
                                    _loadedBookIds.add(book.id);
                                  });
                                }
                              },
                            );
                          },
                        ),

                      ],
                    ),
                  );
                } else if (state is LibraryError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildErrorState(state.message),
                  );
                }
                
                return const SizedBox();
              },
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBannerWithSearch() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(15, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/banner_lib (1).jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF9d3f35).withOpacity(0.1),
                    const Color(0xFF9d3f35).withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Biblioteca P.A.P',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(1, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lee, Aplica, Apoya',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SearchBarWidget(
                    onSearch: _handleSearch,
                    onClear: _clearSearch,
                    initialValue: currentSearchQuery,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
                  currentSearchQuery.isNotEmpty 
                    ? Icons.search_off_rounded
                    : Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                currentSearchQuery.isNotEmpty
                  ? 'No se encontraron resultados'
                  : 'Algo salió mal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                currentSearchQuery.isNotEmpty
                  ? 'No se encontraron libros para "$currentSearchQuery"'
                  : message,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (currentSearchQuery.isNotEmpty) {
                    _clearSearch();
                  } else {
                    _libraryBloc.add(GetBooksEvent());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D6055),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      currentSearchQuery.isNotEmpty 
                        ? Icons.clear_all_rounded 
                        : Icons.refresh_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentSearchQuery.isNotEmpty ? 'Limpiar búsqueda' : 'Reintentar',
                      style: const TextStyle(
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

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF9D6055).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  currentSearchQuery.isNotEmpty 
                    ? Icons.search_off_rounded
                    : Icons.auto_stories_rounded,
                  size: 30,
                  color: const Color(0xFF9D6055).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                currentSearchQuery.isNotEmpty
                  ? 'No se encontraron libros'
                  : selectedCategory != 'Todos'
                    ? 'No hay libros en esta categoría'
                    : 'No hay libros disponibles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                currentSearchQuery.isNotEmpty
                  ? 'Intenta con otros términos: "$currentSearchQuery"'
                  : selectedCategory != 'Todos'
                    ? 'No se encontraron libros en "$selectedCategory"'
                    : 'Los libros aparecerán aquí cuando estén disponibles',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
              if (currentSearchQuery.isNotEmpty || selectedCategory != 'Todos') ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _clearSearch,
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
                      Icon(Icons.library_books_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Ver todos los libros',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBookDetail(BuildContext context, String bookId) {
    Navigator.pushNamed(
      context,
      AppRouter.bookDetail,
      arguments: bookId,
    );
  }
}

// Nuevo widget con Lazy Loading - SIN ANIMACIÓN
class LazyBookCard extends StatefulWidget {
  final dynamic book;
  final String bookId;
  final bool isLoaded;
  final Function(bool) onVisibilityChanged;

  const LazyBookCard({
    Key? key,
    required this.book,
    required this.bookId,
    required this.isLoaded,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<LazyBookCard> createState() => _LazyBookCardState();
}

class _LazyBookCardState extends State<LazyBookCard> {
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.bookId),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          widget.onVisibilityChanged(true);
        }
      },
      child: widget.isLoaded
          ? BookCardWidget(
              key: Key('book_${widget.book.id}'),
              book: widget.book,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.bookDetail,
                  arguments: widget.book.id,
                );
              },
            )
          : _buildLoadingPlaceholder(),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}