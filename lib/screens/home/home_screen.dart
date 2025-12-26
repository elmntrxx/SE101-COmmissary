// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_globals.dart';
import '../../database/app_database.dart';
import '../../services/supabase_auth_service.dart';
import '../../services/connectivity_service.dart';
import '../../widgets/connection_status_indicator.dart';
import '../../utils/sync_status.dart';
import '../../utils/design_constants.dart';

// Import pages
import '../branches/branches_page.dart';
import '../reports/reports_page.dart';
import '../inventory/inventory_page.dart';
import '../ingredients/ingredients_page.dart';
import '../requests/requests_page.dart';
import '../settings/settings_page.dart';

class HomeScreen extends StatefulWidget {
  final UserData signedInUser;

  const HomeScreen({super.key, required this.signedInUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppDatabase _db;
  late ConnectivityService _connectivityService;
  
  Widget? currentPage;
  int selectedIndex = 0;
  bool isSideBarOpen = true;
  bool _isOnline = true;
  SyncStatus _syncStatus = SyncStatus.synced;

  List<Map<String, dynamic>> menuItems = [];

  @override
  void initState() {
    super.initState();
    _db = database;
    _initConnectivity();
    _loadMenuItems();
  }

  void _initConnectivity() {
    _connectivityService = ConnectivityService();
    _connectivityService.connectionStream.listen((isOnline) {
      setState(() {
        _isOnline = isOnline;
        _syncStatus = isOnline ? SyncStatus.synced : SyncStatus.offline;
      });
    });
  }

  void _loadMenuItems() {
    menuItems = [
      {
        'icon': Icons.dashboard,
        'label': 'Dashboard',
        'page': _buildDashboard(),
      },
      {
        'icon': Icons.store,
        'label': 'Branches',
        'page': const BranchesPage(),
      },
      {
        'icon': Icons.inventory_2,
        'label': 'Inventory',
        'page': const InventoryPage(),
      },
      {
        'icon': Icons.restaurant_menu,
        'label': 'Ingredients',
        'page': const IngredientsPage(),
      },
      {
        'icon': Icons.swap_horiz,
        'label': 'Requests',
        'page': const RequestsPage(),
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Reports',
        'page': const ReportsPage(),
      },
      {
        'icon': Icons.settings,
        'label': 'Settings',
        'page': const SettingsPage(),
      },
    ];

    currentPage = menuItems[0]['page'];
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  void _switchPage(int index) {
    setState(() {
      selectedIndex = index;
      currentPage = menuItems[index]['page'];
    });
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Logout', style: TextStyle(fontFamily: fontAll)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: fontAll),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('loggedInUserId');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(),
                
                // Content area
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: currentPage ?? const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSideBarOpen ? 250 : 70,
      decoration: const BoxDecoration(
        color: Color(0xFFEF4848),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo header
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.store, color: Colors.white, size: 32),
                if (isSideBarOpen) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Commissary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontAll,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const Divider(color: Colors.white30, height: 1),
          
          // Menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = selectedIndex == index;
                
                return _buildMenuItem(
                  icon: item['icon'],
                  label: item['label'],
                  isSelected: isSelected,
                  onTap: () => _switchPage(index),
                );
              },
            ),
          ),
          
          // Collapse button
          IconButton(
            icon: Icon(
              isSideBarOpen ? Icons.chevron_left : Icons.chevron_right,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => isSideBarOpen = !isSideBarOpen);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: isSideBarOpen
            ? Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: fontAll,
                ),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Page title
          Text(
            menuItems.isNotEmpty ? menuItems[selectedIndex]['label'] : '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
            ),
          ),
          
          const Spacer(),
          
          // Connection status
          ConnectionStatusIndicator(
            isOnline: _isOnline,
            syncStatus: _syncStatus,
          ),
          
          const SizedBox(width: 16),
          
          // User menu
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFEF4848),
                  child: Text(
                    widget.signedInUser.username[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.signedInUser.username,
                  style: const TextStyle(fontFamily: fontAll),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 12),
                    Text(widget.signedInUser.email),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Welcome back, ${widget.signedInUser.username}!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here\'s an overview of your commissary operations.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontFamily: fontAll,
            ),
          ),
          const SizedBox(height: 32),
          
          // Stats cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                title: 'Active Branches',
                value: '0',
                icon: Icons.store,
                color: Colors.blue,
              ),
              _buildStatCard(
                title: 'Total Items',
                value: '0',
                icon: Icons.inventory,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Pending Requests',
                value: '0',
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
              _buildStatCard(
                title: 'Low Stock Alerts',
                value: '0',
                icon: Icons.warning,
                color: Colors.red,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Quick actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildQuickAction(
                icon: Icons.add_business,
                label: 'Add Branch',
                onTap: () => _switchPage(1), // Navigate to Branches
              ),
              _buildQuickAction(
                icon: Icons.add_box,
                label: 'Add Item',
                onTap: () => _switchPage(2), // Navigate to Inventory
              ),
              _buildQuickAction(
                icon: Icons.person_add,
                label: 'Add Branch Admin',
                onTap: () => _switchPage(1), // Navigate to Branches
              ),
              _buildQuickAction(
                icon: Icons.assessment,
                label: 'View Reports',
                onTap: () => _switchPage(5), // Navigate to Reports
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontAll,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontFamily: fontAll,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFEF4848)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: fontAll,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
