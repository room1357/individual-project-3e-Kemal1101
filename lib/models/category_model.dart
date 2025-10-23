class Category {
  final int id;
  final String name;
  final String? icon;

  Category({required this.id, required this.name, this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: int.parse(json['category_id']),
      name: json['name'],
      icon: json['icon'],
    );
  }
}
