import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header con imagen de biblioteca
              _buildLibraryHeader(),
              
              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barra de búsqueda
                    _buildSearchBar(),
                    
                    const SizedBox(height: 30),
                    
                    // Categorías rápidas
                    _buildQuickCategories(),
                    
                    const SizedBox(height: 30),
                    
                    // Lista de libros
                    _buildSectionTitle('Catálogo de Libros'),
                    const SizedBox(height: 16),
                    _buildBooksList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryHeader() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B4513).withOpacity(0.9),
            const Color(0xFF654321).withOpacity(0.9),
            const Color(0xFF4A2C2A).withOpacity(0.9),
          ],
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Patrón de biblioteca
          _buildLibraryPattern(),
          
          // Overlay con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
              ),
   
            ),
          ),
          
          // Contenido del header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.library_books,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Biblioteca Digital',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Descubre el conocimiento infinito',
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
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_stories,
                        color: Colors.white.withOpacity(0.9),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+10,000 libros disponibles',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryPattern() {
    return Stack(
      children: [
        // Estantes de libros simulados
        for (int i = 0; i < 4; i++)
          Positioned(
            top: 40.0 + (i * 30.0),
            left: 20 + (i * 15.0),
            right: 40 - (i * 10.0),
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  for (int j = 0; j < 8; j++)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: [
                            Colors.red.withOpacity(0.3),
                            Colors.blue.withOpacity(0.3),
                            Colors.green.withOpacity(0.3),
                            Colors.orange.withOpacity(0.3),
                            Colors.purple.withOpacity(0.3),
                          ][j % 5],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.grey[400],
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Buscar libros, autores, categorías...',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.tune,
              color: Color(0xFF8B4513),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCategories() {
    final categories = [
      {'name': 'Ficción', 'icon': Icons.auto_stories, 'color': const Color(0xFF6B73FF)},
      {'name': 'Historia', 'icon': Icons.history_edu, 'color': const Color(0xFF9C27B0)},
      {'name': 'Ciencia', 'icon': Icons.science, 'color': const Color(0xFF00BCD4)},
      {'name': 'Arte', 'icon': Icons.palette, 'color': const Color(0xFFFF7043)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explorar por Categoría',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C1810),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: categories.map((category) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (category['color'] as Color).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (category['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        color: category['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C1810),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C1810),
      ),
    );
  }

  Widget _buildBooksList() {
    final books = [
      {
        'title': 'Don Quijote de la Mancha',
        'author': 'Miguel de Cervantes',
        'year': '1605',
        'pages': '863',
        'category': 'Literatura Clásica',
        'color': const Color(0xFFD32F2F),
        'available': true,
      },
      {
        'title': 'Cien Años de Soledad',
        'author': 'Gabriel García Márquez',
        'year': '1967',
        'pages': '471',
        'category': 'Realismo Mágico',
        'color': const Color(0xFF388E3C),
        'available': true,
      },
      {
        'title': 'Rayuela',
        'author': 'Julio Cortázar',
        'year': '1963',
        'pages': '635',
        'category': 'Literatura Contemporánea',
        'color': const Color(0xFF1976D2),
        'available': false,
      },
      {
        'title': 'Pedro Páramo',
        'author': 'Juan Rulfo',
        'year': '1955',
        'pages': '124',
        'category': 'Literatura Mexicana',
        'color': const Color(0xFFE64A19),
        'available': true,
      },
      {
        'title': 'La Casa de los Espíritus',
        'author': 'Isabel Allende',
        'year': '1982',
        'pages': '433',
        'category': 'Ficción Histórica',
        'color': const Color(0xFF7B1FA2),
        'available': true,
      },
      {
        'title': 'El Amor en los Tiempos del Cólera',
        'author': 'Gabriel García Márquez',
        'year': '1985',
        'pages': '348',
        'category': 'Romance',
        'color': const Color(0xFFAD1457),
        'available': true,
      },
      {
        'title': 'Ficciones',
        'author': 'Jorge Luis Borges',
        'year': '1944',
        'pages': '174',
        'category': 'Cuentos',
        'color': const Color(0xFF00796B),
        'available': false,
      },
      {
        'title': 'La Ciudad y los Perros',
        'author': 'Mario Vargas Llosa',
        'year': '1963',
        'pages': '419',
        'category': 'Literatura Peruana',
        'color': const Color(0xFFF57C00),
        'available': true,
      },
    ];

    return Column(
      children: books.map((book) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Portada del libro
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: book['color'] as Color,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: (book['color'] as Color).withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Textura del libro
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    // Línea del lomo
                    Positioned(
                      left: 6,
                      top: 8,
                      bottom: 8,
                      child: Container(
                        width: 1.5,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    // Ícono central
                    const Center(
                      child: Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Información del libro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1810),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book['author'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildBookInfo(Icons.calendar_today, book['year'] as String),
                        const SizedBox(width: 16),
                        _buildBookInfo(Icons.description, '${book['pages']} pág.'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (book['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        book['category'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: book['color'] as Color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Estado y acciones
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (book['available'] as bool) 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (book['available'] as bool) 
                            ? Icons.check_circle 
                            : Icons.schedule,
                          size: 14,
                          color: (book['available'] as bool) 
                            ? Colors.green[600]
                            : Colors.orange[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (book['available'] as bool) ? 'Disponible' : 'Prestado',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: (book['available'] as bool) 
                              ? Colors.green[600]
                              : Colors.orange[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4513).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      (book['available'] as bool) 
                        ? Icons.bookmark_add
                        : Icons.schedule,
                      color: const Color(0xFF8B4513),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBookInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// Clase principal para ejecutar la app
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca Digital',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'SF Pro Display',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LibraryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(const MyApp());
}