// lib/screens/inventory_management/products_tab.dart
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../database/app_database.dart';
import '../../database/daos/items_dao.dart';
import '../../app_globals.dart';
import '../../utils/tables.dart';
import 'widgets/item_form_dialog.dart';

/// Products/Inventory tab for managing finished products
class ProductsTab extends StatefulWidget {
  final int organizationId;
  final ValueChanged<bool>? onItemsChanged;

  const ProductsTab({
    super.key,
    required this.organizationId,
    this.onItemsChanged,
  });

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  final TextEditingController _searchController = TextEditingController();
  ItemSortOrder _sortOrder = ItemSortOrder.nameAsc;
  String _searchQuery = '';
  bool _showLowStockOnly = false;
  int? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddProductDialog() async {
    // Fetch ingredients and categories
    final ingredients = await database.ingredientsDao.getAllIngredients();
    final categories = await database.categoriesDao.getAllCategories();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => ItemFormDialog(
        organizationId: widget.organizationId,
        availableIngredients: ingredients,
        categories: categories,
        onSave: (itemCompanion, recipeIngredients) async {
          // Insert item
          final itemId = await database.itemsDao.createItem(itemCompanion);

          // Insert recipe ingredients
          const uuid = Uuid();
          for (final ingredient in recipeIngredients) {
            await database.recipeIngredientsDao.createRecipeIngredient(
              RecipeIngredientsCompanion(
                cloudId: Value(uuid.v4()),
                itemId: Value(itemId),
                ingredientId: Value(ingredient.ingredientId),
                quantity: Value(ingredient.quantity),
              ),
            );
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _showEditProductDialog(Item item) async {
    // Fetch ingredients and categories
    final ingredients = await database.ingredientsDao.getAllIngredients();
    final categories = await database.categoriesDao.getAllCategories();
    final existingRecipe = await database.recipeIngredientsDao.getRecipeIngredients(item.id);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => ItemFormDialog(
        item: item,
        organizationId: widget.organizationId,
        availableIngredients: ingredients,
        categories: categories,
        existingRecipe: existingRecipe,
        onSave: (itemCompanion, recipeIngredients) async {
          // Update item
          final updatedItem = Item(
            id: item.id,
            cloudId: itemCompanion.cloudId.value,
            name: itemCompanion.name.value,
            description: itemCompanion.description.value,
            stock: itemCompanion.stock.value,
            criticalLevel: itemCompanion.criticalLevel.value,
            sold: item.sold,
            spoilage: item.spoilage,
            price: itemCompanion.price.value,
            cost: itemCompanion.cost.value,
            organizationId: itemCompanion.organizationId.value,
            categoryId: itemCompanion.categoryId.value,
            masterItemId: item.masterItemId,
            isActive: itemCompanion.isActive.value,
            createdAt: item.createdAt,
            updatedAt: DateTime.now(),
            lastSyncedAt: item.lastSyncedAt,
            needsSync: true,
          );
          await database.itemsDao.updateItem(updatedItem);

          // Update recipe - delete old and insert new
          const uuid = Uuid();
          await database.recipeIngredientsDao.deleteRecipeForItem(item.id);
          for (final ingredient in recipeIngredients) {
            await database.recipeIngredientsDao.createRecipeIngredient(
              RecipeIngredientsCompanion(
                cloudId: Value(uuid.v4()),
                itemId: Value(item.id),
                ingredientId: Value(ingredient.ingredientId),
                quantity: Value(ingredient.quantity),
              ),
            );
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${item.name}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await database.itemsDao.softDeleteItem(item.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} deleted'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAdjustStockDialog(Item item) {
    final controller = TextEditingController();
    bool isAdding = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.inventory, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(child: Text('Adjust Stock: ${item.name}')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Stock: ${item.stock} units',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ToggleButtons(
                isSelected: [isAdding, !isAdding],
                onPressed: (index) {
                  setDialogState(() {
                    isAdding = index == 0;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text('Add Stock'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.remove, size: 20),
                        SizedBox(width: 8),
                        Text('Remove Stock'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(isAdding ? Icons.add : Icons.remove),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final quantity = int.tryParse(controller.text);
                if (quantity != null && quantity > 0) {
                  final adjustment = isAdding ? quantity : -quantity;
                  await database.itemsDao.adjustStock(item.id, adjustment);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${isAdding ? "Added" : "Removed"} $quantity units',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipeDetailsDialog(Item item) async {
    final recipeDetails = await database.recipeIngredientsDao.getRecipeWithDetails(item.id);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.restaurant_menu, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(child: Text('Recipe: ${item.name}')),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: recipeDetails.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No recipe defined for this product.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Recipe table
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(7),
                                topRight: Radius.circular(7),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Ingredient',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Quantity',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Cost',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...recipeDetails.map((detail) => Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.grey[200]!),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(detail.ingredientName),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text('${detail.quantity} ${detail.unit}'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '₱${detail.totalCost.toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Cost summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Cost:'),
                              Text(
                                '₱${item.cost.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Selling Price:'),
                              Text(
                                '₱${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Profit Margin:'),
                              Text(
                                '₱${(item.price - item.cost).toStringAsFixed(2)} '
                                '(${item.price > 0 ? ((item.price - item.cost) / item.price * 100).toStringAsFixed(1) : 0}%)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: item.price - item.cost >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
      stream: database.itemsDao.watchItemsByOrganization(
        widget.organizationId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        var products = snapshot.data ?? [];

        // Notify parent about items count
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onItemsChanged?.call(products.isNotEmpty);
          }
        });

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          products = products
              .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
        }

        // Apply category filter
        if (_selectedCategoryId != null) {
          products = products.where((p) => p.categoryId == _selectedCategoryId).toList();
        }

        // Apply low stock filter
        if (_showLowStockOnly) {
          products = products.where((p) => p.stock <= p.criticalLevel).toList();
        }

        // Apply sorting
        products.sort((a, b) {
          switch (_sortOrder) {
            case ItemSortOrder.nameAsc:
              return a.name.compareTo(b.name);
            case ItemSortOrder.nameDesc:
              return b.name.compareTo(a.name);
            case ItemSortOrder.stockAsc:
              return a.stock.compareTo(b.stock);
            case ItemSortOrder.stockDesc:
              return b.stock.compareTo(a.stock);
            case ItemSortOrder.priceAsc:
              return a.price.compareTo(b.price);
            case ItemSortOrder.priceDesc:
              return b.price.compareTo(a.price);
            case ItemSortOrder.costAsc:
              return a.cost.compareTo(b.cost);
            case ItemSortOrder.costDesc:
              return b.cost.compareTo(a.cost);
            case ItemSortOrder.newestFirst:
              return b.createdAt.compareTo(a.createdAt);
            case ItemSortOrder.oldestFirst:
              return a.createdAt.compareTo(b.createdAt);
          }
        });

        if (products.isEmpty && _searchQuery.isEmpty && !_showLowStockOnly && _selectedCategoryId == null) {
          return emptyTables(
            message: 'You can manage your products here.',
            onAddPressed: _showAddProductDialog,
            buttonType: EmptyButtonType.icon,
            buttonText: null,
          );
        }

        if (products.isEmpty) {
          return const Center(
            child: Text(
              'No products match your filters',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final numberFormat = NumberFormat('#,##0.##');
        return buildUniversalTable(
          headers: [
            'Name',
            'Stock',
            'Price',
            'Cost',
            'Margin',
            'Status',
            '',
          ],
          rows: products.map((product) {
            final isLowStock = product.stock <= product.criticalLevel;
            final profit = product.price - product.cost;
            final profitMargin = product.price > 0 ? (profit / product.price * 100) : 0;
            return [
              Text(product.name),
              Text(numberFormat.format(product.stock)),
              Text('₱${numberFormat.format(product.price)}'),
              Text('₱${numberFormat.format(product.cost)}'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: profit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${profitMargin.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: profit >= 0 ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLowStock ? Colors.orange.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isLowStock ? 'Low Stock' : 'In Stock',
                  style: TextStyle(
                    color: isLowStock ? Colors.orange : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restaurant_menu, size: 18),
                    tooltip: 'View Recipe',
                    onPressed: () => _showRecipeDetailsDialog(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.inventory, size: 18),
                    tooltip: 'Adjust Stock',
                    onPressed: () => _showAdjustStockDialog(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    tooltip: 'Edit',
                    onPressed: () => _showEditProductDialog(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                    tooltip: 'Delete',
                    onPressed: () => _showDeleteConfirmation(product),
                  ),
                ],
              ),
            ];
          }).toList(),
          smallHeaderWidth: 60,
          largeHeaderWidth: 60,
        );
      },
    );
  }
}
