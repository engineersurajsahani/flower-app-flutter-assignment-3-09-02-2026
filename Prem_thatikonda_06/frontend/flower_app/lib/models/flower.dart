class Flower {
  final String? id;
  final String name;
  final String imageUrl;
  final String pdfUrl;
  final String description;

  Flower({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.pdfUrl,
    required this.description,
  });

  factory Flower.fromJson(Map<String, dynamic> json) {
    return Flower(
      id: json['_id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      pdfUrl: json['pdfUrl'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'pdfUrl': pdfUrl,
      'description': description,
    };
  }
}
