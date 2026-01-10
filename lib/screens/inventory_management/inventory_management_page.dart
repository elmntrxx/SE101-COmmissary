// lib/screens/inventory_management/inventory_management_page.dart
import 'package:flutter/material.dart';
import '../../utils/design_constants.dart';
import 'ingredients_tab.dart';
import 'products_tab.dart';

/// Main inventory management page with tabs for Ingredients and Products
class InventoryManagementPage extends StatefulWidget {
  final int organizationId;
  final int commissaryId;
  final String organizationName;

  const InventoryManagementPage({
    super.key,
    required this.organizationId,
    required this.commissaryId,
    this.organizationName = 'Inventory Management',
  });

  @override
  State<InventoryManagementPage> createState() => _InventoryManagementPageState();
}

class _InventoryManagementPageState extends State<InventoryManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.inventory, size: 28),
            const SizedBox(width: 12),
            Text(
              widget.organizationName,
              style: const TextStyle(
                fontFamily: fontAll,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.kitchen),
              text: 'Ingredients',
            ),
            Tab(
              icon: Icon(Icons.fastfood),
              text: 'Products',
            ),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
        ),
        actions: [
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () => _showHelpDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Ingredients Tab
          IngredientsTab(commissaryId: widget.commissaryId),
          // Products Tab
          ProductsTab(organizationId: widget.organizationId),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 12),
            Text('Inventory Management Help'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HelpSection(
                title: 'Ingredients Tab',
                icon: Icons.kitchen,
                color: Colors.orange,
                items: [
                  'Manage raw materials and supplies used in your products',
                  'Track stock levels and set critical thresholds for low stock alerts',
                  'Record cost per unit for accurate product costing',
                  'Adjust stock quantities when receiving or using ingredients',
                ],
              ),
              SizedBox(height: 20),
              _HelpSection(
                title: 'Products Tab',
                icon: Icons.fastfood,
                color: Colors.blue,
                items: [
                  'Create and manage finished products for sale',
                  'Build recipes by adding ingredients with quantities',
                  'Auto-calculate product cost based on recipe ingredients',
                  'Track profit margins and stock levels',
                  'Organize products into categories',
                ],
              ),
              SizedBox(height: 20),
              _HelpSection(
                title: 'Tips',
                icon: Icons.lightbulb,
                color: Colors.amber,
                items: [
                  'Add ingredients first before creating products with recipes',
                  'Low stock items are highlighted with orange borders',
                  'Use the search and filter options to quickly find items',
                  'Click on any card to edit its details',
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _HelpSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.grey)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
