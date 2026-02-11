import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  static Future<String> saveImageFile(File imageFile) async {
    try {
      // Get the application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDirPath = path.join(appDir.path, 'flower_images');
      
      // Create images directory if it doesn't exist
      final Directory imagesDir = Directory(imagesDirPath);
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      // Generate unique filename
      final String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final String filePath = path.join(imagesDirPath, fileName);
      
      // Copy file to local storage
      await imageFile.copy(filePath);
      
      return filePath;
    } catch (e) {
      throw Exception('Failed to save image file: $e');
    }
  }
  
  static Future<String> savePdfFile(File pdfFile) async {
    try {
      // Get the application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String pdfsDirPath = path.join(appDir.path, 'flower_pdfs');
      
      // Create PDFs directory if it doesn't exist
      final Directory pdfsDir = Directory(pdfsDirPath);
      if (!await pdfsDir.exists()) {
        await pdfsDir.create(recursive: true);
      }
      
      // Generate unique filename
      final String fileName = 'pdf_${DateTime.now().millisecondsSinceEpoch}${path.extension(pdfFile.path)}';
      final String filePath = path.join(pdfsDirPath, fileName);
      
      // Copy file to local storage
      await pdfFile.copy(filePath);
      
      return filePath;
    } catch (e) {
      throw Exception('Failed to save PDF file: $e');
    }
  }
  
  static Future<void> deleteImageFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete image file: $e');
    }
  }
  
  static Future<void> deletePdfFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete PDF file: $e');
    }
  }
}