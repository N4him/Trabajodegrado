import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/core/di/injector.dart';
import 'package:my_app/library/presentation/blocs/library_bloc.dart';
import 'package:my_app/library/presentation/blocs/library_event.dart';
import 'package:my_app/library/presentation/blocs/library_state.dart';

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BlocProvider<LibraryBloc>.value(
      value: _libraryBloc,
      child: Scaffold(
        backgroundColor: colorScheme.background,
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildEnhancedHeader(),
              ),

              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (currentSearchQuery.isEmpty)
                            CategoryChipWidget(
                              selectedCategory: selectedCategory,
                              onCategoryChanged: _handleCategoryChange,
                            ),
                          if (currentSearchQuery.isEmpty) const SizedBox(height: 24),
                          _buildSectionHeader(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: BlocConsumer<LibraryBloc, LibraryState>(
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
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(60.0),
                            child: Column(
                              children: [
                                const CircularProgressIndicator(
                                  color: Color(0xFF5E35B1),
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
                        ),
                      );
                    } else if (state is LibraryLoaded) {
                      if (state.books.isEmpty) {
                        return _buildEmptyState();
                      }

                      return SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final book = state.books[index];
                            return BookCardWidget(
                              key: Key('book_${book.id}'),
                              book: book,
                              onTap: () => _navigateToBookDetail(context, book.id),
                            );
                          },
                          childCount: state.books.length,
                        ),
                      );
                    } else if (state is LibraryError) {
                      return _buildErrorState(state.message);
                    }
                    
                    return const SliverToBoxAdapter(child: SizedBox());
                  },
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SliverToBoxAdapter(
      child: Center(
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
                    backgroundColor: const Color(0xFF5E35B1),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SliverToBoxAdapter(
      child: Center(
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
                    color: const Color(0xFF5E35B1).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    currentSearchQuery.isNotEmpty 
                      ? Icons.search_off_rounded
                      : Icons.auto_stories_rounded,
                    size: 80,
                    color: const Color(0xFF5E35B1).withOpacity(0.7),
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
                      backgroundColor: const Color(0xFF5E35B1),
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
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [
                const Color(0xFF1A237E).withOpacity(0.95),
                const Color(0xFF3949AB).withOpacity(0.95),
                const Color(0xFF5E35B1).withOpacity(0.95),
              ]
            : [
                const Color(0xFF1A237E),
                const Color(0xFF3949AB),
                const Color(0xFF5E35B1),
              ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : const Color(0xFF5E35B1).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'library_icon',
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Digital Library',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentSearchQuery.isNotEmpty
                        ? 'Searching: "$currentSearchQuery"'
                        : selectedCategory != 'Todos'
                          ? 'Category: $selectedCategory'
                          : 'Explore infinite worlds of knowledge',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: SearchBarWidget(
              onSearch: _handleSearch,
              onClear: _clearSearch,
              initialValue: currentSearchQuery,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentSearchQuery.isNotEmpty
                  ? 'Search Results'
                  : selectedCategory != 'Todos'
                    ? selectedCategory
                    : 'Book Catalog',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              if (currentSearchQuery.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'for "$currentSearchQuery"',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF5E35B1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF5E35B1).withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.sort_rounded,
                size: 18,
                color: Color(0xFF5E35B1),
              ),
              SizedBox(width: 6),
              Text(
                'Sort',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5E35B1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToBookDetail(BuildContext context, String bookId) {
    Navigator.pushNamed(
      context,
      '/book-detail',
      arguments: bookId,
    );
  }
}