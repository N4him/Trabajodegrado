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
    // Solo recargar si la URL cambió realmente
    if (oldWidget.photoUrl != widget.photoUrl && 
        widget.photoUrl != _lastLoadedUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final currentUrl = widget.photoUrl;
    
    // Evitar cargas duplicadas
    if (currentUrl == _lastLoadedUrl && _cachedImage != null) {
      return;
    }
    
    // Primero cargar desde caché (sin setState para evitar parpadeo)
    final cachedImage = await _storageService.getSavedImage();
    
    if (cachedImage != null && mounted) {
      if (mounted) {
        setState(() {
          _cachedImage = cachedImage;
          _lastLoadedUrl = currentUrl;
        });
      }
      // Si tenemos caché, descargar en background sin mostrar loading
      if (currentUrl?.isNotEmpty == true && currentUrl != _lastLoadedUrl) {
        _downloadImageInBackground(currentUrl!);
      }
      return;
    }
    
    // Si no hay caché y hay URL, descargar con loading
    if (currentUrl?.isNotEmpty == true) {
      if (mounted) {
        setState(() => _isLoading = true);
      }
      
      await _storageService.saveImageFromUrl(currentUrl!);
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

  Future<void> _downloadImageInBackground(String url) async {
    await _storageService.saveImageFromUrl(url);
    final newImage = await _storageService.getSavedImage();
    
    if (mounted && newImage != null) {
      setState(() {
        _cachedImage = newImage;
        _lastLoadedUrl = url;
      });
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