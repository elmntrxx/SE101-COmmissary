import 'package:flutter/material.dart';
import '../../utils/design_constants.dart';
import 'inventory_management_page.dart';
import 'ingredients_tab.dart';
import 'products_tab.dart';

class InventoryManagementPageMobile extends StatelessWidget {
  final InventoryManagementPageState state;

  const InventoryManagementPageMobile({super.key, required this.state});

  Widget buildTab(String label, int index) {
    bool active = state.selectedTab == index;
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => state.setSelectedTab(index),
          child: Container(
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.widget.organizationName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontFamily: fontAll,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.help_outline,
                          size: 28,
                        ),
                        onPressed: () => state.showHelpDialog(context),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          size: 28,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        icon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    buildTab('Ingredients', 0),
                    buildTab('Products', 1),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: state.selectedTab == 0
                      ? IngredientsTab(
                          commissaryId: state.widget.commissaryId,
                          onItemsChanged: state.setHasIngredients,
                        )
                      : ProductsTab(
                          organizationId: state.widget.organizationId,
                          onItemsChanged: state.setHasProducts,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ((state.selectedTab == 0 && state.hasIngredients) ||
              (state.selectedTab == 1 && state.hasProducts))
          ? FloatingActionButton(
              backgroundColor: Colors.red[700],
              onPressed: state.selectedTab == 0
                  ? state.showAddIngredientDialog
                  : state.showAddProductDialog,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
