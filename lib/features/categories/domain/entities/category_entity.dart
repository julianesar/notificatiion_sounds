class CategoryEntity {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final int soundCount;
  final bool isPopular;
  final DateTime createdAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.soundCount,
    this.isPopular = false,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}