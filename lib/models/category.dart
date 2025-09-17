class Category {
  final String id;
  final String name;
  final String? icon;
  final String? color;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // API returns category_dict with keys id (string/number) and title
    final String idStr = json['id']?.toString() ?? '';
    final String nameStr = json['name']?.toString() ?? json['title']?.toString() ?? '';
    return Category(
      id: idStr,
      name: nameStr,
      icon: json['icon']?.toString(),
      color: json['color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }
}

