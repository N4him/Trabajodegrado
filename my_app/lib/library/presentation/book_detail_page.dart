import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: FutureBuilder<BookEntity?>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Cargando libro...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al cargar el libro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error?.toString() ?? 'Error desconocido',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadBook();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E35B1),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final book = snapshot.data!;
          
          // Validate PDF URL
          if (book.pdfUrl.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    size: 64,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PDF no disponible',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Este libro no tiene un archivo PDF asociado',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildBookInfo(book),
              Expanded(
                child: _buildPdfViewer(book),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPdfViewer(BookEntity book) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al cargar el PDF: ${details.error}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              },
              onPageChanged: (details) {
                print("📖 Página cambiada a: ${details.newPageNumber}");
              },
            ),
            // Loading overlay
            if (_isPdfLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Cargando PDF...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Error overlay
            if (_pdfError != null)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error al cargar PDF',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _pdfError!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
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
                          // Force reload
                          _pdfViewerController?.clearSelection();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Visor de PDF',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        FutureBuilder<BookEntity?>(
          future: _bookFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              color: Colors.grey[900],
              onSelected: (value) {
                _handleMenuAction(value);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'zoom_in',
                  child: Row(
                    children: [
                      Icon(Icons.zoom_in, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Aumentar zoom', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'zoom_out',
                  child: Row(
                    children: [
                      Icon(Icons.zoom_out, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Disminuir zoom', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'first_page',
                  child: Row(
                    children: [
                      Icon(Icons.first_page, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Primera página', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'jump_to_page',
                  child: Row(
                    children: [
                      Icon(Icons.navigate_next, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Ir a página', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'zoom_in':
        _pdfViewerController?.zoomLevel = (_pdfViewerController?.zoomLevel ?? 1.0) * 1.25;
        break;
      case 'zoom_out':
        _pdfViewerController?.zoomLevel = (_pdfViewerController?.zoomLevel ?? 1.0) * 0.8;
        break;
      case 'first_page':
        _pdfViewerController?.jumpToPage(1);
        break;
      case 'jump_to_page':
        _showJumpToPageDialog();
        break;
    }
  }

  void _showJumpToPageDialog() {
    final TextEditingController pageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ir a página'),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Número de página',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final pageNumber = int.tryParse(pageController.text);
              if (pageNumber != null && pageNumber > 0) {
                _pdfViewerController?.jumpToPage(pageNumber);
                Navigator.pop(context);
              }
            },
            child: const Text('Ir'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookInfo(BookEntity book) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Book cover
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
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
                          color: const Color(0xFF5E35B1),
                          child: const Icon(
                            Icons.menu_book,
                            color: Colors.white,
                            size: 24,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: const Color(0xFF5E35B1),
                      child: const Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Book info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E35B1).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        book.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${book.pages} páginas',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}