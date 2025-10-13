import 'package:flutter/material.dart';
import 'package:my_app/core/di/injector.dart';
import 'package:my_app/library/domain/entities/book_entity.dart';
import 'package:my_app/library/domain/usescases/get_book_by_id.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BookDetailPage extends StatefulWidget {
  final String bookId;

  const BookDetailPage({Key? key, required this.bookId}) : super(key: key);

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Future<BookEntity?> _bookFuture;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  PdfViewerController? _pdfViewerController;
  bool _isPdfLoading = true;
  String? _pdfError;
  bool _showBookInfo = true;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadBook();
  }

  @override
  void dispose() {
    _pdfViewerController?.dispose();
    super.dispose();
  }

  void _loadBook() {
    _bookFuture = _fetchBook();
  }

  Future<BookEntity?> _fetchBook() async {
    try {
      final getBookById = getIt<GetBookById>();
      final result = await getBookById(widget.bookId);
      return result.fold(
        (failure) {
          return null;
        },
        (book) {
          return book;
        },
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(),
      body: FutureBuilder<BookEntity?>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: const Color.fromARGB(255, 160, 93, 85)),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando libro...',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Color(0xFFE53E3E)),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar el libro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error?.toString() ?? 'Error desconocido',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _loadBook()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 160, 93, 85),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final book = snapshot.data!;
          
          if (book.pdfUrl.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 64,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PDF no disponible',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              Column(
                children: [
                  // Header del libro - Se muestra/oculta con animación
                  if (_showBookInfo)
                    Expanded(
                      child: _buildBookHeader(book, context),
                    ),
                  
                  // PDF Viewer - Ocupa el espacio restante automáticamente
                  if (!_showBookInfo)
                    Expanded(
                      child: _buildPdfViewer(book),
                    ),
                ],
              ),
              
              // Botón flotante para mostrar/ocultar info
              Positioned(
                bottom: 24,
                right: 24,
                child: _buildToggleInfoButton(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToggleInfoButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showBookInfo = !_showBookInfo;
        });
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 160, 93, 85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 160, 93, 85).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _showBookInfo ? Icons.menu_book : Icons.info_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left:5,),
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surface.withOpacity(0.5)
                  : const Color.fromARGB(255, 160, 93, 85),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: colorScheme.onSurface,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 5),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surface.withOpacity(0.5)
                    : const Color.fromARGB(255, 160, 93, 85),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.more_horiz,
                color: colorScheme.onSurface,
                size: 20,
              ),
            ),
            onPressed: () => _showOptionsMenu(),
          ),
        ),
      ],
    );
  }

  void _showOptionsMenu() {
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionItem(Icons.zoom_in, 'Aumentar zoom', () {
              Navigator.pop(context);
              _pdfViewerController?.zoomLevel = (_pdfViewerController?.zoomLevel ?? 1.0) * 1.25;
            }),
            _buildOptionItem(Icons.zoom_out, 'Disminuir zoom', () {
              Navigator.pop(context);
              _pdfViewerController?.zoomLevel = (_pdfViewerController?.zoomLevel ?? 1.0) * 0.8;
            }),
            _buildOptionItem(Icons.first_page, 'Primera página', () {
              Navigator.pop(context);
              _pdfViewerController?.jumpToPage(1);
            }),
            _buildOptionItem(Icons.navigate_next, 'Ir a página', () {
              Navigator.pop(context);
              _showJumpToPageDialog();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surface.withOpacity(0.5)
              : const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color.fromARGB(255, 160, 93, 85), size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showJumpToPageDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final TextEditingController pageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Ir a página',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Número de página',
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: const Color.fromARGB(255, 160, 93, 85), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final pageNumber = int.tryParse(pageController.text);
              if (pageNumber != null && pageNumber > 0) {
                _pdfViewerController?.jumpToPage(pageNumber);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 160, 93, 85),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ir'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookHeader(BookEntity book, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      color: colorScheme.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            // Portada del libro
            Container(
              width: 220,
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.5)
                        : const Color.fromARGB(255, 160, 93, 85).withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: book.coverUrl.isNotEmpty
                    ? Image.network(
                        book.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color.fromARGB(255, 160, 93, 85),
                                  const Color.fromARGB(255, 160, 93, 85),
                                ],
                              ),
                            ),
                            child: const Icon(Icons.menu_book, color: Colors.white, size: 64),
                          );
                        },
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color.fromARGB(255, 160, 93, 85),
                              const Color.fromARGB(255, 160, 93, 85),
                            ],
                          ),
                        ),
                        child: const Icon(Icons.menu_book, color: Colors.white, size: 64),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Título
            Text(
              book.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Autor
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: const  Color.fromARGB(255, 160, 93, 85).withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              book.description.isNotEmpty 
                  ? book.description 
                  : 'Explora este fascinante libro y sumérgete en su contenido. Una obra imprescindible que te transportará a través de sus páginas con historias cautivadoras y conocimientos valiosos.',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.6,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.left,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer(BookEntity book) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        children: [
          SfPdfViewer.network(
            book.pdfUrl,
            key: _pdfViewerKey,
            controller: _pdfViewerController,
            enableTextSelection: true,
            enableDoubleTapZooming: true,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            canShowPaginationDialog: true,
            canShowPasswordDialog: true,
            enableDocumentLinkAnnotation: true,
            canShowHyperlinkDialog: true,
            onDocumentLoaded: (details) {
              setState(() {
                _isPdfLoading = false;
                _pdfError = null;
              });
            },
            onDocumentLoadFailed: (details) {
              setState(() {
                _isPdfLoading = false;
                _pdfError = details.error;
              });
            },
          ),
          if (_isPdfLoading)
            Container(
              color: colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: const Color.fromARGB(255, 160, 93, 85)),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando PDF...',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_pdfError != null)
            Container(
              color: colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Color(0xFFE53E3E)),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar PDF',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _pdfError!,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
ElevatedButton(
  onPressed: () {
    setState(() {
      _isPdfLoading = true;
      _pdfError = null;
    });
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 160, 93, 85),
    foregroundColor: Colors.white, // Color del texto
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: const Text('Reintentar'),
),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}