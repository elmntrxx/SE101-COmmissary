// lib/screens/home/home.dart
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
import '../inventory_management/inventory_management_page.dart';
import '../ingredients/ingredients_page.dart';
import '../requests/requests_page.dart';
import '../settings/settings_page.dart';

class HomeScreen extends StatefulWidget {
  final UserData signedInUser;

  const HomeScreen({super.key, required this.signedInUser});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late AppDatabase _db;
  late ConnectivityService _connectivityService;
  
  Widget? currentPage;
  int selectedIndex = 0;
  bool isSideBarOpen = false;
  bool showLabels = false;
  bool isOnline = true;
  SyncStatus syncStatus = SyncStatus.synced;

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
    _connectivityService.connectionStream.listen((online) {
      setState(() {
        isOnline = online;
        syncStatus = online ? SyncStatus.synced : SyncStatus.offline;
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
        'page': InventoryManagementPage(
          organizationId: widget.signedInUser.organizationId,
          commissaryId: widget.signedInUser.organizationId,
          organizationName: 'Inventory Management',
        ),
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

  void toggleSidebar() {
    setState(() {
      isSideBarOpen = !isSideBarOpen;
      showLabels = false;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && isSideBarOpen) {
        setState(() => showLabels = true);
      }
    });
  }

  void switchPage(int index) {
    setState(() {
      selectedIndex = index;
      currentPage = menuItems[index]['page'];
      isSideBarOpen = false;
      showLabels = false;
    });
  }

  Future<void> handleLogout() async {
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

  Future<void> triggerManualSync() async {
    setState(() {
      syncStatus = SyncStatus.syncing;
    });

    // Simulate sync operation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        syncStatus = isOnline ? SyncStatus.synced : SyncStatus.offline;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're on mobile or desktop based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    if (isMobile) {
      return _buildMobileScaffold();
    } else {
      return _buildDesktopScaffold();
    }
  }

  // Mobile Scaffold
  Widget _buildMobileScaffold() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade400,
        elevation: 3,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          menuItems.isNotEmpty ? menuItems[selectedIndex]['label'] : '',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: fontAll,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Connection Status Indicator
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ConnectionStatusIndicator(
              isOnline: isOnline,
              syncStatus: syncStatus,
              onSyncPressed: triggerManualSync,
            ),
          ),
          
          // Profile Menu with Logout
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 28,
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  handleLogout();
                } else if (value == 'profile') {
                  // Navigate to profile page
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        widget.signedInUser.username,
                        style: const TextStyle(fontFamily: fontAll),
                      ),
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
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: fontAll,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: currentPage ?? const SizedBox.shrink(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red.shade400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(imageAll, height: 60),
                  const SizedBox(height: 10),
                  const Text(
                    "Inventory System",
                    style: TextStyle(
                      fontFamily: fontAll,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Menu items
            ...List.generate(menuItems.length, (index) {
              final bool isActive = selectedIndex == index;

              return ListTile(
                leading: Icon(
                  menuItems[index]["icon"],
                  color: isActive ? Colors.red : Colors.black,
                ),
                title: Text(
                  menuItems[index]["label"],
                  style: TextStyle(
                    color: isActive ? Colors.red : Colors.black,
                    fontFamily: fontAll,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                tileColor: isActive ? Colors.red.withValues(alpha: 0.08) : null,
                selected: isActive,
                onTap: () {
                  Navigator.pop(context);
                  switchPage(index);
                },
              );
            }),
            // Logout button in drawer
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red, fontFamily: fontAll),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                handleLogout();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Desktop Scaffold
  Widget _buildDesktopScaffold() {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.red.shade400,
        elevation: 3,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 35),
          onPressed: toggleSidebar,
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imageAll, height: 30),
            const SizedBox(width: 10),
            const Text(
              "Inventory System",
              style: TextStyle(
                fontFamily: fontAll,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          // Connection Status Indicator
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ConnectionStatusIndicator(
              isOnline: isOnline,
              syncStatus: syncStatus,
              onSyncPressed: triggerManualSync,
            ),
          ),
          
          // Profile Menu with Logout
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 28,
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  handleLogout();
                } else if (value == 'profile') {
                  // Navigate to profile page
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        widget.signedInUser.username,
                        style: const TextStyle(fontFamily: fontAll),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    widget.signedInUser.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: fontAll,
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: fontAll,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          
          // Divider
          Container(width: 1, color: Colors.grey.shade300),
          
          // Main content
          Expanded(
            child: currentPage ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSideBarOpen ? 200 : 70,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          ...List.generate(menuItems.length, (index) {
            return Column(
              children: [
                _buildSideBarButton(
                  icon: menuItems[index]["icon"],
                  label: menuItems[index]["label"],
                  index: index,
                ),
                const SizedBox(height: 5),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSideBarButton({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool active = selectedIndex == index;

    return InkWell(
      onTap: () => switchPage(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: active
            ? BoxDecoration(color: Colors.white.withOpacity(0.25))
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: 25,
              color: active ? Colors.red : Colors.grey.shade900,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: showLabels
                  ? Row(
                      children: [
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: fontAll,
                            fontSize: 16,
                            color: active ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200 ? 4 : 
                                      constraints.maxWidth > 800 ? 2 : 1;
              
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
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
              );
            },
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
                onTap: () => switchPage(1), // Navigate to Branches
              ),
              _buildQuickAction(
                icon: Icons.add_box,
                label: 'Add Item',
                onTap: () => switchPage(2), // Navigate to Inventory
              ),
              _buildQuickAction(
                icon: Icons.person_add,
                label: 'Add Branch Admin',
                onTap: () => switchPage(1), // Navigate to Branches
              ),
              _buildQuickAction(
                icon: Icons.assessment,
                label: 'View Reports',
                onTap: () => switchPage(5), // Navigate to Reports
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