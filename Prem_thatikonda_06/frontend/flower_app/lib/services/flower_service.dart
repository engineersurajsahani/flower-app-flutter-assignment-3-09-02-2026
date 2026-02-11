import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../models/flower.dart';

import 'package:flower_app/utils/local_storage_service.dart';

class FlowerService {
  static final String baseUrl = "http://localhost:8080/api/flowers";

  static Future<Map<String, dynamic>> addFlower({
    required String name,
    required String description,
    Uint8List? imageBytes,
    Uint8List? pdfBytes,
  }) async {
    String imageUrl = "";
    String pdfUrl = "";

    if (imageBytes != null) {
      String base64Image = base64Encode(imageBytes);
      imageUrl = "data:image/png;base64,$base64Image";
    }

    if (pdfBytes != null) {
      String base64Pdf = base64Encode(pdfBytes);
      pdfUrl = "data:application/pdf;base64,$base64Pdf";
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "description": description,
        "imageUrl": imageUrl,
        "pdfUrl": pdfUrl,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      if (imageUrl.isNotEmpty) {
        await LocalStorageService.deleteImageFile(imageUrl);
      }
      if (pdfUrl.isNotEmpty) {
        await LocalStorageService.deletePdfFile(pdfUrl);
      }
      throw Exception("Failed to add flower: ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> editFlower({
    required String id,
    required String name,
    required String description,
    Uint8List? imageBytes,
    Uint8List? pdfBytes,
    String? existingImageUrl,
    String? existingPdfUrl,
  }) async {
    String imageUrl = existingImageUrl ?? "";
    String pdfUrl = existingPdfUrl ?? "";

    if (imageBytes != null) {
      String base64Image = base64Encode(imageBytes);
      imageUrl = "data:image/png;base64,$base64Image";
    }

    if (pdfBytes != null) {
      String base64Pdf = base64Encode(pdfBytes);
      pdfUrl = "data:application/pdf;base64,$base64Pdf";
    }

    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "description": description,
        "imageUrl": imageUrl,
        "pdfUrl": pdfUrl,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to edit flower: ${response.body}");
    }
  }

  static Future<void> deleteFlower(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    if (response.statusCode != 200) {
      throw Exception("Failed to delete flower: ${response.body}");
    }
  }

  Future<List<Flower>> getFlowers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];
      List<Flower> flowers = data
          .map((dynamic item) => Flower.fromJson(item))
          .toList();
      return flowers;
    } else {
      throw Exception("Failed to load flowers");
    }
  }
}
