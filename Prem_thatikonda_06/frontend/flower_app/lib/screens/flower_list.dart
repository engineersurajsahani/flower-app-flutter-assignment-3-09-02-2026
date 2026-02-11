import 'package:flutter/material.dart';
import '../models/flower.dart';
import '../services/flower_service.dart';

class FlowerListScreen extends StatefulWidget {
  const FlowerListScreen({super.key});

  @override
  _FlowerListScreenState createState() => _FlowerListScreenState();
}

class _FlowerListScreenState extends State<FlowerListScreen> {
  final FlowerService _flowerService = FlowerService();
  late Future<List<Flower>> _flowersFuture;

  @override
  void initState() {
    super.initState();
    _refreshFlowers();
  }

  void _refreshFlowers() {
    setState(() {
      _flowersFuture = _flowerService.getFlowers();
    });
  }

  void _navigateToAddFlower() async {
    await Navigator.pushNamed(context, '/add');
    _refreshFlowers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flower List')),
      body: FutureBuilder<List<Flower>>(
        future: _flowersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No flowers found.'));
          }

          final flowers = snapshot.data!;
          return ListView.builder(
            itemCount: flowers.length,
            itemBuilder: (context, index) {
              final flower = flowers[index];
              return Card(
                child: ListTile(
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/view',
                      arguments: flower,
                    );
                    if (result == true) {
                      _refreshFlowers();
                    }
                  },
                  leading: flower.imageUrl.isNotEmpty
                      ? Image.network(
                          flower.imageUrl.startsWith("http")
                              ? flower.imageUrl
                              : "http://localhost:8080${flower.imageUrl}",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image),
                        )
                      : Icon(Icons.local_florist),
                  title: Text(flower.name),
                  subtitle: Text(flower.description),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddFlower,
        child: Icon(Icons.add),
      ),
    );
  }
}
