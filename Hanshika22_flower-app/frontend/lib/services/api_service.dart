import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl = kIsWeb
      ? "http://127.0.0.1:3001/api/files" // Use 127.0.0.1 for better reliability
      : "http://10.0.2.2:3001/api/files"; // android emulator

  // Mobile/Desktop upload
  Future uploadFile(File file) async {
    String fileName = file.path.split('/').last;

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    Response response = await Dio().post("$baseUrl/upload", data: formData);
    return response.data;
  }

  // Web upload using bytes
  Future uploadFileWeb(Uint8List bytes, String name, String mimeType) async {
    FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(
        bytes,
        filename: name,
        contentType: MediaType.parse(mimeType),
      ),
    });

    Response response = await Dio().post("$baseUrl/upload", data: formData);
    return response.data;
  }

  // Delete file by ID
  Future deleteFile(String id) async {
    Response response = await Dio().delete("$baseUrl/$id");
    return response.data;
  }

  // Get all files
  Future getFiles() async {
    Response response = await Dio().get(baseUrl);
    return response.data;
  }
}
