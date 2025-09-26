import 'package:flutter/material.dart';

class ForumsScreen extends StatefulWidget {
  const ForumsScreen({Key? key}) : super(key: key);

  @override
  State<ForumsScreen> createState() => _ForumsScreenState();
}

class _ForumsScreenState extends State<ForumsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int selectedCategoryIndex = 0;

  final categories = [
    {'name': 'Todos', 'icon': Icons.forum, 'color': const Color(0xFF6366F1)},
    {'name': 'General', 'icon': Icons.chat_bubble_outline, 'color': const Color(0xFF10B981)},
    {'name': 'Ayuda', 'icon': Icons.help_outline, 'color': const Color(0xFFF59E0B)},
    {'name': 'Anuncios', 'icon': Icons.campaign, 'color': const Color(0xFFEF4444)},
    {'name': 'Desarrollo', 'icon': Icons.code, 'color': const Color(0xFF8B5CF6)},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildSearchAndFilters(),
            _buildCategories(),
            _buildTabBar(),
            _buildForumsList(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
              const Color(0xFFA855F7),
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Foros Comunitarios',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Conecta, comparte y aprende',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.forum,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildStatChip('2,547', 'Miembros activos'),
                const SizedBox(width: 16),
                _buildStatChip('156', 'Temas hoy'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String number, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.grey[400],
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Buscar temas o publicaciones...',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.filter_list,
                color: const Color(0xFF6366F1),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategoryIndex == index;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategoryIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? category['color'] as Color : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                        ? (category['color'] as Color).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                      blurRadius: isSelected ? 10 : 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: isSelected ? Colors.white : category['color'] as Color,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: Colors.grey[600],
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Trending'),
            Tab(text: 'Recientes'),
          ],
        ),
      ),
    );
  }

  Widget _buildForumsList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _buildForumCard(_getForumPosts()[index], index);
          },
          childCount: _getForumPosts().length,
        ),
      ),
    );
  }

  Widget _buildForumCard(Map<String, dynamic> post, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: post['userColor'] as Color,
                child: Text(
                  (post['author'] as String)[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['author'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      post['time'] as String,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (post['categoryColor'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  post['category'] as String,
                  style: TextStyle(
                    color: post['categoryColor'] as Color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            post['title'] as String,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post['content'] as String,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionButton(
                Icons.thumb_up_outlined,
                post['likes'].toString(),
                const Color(0xFF10B981),
              ),
              const SizedBox(width: 20),
              _buildActionButton(
                Icons.chat_bubble_outline,
                post['replies'].toString(),
                const Color(0xFF6366F1),
              ),
              const SizedBox(width: 20),
              _buildActionButton(
                Icons.visibility_outlined,
                post['views'].toString(),
                Colors.grey[600]!,
              ),
              const Spacer(),
              if (post['isPinned'] == true)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.push_pin,
                    size: 16,
                    color: Color(0xFFF59E0B),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {},
      backgroundColor: const Color(0xFF6366F1),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Nuevo Tema',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getForumPosts() {
    return [
      {
        'author': 'María González',
        'userColor': const Color(0xFF8B5CF6),
        'time': 'hace 2 horas',
        'category': 'General',
        'categoryColor': const Color(0xFF10B981),
        'title': '¿Cuáles son las mejores prácticas para principiantes?',
        'content': 'Hola comunidad, soy nueva en este mundo y me gustaría conocer las mejores prácticas que recomiendan para alguien que está empezando. He estado leyendo documentación pero me gustaría escuchar experiencias reales...',
        'likes': 24,
        'replies': 8,
        'views': 156,
        'isPinned': false,
      },
      {
        'author': 'Carlos Rodríguez',
        'userColor': const Color(0xFFEF4444),
        'time': 'hace 4 horas',
        'category': 'Anuncios',
        'categoryColor': const Color(0xFFEF4444),
        'title': 'Actualizaciones importantes de la plataforma v2.1',
        'content': 'Queridos usuarios, nos complace anunciar las nuevas funcionalidades que estarán disponibles en la versión 2.1. Esta actualización incluye mejoras significativas en rendimiento, nuevas herramientas...',
        'likes': 42,
        'replies': 15,
        'views': 287,
        'isPinned': true,
      },
      {
        'author': 'Ana Martínez',
        'userColor': const Color(0xFF06B6D4),
        'time': 'hace 6 horas',
        'category': 'Ayuda',
        'categoryColor': const Color(0xFFF59E0B),
        'title': 'Error al conectar con la API - ¿Alguien más tiene este problema?',
        'content': 'Desde ayer estoy teniendo problemas para conectarme con la API principal. El error que me aparece es timeout connection. ¿Alguien más está experimentando esto? He probado diferentes métodos...',
        'likes': 18,
        'replies': 12,
        'views': 98,
        'isPinned': false,
      },
      {
        'author': 'Diego López',
        'userColor': const Color(0xFF10B981),
        'time': 'hace 8 horas',
        'category': 'Desarrollo',
        'categoryColor': const Color(0xFF8B5CF6),
        'title': 'Compartiendo mi proyecto: Gestor de tareas con Flutter',
        'content': 'Hola a todos, después de varios meses de trabajo quiero compartir con la comunidad mi último proyecto. Es un gestor de tareas desarrollado completamente en Flutter con una arquitectura limpia...',
        'likes': 35,
        'replies': 22,
        'views': 234,
        'isPinned': false,
      },
      {
        'author': 'Lucia Herrera',
        'userColor': const Color(0xFFF59E0B),
        'time': 'hace 12 horas',
        'category': 'General',
        'categoryColor': const Color(0xFF10B981),
        'title': 'Recursos gratuitos para aprender programación',
        'content': 'He recopilado una lista de recursos completamente gratuitos para aprender programación desde cero. Incluye cursos, tutoriales, libros y proyectos prácticos que pueden ser de gran ayuda...',
        'likes': 67,
        'replies': 31,
        'views': 445,
        'isPinned': false,
      },
      {
        'author': 'Roberto Silva',
        'userColor': const Color(0xFF7C3AED),
        'time': 'hace 1 día',
        'category': 'Desarrollo',
        'categoryColor': const Color(0xFF8B5CF6),
        'title': 'Optimización de rendimiento en aplicaciones móviles',
        'content': 'Quiero iniciar una discusión sobre las técnicas más efectivas para optimizar el rendimiento en aplicaciones móviles. He estado experimentando con diferentes enfoques y me gustaría compartir...',
        'likes': 29,
        'replies': 18,
        'views': 189,
        'isPinned': false,
      },
    ];
  }
}

// Clase principal para ejecutar la app
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foros Comunitarios',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'SF Pro Display',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ForumsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(const MyApp());
}