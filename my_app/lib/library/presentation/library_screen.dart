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
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _fadeAnimation;
  late LibraryBloc _libraryBloc; // Mantener referencia al bloc

  final ScrollController _scrollController = ScrollController();
  String selectedCategory = 'Todos';
  String currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    
    // Inicializar el bloc UNA SOLA VEZ
    _libraryBloc = getIt<LibraryBloc>();
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeAnimationController.forward();
    });

    // Cargar libros iniciales
    _libraryBloc.add(GetBooksEvent());
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _fadeAnimationController.dispose();
    _scrollController.dispose();
    _libraryBloc.close(); // Cerrar el bloc
    super.dispose();
  }

  // Search handler mejorado
  void _handleSearch(String query) {
    print("🔍 UI: Iniciando búsqueda con query: '$query'");
    
    setState(() {
      currentSearchQuery = query.trim();
      // Reset category when searching
      if (query.trim().isNotEmpty) {
        selectedCategory = 'Todos';
      }
    });

    if (query.trim().isEmpty) {
      print("🔍 UI: Query vacía, obteniendo todos los libros");
      _libraryBloc.add(GetBooksEvent());
    } else {
      print("🔍 UI: Enviando SearchBooksEvent al BLoC");
      _libraryBloc.add(SearchBooksEvent(query.trim()));
    }
  }

  // Category change handler
  void _handleCategoryChange(String category) {
    print("📂 UI: Cambiando a categoría: $category");
    setState(() {
      selectedCategory = category;
      // Clear search when filtering by category
      currentSearchQuery = '';
    });

    if (category == 'Todos') {
      _libraryBloc.add(GetBooksEvent());
    } else {
      _libraryBloc.add(GetBooksByCategoryEvent(category));
    }
  }

  // Clear search handler
  void _clearSearch() {
    print("🧹 UI: Limpiando búsqueda");
    setState(() {
      currentSearchQuery = '';
      selectedCategory = 'Todos';
    });
    _libraryBloc.add(GetBooksEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LibraryBloc>.value(
      value: _libraryBloc, // Usar el bloc existente en lugar de crear uno nuevo
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header with Search Bar
              SliverToBoxAdapter(
                child: _buildEnhancedHeader(),
              ),

              // Content with fade animation
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Only show category chips if not searching
                        if (currentSearchQuery.isEmpty)
                          CategoryChipWidget(
                            selectedCategory: selectedCategory,
                            onCategoryChanged: _handleCategoryChange,
                          ),
                        if (currentSearchQuery.isEmpty) const SizedBox(height: 30),
                        _buildSectionHeader(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Books Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: BlocConsumer<LibraryBloc, LibraryState>(
                  listener: (context, state) {
                    // Debug listener to track state changes
                    print("🔄 Estado cambiado a: ${state.runtimeType}");
                    if (state is LibraryLoaded) {
                      print("📚 Libros en UI: ${state.books.length}");
                      for (var book in state.books) {
                        print("  - ${book.title}");
                      }
                    } else if (state is LibraryError) {
                      print("❌ Error en UI: ${state.message}");
                    }
                  },
                  builder: (context, state) {
                    print("🎨 Construyendo UI con estado: ${state.runtimeType}");
                    
                    if (state is LibraryLoading) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF5E35B1),
                            ),
                          ),
                        ),
                      );
                    } else if (state is LibraryLoaded) {
                      print("✅ Renderizando ${state.books.length} libros en UI");
                      
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
                            print("📖 Renderizando card: ${book.title}");
                            return BookCardWidget(
                              key: Key('book_${book.id}'), // Key más específica
                              book: book,
                              onTap: () => _navigateToBookDetail(context, book.id),
                            );
                          },
                          childCount: state.books.length,
                        ),
                      );
                    } else if (state is LibraryError) {
                      print("❌ Mostrando error: ${state.message}");
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  currentSearchQuery.isNotEmpty 
                                    ? Icons.search_off 
                                    : Icons.error_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  currentSearchQuery.isNotEmpty
                                    ? 'No se encontraron libros para "$currentSearchQuery"'
                                    : state.message,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
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
                                  ),
                                  child: Text(
                                    currentSearchQuery.isNotEmpty ? 'Limpiar búsqueda' : 'Reintentar'
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    
                    print("⚠️ Estado no manejado: ${state.runtimeType}");
                    return const SliverToBoxAdapter(child: SizedBox());
                  },
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(
                currentSearchQuery.isNotEmpty 
                  ? Icons.search_off_rounded
                  : Icons.library_books_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                currentSearchQuery.isNotEmpty
                  ? 'No se encontraron libros'
                  : selectedCategory != 'Todos'
                    ? 'No hay libros en la categoría "$selectedCategory"'
                    : 'No hay libros disponibles',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                currentSearchQuery.isNotEmpty
                  ? 'Intenta con otros términos: "${currentSearchQuery}"'
                  : 'Los libros aparecerán aquí cuando estén disponibles',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              if (currentSearchQuery.isNotEmpty) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _clearSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Ver todos los libros'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A237E),
            Color(0xFF3949AB),
            Color(0xFF5E35B1),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E35B1).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'library_icon',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_stories,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Biblioteca Digital',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentSearchQuery.isNotEmpty
                          ? 'Buscando: "$currentSearchQuery"'
                          : selectedCategory != 'Todos'
                            ? 'Categoría: $selectedCategory'
                            : 'Descubre mundos infinitos de conocimiento',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Search bar within header
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: SearchBarWidget(
                onSearch: _handleSearch,
                onClear: _clearSearch,
                initialValue: currentSearchQuery, // Pasar el valor actual
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            currentSearchQuery.isNotEmpty
              ? 'Resultados para "$currentSearchQuery"'
              : selectedCategory != 'Todos'
                ? 'Libros de $selectedCategory'
                : 'Catálogo de Libros',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C1810),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF5E35B1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sort,
                size: 16,
                color: const Color(0xFF5E35B1),
              ),
              const SizedBox(width: 6),
              Text(
                'Ordenar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5E35B1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToBookDetail(BuildContext context, String bookId) {
    print("🚀 Navegando al detalle del libro con ID: $bookId");
    Navigator.pushNamed(
      context,
      '/book-detail',
      arguments: bookId,
    );
  }
}