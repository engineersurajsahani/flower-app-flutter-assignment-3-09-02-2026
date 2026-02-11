import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/flower_service.dart';
import '../models/flower.dart';

class EditFlowerScreen extends StatefulWidget {
  final Flower flower;
  const EditFlowerScreen({super.key, required this.flower});

  @override
  _EditFlowerScreenState createState() => _EditFlowerScreenState();
}

class _EditFlowerScreenState extends State<EditFlowerScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  File? image;
  Uint8List? _imageBytes;
  PlatformFile? _pickedPdf;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.flower.name);
    descriptionController = TextEditingController(
      text: widget.flower.description,
    );
  }

  void uploadImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        image = File(pickedImage.path);
        _imageBytes = bytes;
      });
    }
  }

  void uploadPdf() async {
    final pickedPdf = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (pickedPdf != null) {
      setState(() {
        _pickedPdf = pickedPdf.files.single;
      });
    }
  }

  void editFlower() async {
    Uint8List? pdfBytes;
    if (_pickedPdf != null) {
      if (kIsWeb) {
        pdfBytes = _pickedPdf!.bytes;
      } else if (_pickedPdf!.path != null) {
        pdfBytes = await File(_pickedPdf!.path!).readAsBytes();
      }
    }

    final result = await FlowerService.editFlower(
      id: widget.flower.id!,
      name: nameController.text,
      description: descriptionController.text,
      imageBytes: _imageBytes,
      pdfBytes: pdfBytes,
      existingImageUrl: widget.flower.imageUrl,
      existingPdfUrl: widget.flower.pdfUrl,
    );

    if (result['message'] == 'success') {
      Navigator.pop(context, true); // Return true to indicate update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Flower')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Flower name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Flower description'),
            ),
            SizedBox(height: 20),
            Text("Current Image:"),
            if (widget.flower.imageUrl.isNotEmpty)
              Image.network(
                "http://localhost:8080${widget.flower.imageUrl}", // Assuming local dev setup for web
                height: 100,
                errorBuilder: (context, error, stackTrace) =>
                    Text("Failed to load image"),
              )
            else
              Text("No image"),
            ElevatedButton(onPressed: uploadImage, child: Text('Change Image')),
            if (_imageBytes != null)
              Image.memory(
                _imageBytes!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 20),
            Text("Current PDF: ${widget.flower.pdfUrl}"),
            ElevatedButton(onPressed: uploadPdf, child: Text('Change PDF')),
            if (_pickedPdf != null) Text("New Pdf: ${_pickedPdf!.name}"),
            SizedBox(height: 20),
            ElevatedButton(onPressed: editFlower, child: Text('Update Flower')),
          ],
        ),
      ),
    );
  }
}
