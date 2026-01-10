// lib/database/models/item_with_category.dart
import '../app_database.dart';

/// Model representing an Item with its Category
class ItemWithCategory {
  final Item item;
  final Category? category;

  ItemWithCategory({
    required this.item,
    this.category,
  });

  String get categoryName => category?.name ?? 'Uncategorized';
  int get id => item.id;
  String get name => item.name;
  int get stock => item.stock;
  double get price => item.price;
  double get cost => item.cost;
  int get sold => item.sold;
  int get spoilage => item.spoilage;
  bool get isActive => item.isActive;

  /// Calculate profit margin
  double get profitMargin => price - cost;

  /// Calculate profit percentage
  double get profitPercentage {
    if (price == 0) return 0;
    return (profitMargin / price) * 100;
  }
}
