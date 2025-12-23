// lib/screens/branches/branches_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../app_globals.dart';
import '../../database/app_database.dart';
import '../../utils/design_constants.dart';

/// Branches Page - Manage franchisee branches and their admins
/// Commissary can:
/// - Create new branches (franchisees)
/// - Create branch admin users scoped to a specific branch
/// - View all branches and their status
class BranchesPage extends StatefulWidget {
  const BranchesPage({super.key});

  @override
  State<BranchesPage> createState() => _BranchesPageState();
}

class _BranchesPageState extends State<BranchesPage> {
  late AppDatabase _db;
  List<Organization> _branches = [];
  Map<int, List<User>> _branchUsers = {};
  Organization? _commissary;
  bool _isLoading = true;
  int _selectedTab = 0; // 0 = Branches, 1 = Branch Admins

  final _uuid = const Uuid();

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
      _commissary = await _db.organizationsDao.getCommissary();
      if (_commissary == null) {
        print('⚠️ No commissary found');
        setState(() => _isLoading = false);
        return;
      }

      // Get all franchisees under this commissary
      _branches = await _db.organizationsDao.getFranchisees(_commissary!.cloudId);

      // Get users for each branch
      _branchUsers = {};
      for (final branch in _branches) {
        final users = await _db.usersDao.getUsersByOrganization(branch.id);
        _branchUsers[branch.id] = users;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error loading branches: $e');
      setState(() => _isLoading = false);
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ============================================================================
  // CREATE BRANCH
  // ============================================================================

  void _showCreateBranchDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.add_business, color: Color(0xFFEF4848)),
            SizedBox(width: 12),
            Text('Create New Branch', style: TextStyle(fontFamily: fontAll)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Branch Name *',
                    hintText: 'e.g., Chicken Joo - SM Mall',
                    prefixIcon: Icon(Icons.store),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4848),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Branch name is required')),
                );
                return;
              }

              await _createBranch(
                name: nameController.text.trim(),
                address: addressController.text.trim(),
                phone: phoneController.text.trim(),
                email: emailController.text.trim(),
              );

              Navigator.pop(context);
            },
            child: const Text('Create Branch'),
          ),
        ],
      ),
    );
  }

  Future<void> _createBranch({
    required String name,
    String? address,
    String? phone,
    String? email,
  }) async {
    try {
      await _db.organizationsDao.createOrganization(
        OrganizationsCompanion.insert(
          cloudId: _uuid.v4(),
          name: name,
          type: 'franchisee',
          address: Value(address),
          phone: Value(phone),
          email: Value(email),
          parentCommissaryId: Value(_commissary!.cloudId),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Branch "$name" created successfully')),
      );

      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create branch: $e')),
      );
    }
  }

  // ============================================================================
  // CREATE BRANCH ADMIN
  // ============================================================================

  void _showCreateBranchAdminDialog({Organization? preselectedBranch}) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    Organization? selectedBranch = preselectedBranch;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.person_add, color: Color(0xFFEF4848)),
              SizedBox(width: 12),
              Text('Create Branch Admin', style: TextStyle(fontFamily: fontAll)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Branch selector
                  DropdownButtonFormField<Organization>(
                    value: selectedBranch,
                    decoration: const InputDecoration(
                      labelText: 'Select Branch *',
                      prefixIcon: Icon(Icons.store),
                    ),
                    items: _branches.map((branch) {
                      return DropdownMenuItem(
                        value: branch,
                        child: Text(branch.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedBranch = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password *',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This admin will only be able to access data for their assigned branch.',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4848),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (selectedBranch == null ||
                    nameController.text.trim().isEmpty ||
                    emailController.text.trim().isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                await _createBranchAdmin(
                  branch: selectedBranch!,
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                  password: passwordController.text,
                );

                Navigator.pop(context);
              },
              child: const Text('Create Admin'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBranchAdmin({
    required Organization branch,
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      // Get Branch Admin role
      final branchAdminRole = await _db.rolesDao.getRoleByName('Branch Admin');
      if (branchAdminRole == null) {
        throw Exception('Branch Admin role not found');
      }

      // Create user in local database
      await _db.into(_db.users).insert(
        UsersCompanion.insert(
          cloudId: _uuid.v4(),
          username: name,
          email: email,
          phone: Value(phone),
          passwordHash: _hashPassword(password),
          organizationId: branch.id,
          roleId: branchAdminRole.id,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Branch admin "$name" created for ${branch.name}')),
      );

      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create admin: $e')),
      );
    }
  }

  // ============================================================================
  // UI BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with actions
          Row(
            children: [
              // Tabs
              _buildTab('Branches', 0),
              const SizedBox(width: 16),
              _buildTab('Branch Admins', 1),
              const Spacer(),
              // Action buttons
              if (_selectedTab == 0)
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_business),
                  label: const Text('Add Branch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4848),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _showCreateBranchDialog,
                ),
              if (_selectedTab == 1)
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Branch Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4848),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _branches.isEmpty ? null : () => _showCreateBranchAdminDialog(),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedTab == 0
                    ? _buildBranchesTab()
                    : _buildAdminsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEF4848) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFEF4848) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: fontAll,
          ),
        ),
      ),
    );
  }

  Widget _buildBranchesTab() {
    if (_branches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.store_mall_directory,
        title: 'No Branches Yet',
        subtitle: 'Create your first branch to get started',
        buttonLabel: 'Create Branch',
        onPressed: _showCreateBranchDialog,
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _branches.length,
      itemBuilder: (context, index) {
        final branch = _branches[index];
        final users = _branchUsers[branch.id] ?? [];

        return _buildBranchCard(branch, users);
      },
    );
  }

  Widget _buildBranchCard(Organization branch, List<User> users) {
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.store, color: Colors.green),
              ),
              const Spacer(),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            branch.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (branch.address != null)
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    branch.address!,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.people, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${users.length} users',
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.person_add, size: 20),
                tooltip: 'Add Admin',
                onPressed: () => _showCreateBranchAdminDialog(preselectedBranch: branch),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminsTab() {
    final allAdmins = <Map<String, dynamic>>[];
    for (final branch in _branches) {
      final users = _branchUsers[branch.id] ?? [];
      for (final user in users) {
        allAdmins.add({'user': user, 'branch': branch});
      }
    }

    if (allAdmins.isEmpty) {
      return _buildEmptyState(
        icon: Icons.admin_panel_settings,
        title: 'No Branch Admins Yet',
        subtitle: 'Create a branch first, then add admins',
        buttonLabel: _branches.isEmpty ? 'Create Branch' : 'Add Admin',
        onPressed: _branches.isEmpty
            ? _showCreateBranchDialog
            : () => _showCreateBranchAdminDialog(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Branch', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: allAdmins.map((data) {
          final user = data['user'] as User;
          final branch = data['branch'] as Organization;

          return DataRow(cells: [
            DataCell(Text(user.username)),
            DataCell(Text(user.email)),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(branch.name, style: TextStyle(color: Colors.blue.shade700)),
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isActive ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: user.isActive ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    tooltip: 'Edit',
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      user.isActive ? Icons.block : Icons.check_circle,
                      size: 18,
                      color: user.isActive ? Colors.red : Colors.green,
                    ),
                    tooltip: user.isActive ? 'Deactivate' : 'Activate',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(buttonLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4848),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
