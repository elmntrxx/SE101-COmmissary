// lib/screens/reports/reports_page.dart
import 'package:flutter/material.dart';
import '../../app_globals.dart';
import '../../database/app_database.dart';
import '../../utils/design_constants.dart';

/// Reports Page - Cross-branch reporting for commissary
/// Shows aggregated data from ALL franchisee branches
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late AppDatabase _db;
  bool _isLoading = true;

  // Data
  List<Organization> _branches = [];
  Map<int, List<Item>> _branchItems = {};
  Map<int, Map<String, dynamic>> _branchStats = {};
  Organization? _selectedBranch; // null = All branches
  String _selectedPeriod = 'This Week';

  // Aggregated stats
  int _totalItems = 0;
  int _totalSold = 0;
  int _totalSpoilage = 0;
  int _lowStockCount = 0;

  @override
  void initState() {
    super.initState();
    _db = database;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Get commissary
      final commissary = await _db.organizationsDao.getCommissary();
      if (commissary == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get all branches
      _branches = await _db.organizationsDao.getFranchisees(commissary.cloudId);

      // Get items and stats for each branch
      _branchItems = {};
      _branchStats = {};
      _totalItems = 0;
      _totalSold = 0;
      _totalSpoilage = 0;
      _lowStockCount = 0;

      for (final branch in _branches) {
        final items = await _db.itemsDao.getItemsByOrganization(branch.id);
        _branchItems[branch.id] = items;

        // Calculate stats for this branch
        int sold = 0;
        int spoilage = 0;
        int lowStock = 0;

        for (final item in items) {
          sold += item.sold;
          spoilage += item.spoilage;
          if (item.stock <= item.criticalLevel) lowStock++;
        }

        _branchStats[branch.id] = {
          'itemCount': items.length,
          'sold': sold,
          'spoilage': spoilage,
          'lowStock': lowStock,
        };

        // Add to totals
        _totalItems += items.length;
        _totalSold += sold;
        _totalSpoilage += spoilage;
        _lowStockCount += lowStock;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error loading reports: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      // MOBILE VIEW
      return Scaffold(
        backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Reports',
                            style: TextStyle(fontSize: 26, fontFamily: fontAll),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, size: 28),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Mobile Filters
                      _buildMobileFilters(),
                      const SizedBox(height: 16),

                      // Mobile Stats
                      _buildMobileStats(),
                      const SizedBox(height: 24),

                      // Branch Performance
                      const Text(
                        'Branch Performance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontAll,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMobileBranchComparison(),
                      const SizedBox(height: 24),

                      // Branch List
                      if (_selectedBranch == null) ...[
                        const Text(
                          'All Branches',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontAll,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildMobileBranchList(),
                      ] else ...[
                        Text(
                          '${_selectedBranch!.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontAll,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildMobileBranchDetails(_selectedBranch!),
                      ],
                    ],
                  ),
                ),
        ),
      );
    }

    // DESKTOP VIEW
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filters
                  _buildFilters(),
                  const SizedBox(height: 24),

                  // Overall stats
                  _buildOverallStats(),
                  const SizedBox(height: 32),

                  // Branch comparison
                  const Text(
                    'Branch Performance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontAll,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBranchComparison(),
                  const SizedBox(height: 32),

                  // Detailed tables
                  if (_selectedBranch == null) ...[
                    const Text(
                      'All Branches Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontAll,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAllBranchesTable(),
                  ] else ...[
                    Text(
                      '${_selectedBranch!.name} Details',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontAll,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBranchDetailsTable(_selectedBranch!),
                  ],
                ],
              ),
            ),
    );
  }

  // DESKTOP WIDGETS

  Widget _buildFilters() {
    return Row(
      children: [
        // Branch filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Organization?>(
              value: _selectedBranch,
              hint: const Text('All Branches'),
              items: [
                const DropdownMenuItem<Organization?>(
                  value: null,
                  child: Text('All Branches'),
                ),
                ..._branches.map((branch) => DropdownMenuItem(
                      value: branch,
                      child: Text(branch.name),
                    )),
              ],
              onChanged: (value) {
                setState(() => _selectedBranch = value);
              },
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Period filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              items: ['Today', 'This Week', 'This Month', 'This Year']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedPeriod = value!);
              },
            ),
          ),
        ),
        const Spacer(),

        // Export button
        OutlinedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Export Report'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export feature coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOverallStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard(
          title: 'Active Branches',
          value: '${_branches.length}',
          icon: Icons.store,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Total Items',
          value: '$_totalItems',
          icon: Icons.inventory,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Total Sold',
          value: '$_totalSold',
          icon: Icons.shopping_cart,
          color: Colors.purple,
        ),
        _buildStatCard(
          title: 'Total Spoilage',
          value: '$_totalSpoilage',
          icon: Icons.delete_forever,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Low Stock Alerts',
          value: '$_lowStockCount',
          icon: Icons.warning,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        // Calculate appropriate sizes based on available space
        final padding = availableHeight * 0.12;
        final iconSize = availableHeight * 0.15;
        final valueFontSize = (availableHeight * 0.20).clamp(16.0, 28.0);
        final titleFontSize = (availableHeight * 0.10).clamp(10.0, 13.0);
        
        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(padding * 0.4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: iconSize),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: valueFontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontAll,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: padding * 0.2),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: fontAll,
                        fontSize: titleFontSize,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBranchComparison() {
    if (_branches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No branches to compare',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _branches.map((branch) {
          final stats = _branchStats[branch.id] ?? {};
          final sold = stats['sold'] ?? 0;
          final maxSold = _totalSold > 0 ? _totalSold : 1;
          final percentage = (sold / maxSold * 100).toInt();

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$sold',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: percentage / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                const Color(0xFFEF4848),
                                const Color(0xFFEF4848).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    branch.name,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAllBranchesTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DataTable(
        columns: const [
          DataColumn(
              label: Text('Branch', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Items', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Sold', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Spoilage', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Low Stock', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _branches.map((branch) {
          final stats = _branchStats[branch.id] ?? {};

          return DataRow(cells: [
            DataCell(Text(branch.name)),
            DataCell(Text('${stats['itemCount'] ?? 0}')),
            DataCell(Text('${stats['sold'] ?? 0}')),
            DataCell(Text('${stats['spoilage'] ?? 0}')),
            DataCell(
              Row(
                children: [
                  if ((stats['lowStock'] ?? 0) > 0)
                    const Icon(Icons.warning, color: Colors.orange, size: 16),
                  Text('${stats['lowStock'] ?? 0}'),
                ],
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: branch.isActive ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  branch.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: branch.isActive ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildBranchDetailsTable(Organization branch) {
    final items = _branchItems[branch.id] ?? [];

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No items found for this branch'),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Sold', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Spoilage', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: items.map((item) {
          final isLowStock = item.stock <= item.criticalLevel;

          return DataRow(cells: [
            DataCell(Text(item.name)),
            DataCell(
              Row(
                children: [
                  if (isLowStock)
                    const Icon(Icons.warning, color: Colors.orange, size: 16),
                  Text('${item.stock}'),
                ],
              ),
            ),
            DataCell(Text('${item.sold}')),
            DataCell(Text('${item.spoilage}')),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLowStock ? Colors.orange.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isLowStock ? 'Low Stock' : 'OK',
                  style: TextStyle(
                    color: isLowStock ? Colors.orange : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  // MOBILE WIDGETS

  Widget _buildMobileFilters() {
    return Column(
      children: [
        // Branch filter
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Organization?>(
              value: _selectedBranch,
              isExpanded: true,
              hint: const Text('All Branches'),
              items: [
                const DropdownMenuItem<Organization?>(
                  value: null,
                  child: Text('All Branches'),
                ),
                ..._branches.map((branch) => DropdownMenuItem(
                      value: branch,
                      child: Text(branch.name),
                    )),
              ],
              onChanged: (value) {
                setState(() => _selectedBranch = value);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Period filter
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              isExpanded: true,
              items: ['Today', 'This Week', 'This Month', 'This Year']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedPeriod = value!);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMobileStatCard(
                title: 'Branches',
                value: '${_branches.length}',
                icon: Icons.store,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMobileStatCard(
                title: 'Items',
                value: '$_totalItems',
                icon: Icons.inventory,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMobileStatCard(
                title: 'Sold',
                value: '$_totalSold',
                icon: Icons.shopping_cart,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMobileStatCard(
                title: 'Spoilage',
                value: '$_totalSpoilage',
                icon: Icons.delete_forever,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMobileStatCard(
          title: 'Low Stock Alerts',
          value: '$_lowStockCount',
          icon: Icons.warning,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildMobileStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontAll,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: fontAll,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBranchComparison() {
    if (_branches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No branches to compare',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _branches.map((branch) {
          final stats = _branchStats[branch.id] ?? {};
          final sold = stats['sold'] ?? 0;
          final maxSold = _totalSold > 0 ? _totalSold : 1;
          final percentage = (sold / maxSold * 100).toInt();

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$sold',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: percentage / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                const Color(0xFFEF4848),
                                const Color(0xFFEF4848).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    branch.name,
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileBranchList() {
    return Column(
      children: _branches.map((branch) {
        final stats = _branchStats[branch.id] ?? {};

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      branch.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontAll,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: branch.isActive
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      branch.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: branch.isActive ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMobileStat('Items', '${stats['itemCount'] ?? 0}'),
                  _buildMobileStat('Sold', '${stats['sold'] ?? 0}'),
                  _buildMobileStat('Spoilage', '${stats['spoilage'] ?? 0}'),
                  _buildMobileStat('Low Stock', '${stats['lowStock'] ?? 0}',
                      hasWarning: (stats['lowStock'] ?? 0) > 0),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileStat(String label, String value, {bool hasWarning = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasWarning)
              const Icon(Icons.warning, color: Colors.orange, size: 14),
            if (hasWarning) const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBranchDetails(Organization branch) {
    final items = _branchItems[branch.id] ?? [];

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No items found for this branch'),
        ),
      );
    }

    return Column(
      children: items.map((item) {
        final isLowStock = item.stock <= item.criticalLevel;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontAll,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLowStock
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isLowStock ? 'Low Stock' : 'OK',
                      style: TextStyle(
                        color: isLowStock ? Colors.orange : Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMobileStat('Stock', '${item.stock}', hasWarning: isLowStock),
                  _buildMobileStat('Sold', '${item.sold}'),
                  _buildMobileStat('Spoilage', '${item.spoilage}'),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}