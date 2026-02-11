import 'package:flutter/material.dart';
import './screens/flower_list.dart';
import './screens/add_flower.dart';
import './screens/edit_flower.dart';
import './screens/view_flower.dart';
import './models/flower.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flower App',
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => const FlowerListScreen(),
        "/add": (context) => const AddFlowerScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/edit') {
          final flower = settings.arguments as Flower;
          return MaterialPageRoute(
            builder: (context) => EditFlowerScreen(flower: flower),
          );
        } else if (settings.name == '/view') {
          final flower = settings.arguments as Flower;
          return MaterialPageRoute(
            builder: (context) => ViewFlowerScreen(flower: flower),
          );
        }
        return null;
      },
    );
  }
}
