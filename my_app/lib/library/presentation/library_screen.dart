import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:my_app/core/di/injector.dart';
import 'package:my_app/library/presentation/blocs/library_bloc.dart';
import 'package:my_app/library/presentation/blocs/library_event.dart';
import 'package:my_app/library/presentation/blocs/library_state.dart';
import 'package:my_app/config/app_router.dart';

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

  @override
  void initState() {
    super.initState();
    
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
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _fadeAnimationController.dispose();
    _scrollController.dispose();
    _libraryBloc.close();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      currentSearchQuery = query.trim();
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
    });
    _libraryBloc.add(GetBooksEvent());
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = 0;
    });

    if (index == 1) {
      // Navegar a la pantalla de libros guardados
      Navigator.pushNamed(context, AppRouter.savedBooks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BlocProvider<LibraryBloc>.value(
      value: _libraryBloc,
      child: Scaffold(
        backgroundColor: isDark ? colorScheme.background : const Color(0xFFFAF9F6),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner destacado con búsqueda integrada
                _buildFeaturedBannerWithSearch(),
                
                const SizedBox(height: 20),
                
                // Categorías (chips horizontales)
                if (currentSearchQuery.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CategoryChipWidget(
                      selectedCategory: selectedCategory,
                      onCategoryChanged: _handleCategoryChange,
                    ),
                  ),
                
                if (currentSearchQuery.isEmpty) const SizedBox(height: 24),
                
                // Grid de libros
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: BlocConsumer<LibraryBloc, LibraryState>(
                    listener: (context, state) {
                      if (state is LibraryLoaded) {
                        // ignore: unused_local_variable
                        for (var book in state.books) {
                        }
                      } else if (state is LibraryError) {
                      }
                    },
                    builder: (context, state) {
                      if (state is LibraryLoading) {
                        return Center(
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
                                  'Loading books...',
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (state is LibraryLoaded) {
                        if (state.books.isEmpty) {
                          return _buildEmptyState();
                        }

                       return ListView.separated(
                         shrinkWrap: true,
                         physics: const NeverScrollableScrollPhysics(),
                         itemCount: state.books.length,
                         separatorBuilder: (context, index) => const SizedBox(height: 12),
                         itemBuilder: (context, index) {
                           final book = state.books[index];
                           return BookCardWidget(
                             key: Key('book_${book.id}'),
                             book: book,
                             onTap: () => _navigateToBookDetail(context, book.id),
                           );
                         },
                       );
                      } else if (state is LibraryError) {
                        return _buildErrorState(state.message);
                      }
                      
                      return const SizedBox();
                    },
                  ),
                ),

                const SizedBox(height: 80), // Espacio para la barra de navegación
              ],
            ),
          ),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: _currentIndex,
          height: 60.0,
          items: const <Widget>[
            Icon(Icons.home_rounded, size: 30, color: Colors.white),
            Icon(Icons.bookmark_rounded, size: 30, color: Colors.white),
          ],
          color: const Color(0xFFa65f59),
          buttonBackgroundColor: const Color.fromARGB(255, 196, 110, 100),
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          onTap: _onNavBarTap,
        ),
      ),
    );
  }

  Widget _buildFeaturedBannerWithSearch() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Imagen de fondo desde assets
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
          // Overlay oscuro para mejorar legibilidad
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromARGB(255, 114, 35, 35).withOpacity(0.4),
                    const Color.fromARGB(255, 114, 35, 35).withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          // Contenido con título y búsqueda
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Discover Your Next Great Read',
                    style: TextStyle(
                      fontSize: 24,
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
            color: isDark 
              ? colorScheme.surface 
              : Colors.white,
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
                  ? 'No results found'
                  : 'Something went wrong',
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
                  ? 'No books found for "$currentSearchQuery"'
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
                      currentSearchQuery.isNotEmpty ? 'Clear search' : 'Retry',
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
            color: isDark 
              ? colorScheme.surface 
              : Colors.white,
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
                  size: 80,
                  color: const Color(0xFF9D6055).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                currentSearchQuery.isNotEmpty
                  ? 'No books found'
                  : selectedCategory != 'Todos'
                    ? 'No books in this category'
                    : 'No books available',
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
                  ? 'Try different search terms: "$currentSearchQuery"'
                  : selectedCategory != 'Todos'
                    ? 'No books found in "$selectedCategory" category'
                    : 'Books will appear here when available',
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.library_books_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'View all books',
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