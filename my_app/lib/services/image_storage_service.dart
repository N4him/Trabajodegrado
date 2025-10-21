import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ImageStorageService {
  static const String _imageKey = 'profile_image';
  static const String _imageUrlKey = 'profile_image_url'; // Guardamos la URL también
  
  // Guardar imagen desde URL
  Future<void> saveImageFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        String base64Image = base64Encode(response.bodyBytes);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_imageKey, base64Image);
        await prefs.setString(_imageUrlKey, imageUrl); // Guardamos la URL
      }
    // ignore: empty_catches
    } catch (e) {
    }
  }
  
  // Obtener imagen guardada
  Future<Uint8List?> getSavedImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? base64Image = prefs.getString(_imageKey);
      
      if (base64Image != null) {
        return base64Decode(base64Image);
      }
    // ignore: empty_catches
    } catch (e) {
    }
    return null;
  }
  
  // Obtener URL guardada
  Future<String?> getSavedImageUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_imageUrlKey);
    // ignore: empty_catches
    } catch (e) {
    }
    return null;
  }
  
  // Verificar si la URL ya está en caché
  Future<bool> isImageCached(String imageUrl) async {
    final savedUrl = await getSavedImageUrl();
    return savedUrl == imageUrl;
  }
  
  // Eliminar imagen guardada
  Future<void> clearSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_imageKey);
    await prefs.remove(_imageUrlKey);
  }
}

