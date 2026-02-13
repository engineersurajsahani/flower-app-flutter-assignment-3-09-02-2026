import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService();
  List files = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  fetchFiles() async {
    try {
      var res = await api.getFiles();
      setState(() {
        files = res;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching files: ${e.toString()}")),
      );
    }
  }

  String getMimeType(String fileName) {
    if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) return "image/jpeg";
    if (fileName.endsWith(".png")) return "image/png";
    if (fileName.endsWith(".pdf")) return "application/pdf";
    return "application/octet-stream";
  }

  pickAndUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null) {
      PlatformFile pickedFile = result.files.single;

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Uploading ${pickedFile.name}...")),
      );

      try {
        if (kIsWeb) {
          if (pickedFile.bytes != null && pickedFile.bytes!.isNotEmpty) {
            await api.uploadFileWeb(
              pickedFile.bytes!,
              pickedFile.name,
              getMimeType(pickedFile.name),
            );
          } else {
            throw Exception("No file bytes found for web upload");
          }
        } else {
          File file = File(pickedFile.path!);
          await api.uploadFile(file);
        }

        fetchFiles();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File uploaded successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Upload failed: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  deleteFile(String id) async {
    try {
      await api.deleteFile(id);
      fetchFiles();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: ${e.toString()}")),
      );
    }
  }

  bool isImage(String fileType) => fileType == 'image';

  @override
  Widget build(BuildContext context) {
    // Modern Color Palette
    final primaryColor = Color(0xFF6200EA); // Deep Purple
    final secondaryColor = Color(0xFF03DAC6); // Teal
    final backgroundColor = Color(0xFFF5F5F7); // Whitesmoke
    final cardColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "My Cloud Drive",
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, Color(0xFF3700B3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: pickAndUpload,
        label: Text("Upload"),
        icon: Icon(Icons.cloud_upload),
        backgroundColor: secondaryColor,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : files.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        "No files yet",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Tap the upload button to add files",
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 900
                          ? 4
                          : MediaQuery.of(context).size.width > 600
                              ? 3
                              : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      var file = files[index];
                      // Use 127.0.0.1 for image URL if on web to match API service
                      String imageUrl = kIsWeb
                          ? "http://127.0.0.1:3001/${file['filepath']}"
                          : file['filepath']; // For mobile, usually requires full path or different handling

                      // If mobile and filepath is relative, might need fixing generally, but focusing on web logic:
                      if (!kIsWeb) {
                        // Assuming file path is local path on device for now as per original code
                      }

                      return Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Optional: Add logic to open/view file
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.vertical(top: Radius.circular(16)),
                                      child: Container(
                                        width: double.infinity,
                                        color: Colors.grey[100],
                                        child: isImage(file['filetype'])
                                            ? (kIsWeb
                                                ? Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (ctx, _, __) => Center(
                                                        child: Icon(Icons.broken_image,
                                                            color: Colors.grey)),
                                                  )
                                                : Image.file(
                                                    File(file['filepath']),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (ctx, _, __) => Center(
                                                        child: Icon(Icons.broken_image,
                                                            color: Colors.grey)),
                                                  ))
                                            : Center(
                                                child: Icon(Icons.picture_as_pdf,
                                                    size: 48, color: Colors.red[400]),
                                              ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: InkWell(
                                        onTap: () => deleteFile(file['_id']),
                                        child: Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              )
                                            ],
                                          ),
                                          child: Icon(Icons.delete_outline,
                                              size: 18, color: Colors.red[400]),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file['filename'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      file['filetype'].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
