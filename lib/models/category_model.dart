class Category {
  final int id;
  final String name;
  final String? icon;

  Category({required this.id, required this.name, this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    // API bisa mengembalikan id sebagai string atau int, jadi kita tangani keduanya.
    final idValue = json['category_id'];
    return Category(
      id: idValue is int ? idValue : int.parse(idValue),
      name: json['name'],
      icon: json['icon'] as String?,
    );
  }
}
