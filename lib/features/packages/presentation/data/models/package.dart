class Package {
  final int id;
  final String name;
  final String description;
  final String image;
  final String buttonText;
  final String price;
  final int points;
  final int limit;
  final int moneyPngCount;
  final bool status;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  Package({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.buttonText,
    required this.price,
    required this.points,
    required this.limit,
    required this.moneyPngCount,
    required this.status,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      buttonText: json['button_text'],
      price: json['price'],
      points: json['points'],
      limit: json['limit'],
      moneyPngCount: json['money_png_count'],
      status: json['status'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'button_text': buttonText,
      'price': price,
      'points': points,
      'limit': limit,
      'money_png_count': moneyPngCount,
      'status': status,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}



