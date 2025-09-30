import 'package:flutter/material.dart';
import 'package:my_app/library/domain/entities/book_entity.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class BookCardWidget extends StatelessWidget {
  final BookEntity book;
  final VoidCallback onTap;

  const BookCardWidget({
    Key? key,
    required this.book,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildBookCover(),
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Book title
          Text(
            book.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // Author
          Text(
            book.author,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBookCover() {
    // Prioridad 1: Si hay coverUrl, usar imagen normal
    if (book.coverUrl.isNotEmpty) {
      return Image.network(
        book.coverUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          // Si falla la imagen y hay PDF, renderizar primera página
          if (book.pdfUrl.isNotEmpty) {
            return _PdfThumbnail(
              pdfUrl: book.pdfUrl,
              bookTitle: book.title,
            );
          }
          return _buildFallbackCover();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingCover();
        },
      );
    }
    
    // Prioridad 2: Si no hay coverUrl pero hay PDF
    if (book.pdfUrl.isNotEmpty) {
      return _PdfThumbnail(
        pdfUrl: book.pdfUrl,
        bookTitle: book.title,
      );
    }
    
    // Prioridad 3: Fallback con gradiente
    return _buildFallbackCover();
  }

  Widget _buildLoadingCover() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6C63FF),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildFallbackCover() {
    final colors = _getGradientColors(book.title);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.menu_book,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  List<Color> _getGradientColors(String title) {
    final hash = title.hashCode.abs();
    final gradients = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFF2193b0), const Color(0xFF6dd5ed)],
      [const Color(0xFFee0979), const Color(0xFFff6a00)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
      [const Color(0xFF30cfd0), const Color(0xFF330867)],
      [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
      [const Color(0xFFff9a9e), const Color(0xFFfecfef)],
      [const Color(0xFF6a11cb), const Color(0xFF2575fc)],
      [const Color(0xFFf12711), const Color(0xFFf5af19)],
    ];
    
    return gradients[hash % gradients.length];
  }
}

// Widget interno para renderizar la primera página del PDF
class _PdfThumbnail extends StatefulWidget {
  final String pdfUrl;
  final String bookTitle;

  const _PdfThumbnail({
    required this.pdfUrl,
    required this.bookTitle,
  });

  @override
  State<_PdfThumbnail> createState() => _PdfThumbnailState();
}

class _PdfThumbnailState extends State<_PdfThumbnail> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPdfThumbnail();
  }

  Future<void> _loadPdfThumbnail() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Descargar PDF
      final response = await http.get(Uri.parse(widget.pdfUrl));
      
      if (response.statusCode != 200) {
        throw Exception('Error al descargar PDF: ${response.statusCode}');
      }

      final pdfData = response.bodyBytes;

      // Abrir documento PDF
      final doc = await PdfDocument.openData(pdfData);

      // Obtener primera página
      final page = await doc.getPage(1);

      // Renderizar como imagen
      final pageImage = await page.render(
        width: (page.width * 2.0).toInt(),
        height: (page.height * 2.0).toInt(),
      );

      final imageBytes = await pageImage?.createImageIfNotAvailable();

      // Cerrar documento
      doc.dispose();

      if (mounted && imageBytes != null) {
        setState(() {
          _thumbnailBytes = imageBytes;
          _isLoading = false;
        });
      } else {
        throw Exception('No se pudo generar la imagen');
      }
    } catch (e) {
      print('Error al generar thumbnail del PDF: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF6C63FF),
                strokeWidth: 2,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Cargando portada...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError || _thumbnailBytes == null) {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.picture_as_pdf,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.bookTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Image.memory(
      _thumbnailBytes!,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }
}