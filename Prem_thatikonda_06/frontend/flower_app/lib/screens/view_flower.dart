import 'package:flutter/material.dart';
import '../models/flower.dart';
import '../services/flower_service.dart';

class ViewFlowerScreen extends StatefulWidget {
  final Flower flower;
  const ViewFlowerScreen({super.key, required this.flower});

  @override
  _ViewFlowerScreenState createState() => _ViewFlowerScreenState();
}

class _ViewFlowerScreenState extends State<ViewFlowerScreen> {
  late Flower _flower;

  @override
  void initState() {
    super.initState();
    _flower = widget.flower;
  }

  void _navigateToEditFlower() async {
    final result = await Navigator.pushNamed(
      context,
      '/edit',
      arguments: _flower,
    );
    if (result == true) {
      // Re-fetch or update locally if we returned true (meaning edited)
      // For now, let's just pop back to list with 'true' so list refreshes,
      // OR we could re-fetch the single flower details here.
      // Simpler approach: return 'true' to list to refresh everything.
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  void _deleteFlower() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deleting Flower'),
        content: Text('Are you sure you want to delete ${_flower.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FlowerService.deleteFlower(_flower.id!);
        if (!mounted) return;
        Navigator.pop(context, true); // Return true to refresh list
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_flower.name),
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: _navigateToEditFlower),
          IconButton(icon: Icon(Icons.delete), onPressed: _deleteFlower),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_flower.imageUrl.isNotEmpty)
              Image.network(
                _flower.imageUrl.startsWith("http")
                    ? _flower.imageUrl
                    : "http://localhost:8080${_flower.imageUrl}",
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, size: 50),
                ),
              )
            else
              Container(
                height: 300,
                color: Colors.grey[200],
                child: Icon(Icons.local_florist, size: 100, color: Colors.grey),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _flower.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(_flower.description, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  if (_flower.pdfUrl.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(child: Text("PDF: ${_flower.pdfUrl}")),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
