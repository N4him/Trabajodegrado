import 'package:flutter/material.dart';
import 'package:my_app/core/di/injector.dart';
import 'package:my_app/library/domain/entities/book_entity.dart';
import 'package:my_app/library/domain/usescases/get_book_by_id.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BookDetailPage extends StatefulWidget {
  final String bookId;

  // ignore: use_super_parameters
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
    final colorScheme = Theme.of(context).colorScheme; // 👈 CAMBIO 1
    
    return Scaffold(
      backgroundColor: colorScheme.background, // 👈 CAMBIO 2 (era Color(0xFFF8F9FA))
      appBar: _buildAppBar(),
      body: FutureBuilder<BookEntity?>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando libro...',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface.withOpacity(0.7), // 👈 CAMBIO 3
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
                      color: colorScheme.onSurface, // 👈 CAMBIO 4
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error?.toString() ?? 'Error desconocido',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6), // 👈 CAMBIO 5
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _loadBook()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
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
                    color: colorScheme.onSurface.withOpacity(0.3), // 👈 CAMBIO 6
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PDF no disponible',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface, // 👈 CAMBIO 7
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildBookHeader(book),
                _buildPdfViewer(book),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final colorScheme = Theme.of(context).colorScheme; // 👈 CAMBIO 8
    final isDark = Theme.of(context).brightness == Brightness.dark; // 👈 CAMBIO 9
    
    return AppBar(
      backgroundColor: colorScheme.surface, // 👈 CAMBIO 10 (era Colors.white)
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark // 👈 CAMBIO 11
                  ? colorScheme.surface.withOpacity(0.5)
                  : const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: colorScheme.onSurface, // 👈 CAMBIO 12
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surface.withOpacity(0.5)
                    : const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(10),
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
    final colorScheme = Theme.of(context).colorScheme; // 👈 CAMBIO 13
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface, // 👈 CAMBIO 14 (era Colors.white)
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
    final colorScheme = Theme.of(context).colorScheme; // 👈 CAMBIO 15
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark // 👈 CAMBIO 16
              ? colorScheme.surface.withOpacity(0.5)
              : const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface, // 👈 CAMBIO 17
        ),
      ),
      onTap: onTap,
    );
  }

  void _showJumpToPageDialog() {
    final colorScheme = Theme.of(context).colorScheme; // 👈 CAMBIO 18
    final TextEditingController pageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface, // 👈 CAMBIO 19
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Ir a página',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface, // 👈 CAMBIO 20
          ),
        ),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: colorScheme.onSurface), // 👈 CAMBIO 21
          decoration: InputDecoration(
            hintText: 'Número de página',
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5), // 👈 CAMBIO 22
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6), // 👈 CAMBIO 23
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
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ir'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookHeader(BookEntity book) {
    final colorScheme = Theme.of(context).colorScheme; // 👈 CAMBIO 24
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: colorScheme.surface, // 👈 CAMBIO 25 (era Colors.white)
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          // Book cover with shadow
          Container(
            width: 180,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark // 👈 CAMBIO 26
                      ? Colors.black.withOpacity(0.5)
                      : const Color(0xFF6C63FF).withOpacity(0.2),
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
                                const Color(0xFF6C63FF),
                                const Color(0xFF4834DF),
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
                            const Color(0xFF6C63FF),
                            const Color(0xFF4834DF),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.menu_book, color: Colors.white, size: 64),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          // Book title
          Text(
            book.title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface, // 👈 CAMBIO 27 (era Color(0xFF1A202C))
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Author
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.6), // 👈 CAMBIO 28
              ),
              const SizedBox(width: 6),
              Text(
                book.author,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface.withOpacity(0.6), // 👈 CAMBIO 29
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6C63FF).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              book.category,
              style: const TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Description section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Descripción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface, // 👈 CAMBIO 30
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            book.description.isNotEmpty 
                ? book.description 
                : 'Explora este fascinante libro y sumérgete en su contenido. Una obra imprescindible que te transportará a través de sus páginas con historias cautivadoras y conocimientos valiosos.',
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurface.withOpacity(0.7), // 👈 CAMBIO 31
              height: 1.6,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer(BookEntity book) {
    final colorScheme = Theme.of(context).colorScheme; // 👈 CAMBIO 32
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 500,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface, // 👈 CAMBIO 33
        boxShadow: [
          BoxShadow(
            color: isDark // 👈 CAMBIO 34
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
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
              color: colorScheme.surface, // 👈 CAMBIO 35
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando PDF...',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withOpacity(0.7), // 👈 CAMBIO 36
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_pdfError != null)
            Container(
              color: colorScheme.surface, // 👈 CAMBIO 37
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
                        color: colorScheme.onSurface, // 👈 CAMBIO 38
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _pdfError!,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6), // 👈 CAMBIO 39
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
                        backgroundColor: const Color(0xFF6C63FF),
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