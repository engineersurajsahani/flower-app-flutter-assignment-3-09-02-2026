import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/flower_service.dart';

class AddFlowerScreen extends StatefulWidget {
  const AddFlowerScreen({super.key});

  @override
  _AddFlowerScreenState createState() => _AddFlowerScreenState();
}

class _AddFlowerScreenState extends State<AddFlowerScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  File? image;
  Uint8List? _imageBytes;
  PlatformFile? _pickedPdf;

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

  void addFlower() async {
    Uint8List? pdfBytes;
    if (_pickedPdf != null) {
      if (kIsWeb) {
        pdfBytes = _pickedPdf!.bytes;
      } else if (_pickedPdf!.path != null) {
        pdfBytes = await File(_pickedPdf!.path!).readAsBytes();
      }
    }

    try {
      final result = await FlowerService.addFlower(
        name: nameController.text,
        description: descriptionController.text,
        imageBytes: _imageBytes,
        pdfBytes: pdfBytes,
      );
      if (!mounted) return;

      if (result['message'] == 'success') {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content: Text(result['message']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Flower')),
      body: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Flower name'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Flower description'),
          ),
          ElevatedButton(onPressed: uploadImage, child: Text('Select Image')),
          if (_imageBytes != null)
            Image.memory(
              _imageBytes!,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ElevatedButton(onPressed: uploadPdf, child: Text('Select PDF')),
          if (_pickedPdf != null) Text("Pdf: ${_pickedPdf!.name}"),
          ElevatedButton(onPressed: addFlower, child: Text('Add Flower')),
        ],
      ),
    );
  }
}
