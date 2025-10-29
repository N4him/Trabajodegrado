import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:my_app/services/image_storage_service.dart';

class ProfileAvatarWidget extends StatefulWidget {
  final String? photoUrl;
  final double radius;
  
  const ProfileAvatarWidget({
    super.key, 
    this.photoUrl,
    this.radius = 40,
  });

  @override
  State<ProfileAvatarWidget> createState() => _ProfileAvatarWidgetState();
}

class _ProfileAvatarWidgetState extends State<ProfileAvatarWidget> {
  final ImageStorageService _storageService = ImageStorageService();
  Uint8List? _cachedImage;
  bool _isLoading = false;
  String? _lastLoadedUrl;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ProfileAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Detectar cambio de URL y actualizar caché
    if (oldWidget.photoUrl != widget.photoUrl) {
      _handlePhotoUrlChange();
    }
  }

  /// Maneja el cambio de URL de foto y actualiza el caché
  Future<void> _handlePhotoUrlChange() async {
    final newUrl = widget.photoUrl;
    
    // Si la URL es vacía o null, limpiar
    if (newUrl?.isEmpty ?? true) {
      if (mounted) {
        setState(() {
          _cachedImage = null;
          _lastLoadedUrl = null;
        });
      }
      return;
    }
    
    // Verificar si la nueva URL ya está en caché
    final isCached = await _storageService.isImageCached(newUrl!);
    
    if (isCached) {
      // La imagen ya está en caché, solo cargarla
      final cachedImage = await _storageService.getSavedImage();
      if (mounted) {
        setState(() {
          _cachedImage = cachedImage;
          _lastLoadedUrl = newUrl;
        });
      }
    } else {
      // Nueva imagen, descargar y guardar en caché
      if (mounted) {
        setState(() => _isLoading = true);
      }
      
      await _storageService.saveImageFromUrl(newUrl);
      final newImage = await _storageService.getSavedImage();
      
      if (mounted) {
        setState(() {
          _cachedImage = newImage;
          _isLoading = false;
          _lastLoadedUrl = newUrl;
        });
      }
    }
  }

  Future<void> _loadImage() async {
    final currentUrl = widget.photoUrl;
    
    // Si no hay URL, no hacer nada
    if (currentUrl?.isEmpty ?? true) {
      return;
    }
    
    // Verificar si ya está cacheada
    final isCached = await _storageService.isImageCached(currentUrl!);
    
    if (isCached) {
      // Cargar desde caché sin loading
      final cachedImage = await _storageService.getSavedImage();
      if (mounted && cachedImage != null) {
        setState(() {
          _cachedImage = cachedImage;
          _lastLoadedUrl = currentUrl;
        });
      }
    } else {
      // Descargar y guardar en caché
      if (mounted) {
        setState(() => _isLoading = true);
      }
      
      await _storageService.saveImageFromUrl(currentUrl);
      final newImage = await _storageService.getSavedImage();
      
      if (mounted) {
        setState(() {
          _cachedImage = newImage;
          _isLoading = false;
          _lastLoadedUrl = currentUrl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: widget.radius,
        backgroundImage: _cachedImage != null
            ? MemoryImage(_cachedImage!)
            : (widget.photoUrl?.isNotEmpty == true
                ? NetworkImage(widget.photoUrl!)
                : null) as ImageProvider?,
        child: _cachedImage == null && widget.photoUrl?.isEmpty != false
            ? (_isLoading
                ? SizedBox(
                    width: widget.radius * 0.75,
                    height: widget.radius * 0.75,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey,
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: widget.radius,
                    color: Colors.grey,
                  ))
            : null,
      ),
    );
  }
}