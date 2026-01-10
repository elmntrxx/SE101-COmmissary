// lib/screens/inventory_management/products_tab.dart
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';
import '../../database/app_database.dart';
import '../../database/daos/items_dao.dart';
import '../../app_globals.dart';
import '../../utils/design_constants.dart';
import 'widgets/item_form_dialog.dart';

/// Products/Inventory tab for managing finished products
class ProductsTab extends StatefulWidget {
  final int organizationId;

  const ProductsTab({
    super.key,
    required this.organizationId,
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
    return Column(
      children: [
        // Search and Actions Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Search
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Category filter
              StreamBuilder<List<Category>>(
                stream: database.categoriesDao.watchAllCategories(),
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? [];
                  return PopupMenuButton<int?>(
                    icon: const Icon(Icons.category),
                    tooltip: 'Filter by category',
                    onSelected: (id) {
                      setState(() => _selectedCategoryId = id);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<int?>(
                        value: null,
                        child: Row(
                          children: [
                            Icon(
                              Icons.all_inclusive,
                              size: 20,
                              color: _selectedCategoryId == null
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            const Text('All Categories'),
                            if (_selectedCategoryId == null) ...[
                              const Spacer(),
                              const Icon(Icons.check, size: 18, color: Colors.blue),
                            ],
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      ...categories.map((cat) => PopupMenuItem<int?>(
                            value: cat.id,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.label,
                                  size: 20,
                                  color: _selectedCategoryId == cat.id
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Text(cat.name),
                                if (_selectedCategoryId == cat.id) ...[
                                  const Spacer(),
                                  const Icon(Icons.check, size: 18, color: Colors.blue),
                                ],
                              ],
                            ),
                          )),
                    ],
                  );
                },
              ),

              // Sort dropdown
              PopupMenuButton<ItemSortOrder>(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort by',
                onSelected: (order) {
                  setState(() => _sortOrder = order);
                },
                itemBuilder: (context) => [
                  _buildSortMenuItem(
                    ItemSortOrder.nameAsc,
                    'Name (A-Z)',
                    Icons.sort_by_alpha,
                  ),
                  _buildSortMenuItem(
                    ItemSortOrder.nameDesc,
                    'Name (Z-A)',
                    Icons.sort_by_alpha,
                  ),
                  const PopupMenuDivider(),
                  _buildSortMenuItem(
                    ItemSortOrder.stockAsc,
                    'Stock (Low to High)',
                    Icons.trending_up,
                  ),
                  _buildSortMenuItem(
                    ItemSortOrder.stockDesc,
                    'Stock (High to Low)',
                    Icons.trending_down,
                  ),
                  const PopupMenuDivider(),
                  _buildSortMenuItem(
                    ItemSortOrder.priceAsc,
                    'Price (Low to High)',
                    Icons.attach_money,
                  ),
                  _buildSortMenuItem(
                    ItemSortOrder.priceDesc,
                    'Price (High to Low)',
                    Icons.attach_money,
                  ),
                  const PopupMenuDivider(),
                  _buildSortMenuItem(
                    ItemSortOrder.newestFirst,
                    'Newest First',
                    Icons.schedule,
                  ),
                  _buildSortMenuItem(
                    ItemSortOrder.oldestFirst,
                    'Oldest First',
                    Icons.history,
                  ),
                ],
              ),

              // Low stock filter
              FilterChip(
                label: const Text('Low Stock'),
                selected: _showLowStockOnly,
                onSelected: (selected) {
                  setState(() => _showLowStockOnly = selected);
                },
                avatar: Icon(
                  Icons.warning,
                  size: 18,
                  color: _showLowStockOnly ? Colors.white : Colors.orange,
                ),
                selectedColor: Colors.orange,
              ),
              const SizedBox(width: 12),

              // Add button
              ElevatedButton.icon(
                onPressed: _showAddProductDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Products list
        Expanded(
          child: StreamBuilder<List<Item>>(
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

              // Apply search filter
              if (_searchQuery.isNotEmpty) {
                products = products
                    .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();
              }

              // Apply category filter
              if (_selectedCategoryId != null) {
                products = products
                    .where((p) => p.categoryId == _selectedCategoryId)
                    .toList();
              }

              // Apply low stock filter
              if (_showLowStockOnly) {
                products = products
                    .where((p) => p.stock <= p.criticalLevel)
                    .toList();
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

              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty || _showLowStockOnly || _selectedCategoryId != null
                            ? Icons.search_off
                            : Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty || _showLowStockOnly || _selectedCategoryId != null
                            ? 'No products match your filters'
                            : 'No products yet',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_searchQuery.isEmpty && !_showLowStockOnly && _selectedCategoryId == null)
                        ElevatedButton.icon(
                          onPressed: _showAddProductDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Your First Product'),
                        ),
                    ],
                  ),
                );
              }

              return _buildProductsGrid(products);
            },
          ),
        ),
      ],
    );
  }

  PopupMenuItem<ItemSortOrder> _buildSortMenuItem(
    ItemSortOrder order,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: order,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: _sortOrder == order ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: _sortOrder == order ? FontWeight.bold : FontWeight.normal,
              color: _sortOrder == order ? Colors.blue : null,
            ),
          ),
          if (_sortOrder == order) ...[
            const Spacer(),
            const Icon(Icons.check, size: 18, color: Colors.blue),
          ],
        ],
      ),
    );
  }

  Widget _buildProductsGrid(List<Item> products) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
                ? 3
                : constraints.maxWidth > 500
                    ? 2
                    : 1;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return _buildProductCard(products[index]);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Item product) {
    final isLowStock = product.stock <= product.criticalLevel;
    final profit = product.price - product.cost;
    final profitMargin = product.price > 0 ? (profit / product.price * 100) : 0;
    final stockPercentage = product.criticalLevel > 0
        ? (product.stock / (product.criticalLevel * 2)).clamp(0.0, 1.0)
        : 1.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLowStock
            ? const BorderSide(color: Colors.orange, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEditProductDialog(product),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontFamily: fontAll,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isLowStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 14,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Low',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditProductDialog(product);
                          break;
                        case 'recipe':
                          _showRecipeDetailsDialog(product);
                          break;
                        case 'adjust':
                          _showAdjustStockDialog(product);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(product);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'recipe',
                        child: Row(
                          children: [
                            Icon(Icons.restaurant_menu, size: 20),
                            SizedBox(width: 12),
                            Text('View Recipe'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'adjust',
                        child: Row(
                          children: [
                            Icon(Icons.inventory, size: 20),
                            SizedBox(width: 12),
                            Text('Adjust Stock'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Description
              if (product.description != null && product.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    product.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              const Spacer(),

              // Pricing row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₱${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: fontAll,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Cost: ₱${product.cost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: profit >= 0
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${profitMargin.toStringAsFixed(0)}% margin',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: profit >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stock indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.stock} units',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isLowStock ? Colors.orange : Colors.black87,
                        ),
                      ),
                      Text(
                        'Critical: ${product.criticalLevel}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: stockPercentage,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isLowStock ? Colors.orange : Colors.green,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
