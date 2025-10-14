import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Cache Manager personalizado CORRECTO - usa ImageCacheManager
class AvatarCacheManager {
  static const key = 'avatarCache';
  
  // Usar el CacheManager por defecto que SÍ soporta redimensionamiento
  static CacheManager get instance => CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 500,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}

class OptimizedCachedAvatar extends StatefulWidget {
  final String? photoUrl;
  final String fallbackText;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showDebug;

  const OptimizedCachedAvatar({
    Key? key,
    required this.photoUrl,
    required this.fallbackText,
    this.radius = 24,
    this.backgroundColor,
    this.textColor,
    this.showDebug = false,
  }) : super(key: key);

  @override
  State<OptimizedCachedAvatar> createState() => _OptimizedCachedAvatarState();
}

class _OptimizedCachedAvatarState extends State<OptimizedCachedAvatar> {
  @override
  Widget build(BuildContext context) {
    if (widget.showDebug) {
      print('🖼️ Avatar URL: ${widget.photoUrl}');
      print('📝 Fallback: ${widget.fallbackText}');
    }

    if (widget.photoUrl == null || 
        widget.photoUrl!.isEmpty || 
        !_isValidUrl(widget.photoUrl!)) {
      if (widget.showDebug) {
        print('❌ URL inválida o vacía');
      }
      return _buildFallbackAvatar();
    }

    return CachedNetworkImage(
      imageUrl: widget.photoUrl!,
      cacheManager: AvatarCacheManager.instance,
      imageBuilder: (context, imageProvider) {
        if (widget.showDebug) {
          print('✅ Imagen cargada: ${widget.photoUrl}');
        }
        return CircleAvatar(
          radius: widget.radius,
          backgroundImage: imageProvider,
          backgroundColor: Colors.transparent,
        );
      },
      placeholder: (context, url) {
        if (widget.showDebug) {
          print('⏳ Cargando imagen...');
        }
        return _buildLoadingAvatar();
      },
      errorWidget: (context, url, error) {
        if (widget.showDebug) {
          print('❌ Error: $error');
        }
        return _buildErrorAvatar();
      },
      // ⚡ SIN maxWidth/maxHeight - Deja que el cache manager lo maneje
      memCacheWidth: (widget.radius * 2 * 3).toInt(), // Solo memoria
      memCacheHeight: (widget.radius * 2 * 3).toInt(),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
      // Headers para evitar bloqueos CORS
      httpHeaders: const {
        'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)',
        'Accept': 'image/*',
      },
    );
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && 
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Widget _buildFallbackAvatar() {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor ?? Colors.grey[300],
      child: Text(
        widget.fallbackText.isNotEmpty 
            ? widget.fallbackText[0].toUpperCase() 
            : 'U',
        style: TextStyle(
          color: widget.textColor ?? Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: widget.radius * 0.75,
        ),
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor ?? Colors.grey[100],
      child: SizedBox(
        width: widget.radius * 0.6,
        height: widget.radius * 0.6,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.textColor?.withOpacity(0.5) ?? Colors.grey[400]!,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorAvatar() {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor ?? Colors.grey[300],
      child: Icon(
        Icons.person_rounded,
        size: widget.radius * 1.2,
        color: widget.textColor ?? Colors.grey[600],
      ),
    );
  }
}

// Preloader optimizado
class AvatarPreloader {
  static final Set<String> _preloadedUrls = {};

  static Future<void> preloadAvatars(List<String?> urls) async {
    final validUrls = urls
        .where((url) => 
            url != null && 
            url.isNotEmpty && 
            !_preloadedUrls.contains(url) &&
            _isValidUrl(url))
        .take(10) // Solo los primeros 10
        .toList();

    if (validUrls.isEmpty) return;

    // Carga en lotes pequeños
    for (final url in validUrls) {
      _preloadSingleAvatar(url!);
    }
  }

  static Future<void> _preloadSingleAvatar(String url) async {
    try {
      await AvatarCacheManager.instance.downloadFile(url);
      _preloadedUrls.add(url);
      print('✅ Precargado: $url');
    } catch (e) {
      print('⚠️ No se pudo precargar: $url');
    }
  }

  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && 
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static void clearCache() {
    _preloadedUrls.clear();
  }
}