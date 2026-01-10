// lib/screens/inventory_management/ingredients_tab.dart
import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../database/daos/ingredients_dao.dart';
import '../../app_globals.dart';
import '../../utils/design_constants.dart';
import 'widgets/ingredient_form_dialog.dart';

/// Ingredients tab for managing raw materials/ingredients
class IngredientsTab extends StatefulWidget {
  final int commissaryId;

  const IngredientsTab({
    super.key,
    required this.commissaryId,
  });

  @override
  State<IngredientsTab> createState() => _IngredientsTabState();
}

class _IngredientsTabState extends State<IngredientsTab> {
  final TextEditingController _searchController = TextEditingController();
  IngredientSortOrder _sortOrder = IngredientSortOrder.nameAsc;
  String _searchQuery = '';
  bool _showLowStockOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddIngredientDialog() {
    showDialog(
      context: context,
      builder: (context) => IngredientFormDialog(
        commissaryId: widget.commissaryId,
        onSave: (companion) async {
          await database.ingredientsDao.createIngredient(companion);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ingredient added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditIngredientDialog(Ingredient ingredient) {
    showDialog(
      context: context,
      builder: (context) => IngredientFormDialog(
        ingredient: ingredient,
        commissaryId: widget.commissaryId,
        onSave: (companion) async {
          final updated = Ingredient(
            id: ingredient.id,
            cloudId: companion.cloudId.value,
            name: companion.name.value,
            unit: companion.unit.value,
            stock: companion.stock.value,
            costPerUnit: companion.costPerUnit.value,
            criticalLevel: companion.criticalLevel.value,
            commissaryId: companion.commissaryId.value,
            isActive: companion.isActive.value,
            createdAt: ingredient.createdAt,
            updatedAt: DateTime.now(),
            lastSyncedAt: ingredient.lastSyncedAt,
            needsSync: true,
          );
          await database.ingredientsDao.updateIngredient(updated);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ingredient updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(Ingredient ingredient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ingredient'),
        content: Text(
          'Are you sure you want to delete "${ingredient.name}"?\n\n'
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
              await database.ingredientsDao.softDeleteIngredient(ingredient.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${ingredient.name} deleted'),
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

  void _showAdjustStockDialog(Ingredient ingredient) {
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
              Expanded(child: Text('Adjust Stock: ${ingredient.name}')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Stock: ${ingredient.stock.toStringAsFixed(2)} ${ingredient.unit}',
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantity (${ingredient.unit})',
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
                final quantity = double.tryParse(controller.text);
                if (quantity != null && quantity > 0) {
                  final adjustment = isAdding ? quantity : -quantity;
                  await database.ingredientsDao.adjustStock(
                    ingredient.id,
                    adjustment,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${isAdding ? "Added" : "Removed"} ${quantity.toStringAsFixed(2)} ${ingredient.unit}',
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Actions Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Search
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search ingredients...',
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

                  // Sort dropdown
                  PopupMenuButton<IngredientSortOrder>(
                    icon: const Icon(Icons.sort),
                    tooltip: 'Sort by',
                    onSelected: (order) {
                      setState(() => _sortOrder = order);
                    },
                    itemBuilder: (context) => [
                      _buildSortMenuItem(
                        IngredientSortOrder.nameAsc,
                        'Name (A-Z)',
                        Icons.sort_by_alpha,
                      ),
                      _buildSortMenuItem(
                        IngredientSortOrder.nameDesc,
                        'Name (Z-A)',
                        Icons.sort_by_alpha,
                      ),
                      const PopupMenuDivider(),
                      _buildSortMenuItem(
                        IngredientSortOrder.stockAsc,
                        'Stock (Low to High)',
                        Icons.trending_up,
                      ),
                      _buildSortMenuItem(
                        IngredientSortOrder.stockDesc,
                        'Stock (High to Low)',
                        Icons.trending_down,
                      ),
                      const PopupMenuDivider(),
                      _buildSortMenuItem(
                        IngredientSortOrder.costAsc,
                        'Cost (Low to High)',
                        Icons.attach_money,
                      ),
                      _buildSortMenuItem(
                        IngredientSortOrder.costDesc,
                        'Cost (High to Low)',
                        Icons.attach_money,
                      ),
                      const PopupMenuDivider(),
                      _buildSortMenuItem(
                        IngredientSortOrder.newestFirst,
                        'Newest First',
                        Icons.schedule,
                      ),
                      _buildSortMenuItem(
                        IngredientSortOrder.oldestFirst,
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
                    onPressed: _showAddIngredientDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Ingredient'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Ingredients list
        Expanded(
          child: StreamBuilder<List<Ingredient>>(
            stream: database.ingredientsDao.watchIngredientsByCommissary(
              widget.commissaryId,
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

              var ingredients = snapshot.data ?? [];

              // Apply search filter
              if (_searchQuery.isNotEmpty) {
                ingredients = ingredients
                    .where((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();
              }

              // Apply low stock filter
              if (_showLowStockOnly) {
                ingredients = ingredients
                    .where((i) => i.stock <= i.criticalLevel)
                    .toList();
              }

              // Apply sorting
              ingredients.sort((a, b) {
                switch (_sortOrder) {
                  case IngredientSortOrder.nameAsc:
                    return a.name.compareTo(b.name);
                  case IngredientSortOrder.nameDesc:
                    return b.name.compareTo(a.name);
                  case IngredientSortOrder.stockAsc:
                    return a.stock.compareTo(b.stock);
                  case IngredientSortOrder.stockDesc:
                    return b.stock.compareTo(a.stock);
                  case IngredientSortOrder.costAsc:
                    return a.costPerUnit.compareTo(b.costPerUnit);
                  case IngredientSortOrder.costDesc:
                    return b.costPerUnit.compareTo(a.costPerUnit);
                  case IngredientSortOrder.newestFirst:
                    return b.createdAt.compareTo(a.createdAt);
                  case IngredientSortOrder.oldestFirst:
                    return a.createdAt.compareTo(b.createdAt);
                }
              });

              if (ingredients.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty || _showLowStockOnly
                            ? Icons.search_off
                            : Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty || _showLowStockOnly
                            ? 'No ingredients match your filters'
                            : 'No ingredients yet',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_searchQuery.isEmpty && !_showLowStockOnly)
                        ElevatedButton.icon(
                          onPressed: _showAddIngredientDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Your First Ingredient'),
                        ),
                    ],
                  ),
                );
              }

              return _buildIngredientsGrid(ingredients);
            },
          ),
        ),
      ],
    );
  }

  PopupMenuItem<IngredientSortOrder> _buildSortMenuItem(
    IngredientSortOrder order,
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
            color: _sortOrder == order ? Colors.orange : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: _sortOrder == order ? FontWeight.bold : FontWeight.normal,
              color: _sortOrder == order ? Colors.orange : null,
            ),
          ),
          if (_sortOrder == order) ...[
            const Spacer(),
            const Icon(Icons.check, size: 18, color: Colors.orange),
          ],
        ],
      ),
    );
  }

  Widget _buildIngredientsGrid(List<Ingredient> ingredients) {
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
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: ingredients.length,
          itemBuilder: (context, index) {
            return _buildIngredientCard(ingredients[index]);
          },
        );
      },
    );
  }

  Widget _buildIngredientCard(Ingredient ingredient) {
    final isLowStock = ingredient.stock <= ingredient.criticalLevel;
    final stockPercentage = ingredient.criticalLevel > 0
        ? (ingredient.stock / (ingredient.criticalLevel * 2)).clamp(0.0, 1.0)
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
        onTap: () => _showEditIngredientDialog(ingredient),
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
                      ingredient.name,
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
                          _showEditIngredientDialog(ingredient);
                          break;
                        case 'adjust':
                          _showAdjustStockDialog(ingredient);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(ingredient);
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
              const Spacer(),

              // Stock indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${ingredient.stock.toStringAsFixed(2)} ${ingredient.unit}',
                        style: TextStyle(
                          fontFamily: fontAll,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLowStock ? Colors.orange : Colors.black87,
                        ),
                      ),
                      Text(
                        '₱${ingredient.costPerUnit.toStringAsFixed(2)}/${ingredient.unit}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 4),
                  Text(
                    'Critical: ${ingredient.criticalLevel.toStringAsFixed(0)} ${ingredient.unit}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
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
