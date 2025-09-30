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
      print("🔍 Cargando libro con ID: ${widget.bookId}");
      final getBookById = getIt<GetBookById>();
      final result = await getBookById(widget.bookId);
      return result.fold(
        (failure) {
          print("❌ Error al cargar libro: ${failure.message}");
          return null;
        },
        (book) {
          print("✅ Libro cargado: ${book.title}");
          print("📄 PDF URL: ${book.pdfUrl}");
          return book;
        },
      );
    } catch (e) {
      print("💥 Excepción al cargar libro: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: FutureBuilder<BookEntity?>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  SizedBox(height: 16),
                  Text(
                    'Cargando libro...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A5568),
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
                  const Text(
                    'Error al cargar el libro',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error?.toString() ?? 'Error desconocido',
                    style: const TextStyle(color: Color(0xFF718096)),
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, size: 64, color: Color(0xFFCBD5E0)),
                  SizedBox(height: 16),
                  Text(
                    'PDF no disponible',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3748), size: 18),
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
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.more_horiz, color: Color(0xFF2D3748), size: 20),
            ),
            onPressed: () => _showOptionsMenu(),
          ),
        ),
      ],
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3748),
        ),
      ),
      onTap: onTap,
    );
  }

  void _showJumpToPageDialog() {
    final TextEditingController pageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Ir a página',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Número de página',
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
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF718096))),
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
    return Container(
      color: Colors.white,
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
                  color: const Color(0xFF6C63FF).withOpacity(0.2),
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
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Author
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 16, color: Color(0xFF718096)),
              const SizedBox(width: 6),
              Text(
                book.author,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
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
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Descripción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            book.description.isNotEmpty 
                ? book.description 
                : 'Explora este fascinante libro y sumérgete en su contenido. Una obra imprescindible que te transportará a través de sus páginas con historias cautivadoras y conocimientos valiosos.',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF4A5568),
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
    return Container(
      height: 500,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
              print("✅ PDF cargado exitosamente. Páginas: ${details.document.pages.count}");
            },
            onDocumentLoadFailed: (details) {
              setState(() {
                _isPdfLoading = false;
                _pdfError = details.error;
              });
              print("❌ Error al cargar PDF: ${details.error}");
            },
          ),
          if (_isPdfLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    SizedBox(height: 16),
                    Text(
                      'Cargando PDF...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_pdfError != null)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Color(0xFFE53E3E)),
                    const SizedBox(height: 16),
                    const Text(
                      'Error al cargar PDF',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _pdfError!,
                        style: const TextStyle(color: Color(0xFF718096)),
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