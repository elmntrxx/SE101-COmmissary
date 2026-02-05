// lib/screens/requests/requests_page.dart
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_globals.dart';
import '../../database/app_database.dart';
import '../../services/realtime_stock_request_service.dart';
import '../../widgets/realtime_status_indicator.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  late AppDatabase db;
  int? currentUserId;
  int? commissaryId;
  String? _commissaryCloudId;

  @override
  void initState() {
    super.initState();
    db = database;
    _loadContext();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContext() async {
    debugPrint('RequestsPage: loading context...');
    final user = AppGlobals.instance.authService.currentUser;
    debugPrint('RequestsPage: currentUser=${user?.id} orgId=${user?.organizationId}');
    if (user != null) {
      if (mounted) {
        setState(() {
          currentUserId = user.id;
          commissaryId = user.organizationId;
        });
      }

      try {
        final org = await db.organizationsDao.getOrganizationById(user.organizationId);
        debugPrint('RequestsPage: org cloudId=${org?.cloudId}');
        if (org?.cloudId != null) {
          _commissaryCloudId = org!.cloudId;
          debugPrint('RequestsPage: attaching realtime cloudId=$_commissaryCloudId');
          await realtimeStockRequestService.attach(_commissaryCloudId!);
          realtimeStockRequestService.statusStream.listen((status) {
            debugPrint('RequestsPage: realtime status=$status');
          });
          realtimeStockRequestService.eventStream.listen((event) {
            debugPrint('RequestsPage: realtime event cloudId=${event.cloudId} status=${event.status}');
          });
        }
      } catch (e) {
        debugPrint('RequestsPage: WARN Failed to initialize realtime: $e');
      }
    } else {
      debugPrint('RequestsPage: no currentUser yet');
    }
  }


  @override
  void dispose() {
    realtimeStockRequestService.detach();
    super.dispose();
  }

  Future<void> _approveRequest(StockReplenishmentRequest request) async {
    if (currentUserId == null) return;

    // Show confirmation dialog with quantity adjustment?
    // For now, simple confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Request'),
        content: Text(
          'Approve request for ${request.quantityRequested} units?\n\nThis will deduct from commissary stock and add to branch stock immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve & Transfer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 1. Check commissary stock
      final item = await db.itemsDao.getItemById(request.itemId);
      if (item == null) {
        throw Exception(
          'Item not found in commissary (itemId: ${request.itemId})',
        );
      }

      print(
        '📦 Item found: ${item.name} (id=${item.id}, cloudId=${item.cloudId})',
      );
      print(
        '   Current stock: ${item.stock}, Requested: ${request.quantityRequested}',
      );

      if (item.stock < request.quantityRequested) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Insufficient stock! Have: ${item.stock}, Requested: ${request.quantityRequested}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 2. Reduce commissary stock
      final newStock = item.stock - request.quantityRequested;
      final rowsUpdated = await db.itemsDao.updateStock(
        request.itemId,
        newStock,
      );
      print('📦 updateStock returned: $rowsUpdated rows updated');
      print(
        '📦 Reduced commissary stock for item ${item.name}: ${item.stock} → $newStock',
      );

      // Verify the update worked
      final updatedItem = await db.itemsDao.getItemById(request.itemId);
      print(
        '📦 Verification - Item after update: stock=${updatedItem?.stock}, needsSync=${updatedItem?.needsSync}',
      );

      // 3. Add to branch stock
      // Find existing stock record for branch
      final branchStock = await db.branchItemStockDao.getStockForItem(
        request.franchiseeId,
        request.itemId,
      );

      if (branchStock != null) {
        // Update existing
        await db.branchItemStockDao.receiveItems(
          branchStock.id,
          request.quantityRequested,
        );
      } else {
        // Create new
        await db.branchItemStockDao.createStock(
          BranchItemStockCompanion(
            organizationId: Value(request.franchiseeId),
            itemId: Value(request.itemId),
            stock: Value(request.quantityRequested),
            sold: const Value(0),
            spoilage: const Value(0),
            lastReceivedAt: Value(DateTime.now()),
            lastReceivedQuantity: Value(request.quantityRequested),
          ),
        );
      }

      // 4. Mark request as approved
      await db.stockReplenishmentRequestsDao.approveRequest(
        requestId: request.id,
        reviewedBy: currentUserId!,
        commissaryNotes: 'Auto-approved by commissary app',
      );

      // 5. Auto-sync to push changes to cloud
      try {
        print('🔄 Auto-syncing after approval...');
        await syncService.performFullSync();
        print('✅ Approval synced to cloud');
      } catch (syncError) {
        print('⚠️ Sync failed (will retry later): $syncError');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Request approved and stock transferred'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error approving request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectRequest(StockReplenishmentRequest request) async {
    if (currentUserId == null) return;

    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await db.stockReplenishmentRequestsDao.rejectRequest(
        requestId: request.id,
        reviewedBy: currentUserId!,
        reason: reasonController.text.trim(),
      );

      // Auto-sync to push rejection to cloud
      try {
        print('🔄 Auto-syncing after rejection...');
        await syncService.performFullSync();
        print('✅ Rejection synced to cloud');
      } catch (syncError) {
        print('⚠️ Sync failed (will retry later): $syncError');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error rejecting request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildTab(String label, int index) {
    bool active = selectedTab == index;
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setSelectedTab(index),
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
    if (commissaryId == null) {
      return const Scaffold(
        backgroundColor: Color.fromRGBO(238, 238, 238, 1),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Replenishment Requests'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: RealtimeStatusIndicator(
              service: realtimeStockRequestService,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // Trigger sync and refresh
              try {
                await syncService.performFullSync();
              } catch (e) {
                print('Sync error: $e');
              }
              if (mounted) setState(() {}); 
            },
          ),
        ],
      ),
      body: StreamBuilder<List<StockReplenishmentRequest>>(
        stream: db.stockReplenishmentRequestsDao.watchPendingRequests(commissaryId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!;

          if (requests.isEmpty) {
            return const Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildTab('Pending Requests', 0),
                        _buildTab('Request History', 1),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: selectedTab == 0
                          ? _buildPendingRequestsTab()
                          : _buildHistoryTab(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestsTab() {
    return StreamBuilder<List<StockReplenishmentRequest>>(
      stream: db.stockReplenishmentRequestsDao.watchPendingRequests(
        commissaryId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allRequests = snapshot.data!;

        // Filter requests based on search
        final requests = allRequests.where((req) {
          if (searchQuery.isEmpty) return true;
          return req.id.toString().contains(searchQuery) ||
              req.quantityRequested.toString().contains(searchQuery);
        }).toList();

        if (requests.isEmpty) {
          return emptyTables(
            message: allRequests.isEmpty
                ? 'No pending requests. All caught up!'
                : 'No requests match your search.',
            onAddPressed: null,
            buttonType: EmptyButtonType.none,
          );
        }

        return FutureBuilder<List<List<dynamic>>>(
          future: _buildRequestRows(requests),
          builder: (context, rowSnapshot) {
            if (!rowSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return buildUniversalTable(
              headers: [
                'Request ID',
                'Branch',
                'Item',
                'Qty Requested',
                'Stock Available',
                'Date',
                'Status',
                '',
              ],
              rows: rowSnapshot.data!,
              smallHeaderWidth: 20,
              largeHeaderWidth: 60,
            );
          },
        );
      },
    );
  }

  Future<List<List<dynamic>>> _buildRequestRows(
    List<StockReplenishmentRequest> requests,
  ) async {
    List<List<dynamic>> rows = [];

    for (final req in requests) {
      final org = await db.organizationsDao.getOrganizationById(
        req.franchiseeId,
      );
      final item = await db.itemsDao.getItemById(req.itemId);

      rows.add([
        Text('#${req.id}', style: const TextStyle(fontFamily: fontAll)),
        Text(
          org?.name ?? 'Unknown Branch',
          style: const TextStyle(fontFamily: fontAll),
        ),
        Text(
          item?.name ?? 'Unknown Item',
          style: const TextStyle(fontFamily: fontAll),
        ),
        Text(
          '${req.quantityRequested}',
          style: const TextStyle(
            fontFamily: fontAll,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${item?.stock ?? 0}',
          style: TextStyle(
            fontFamily: fontAll,
            color: (item?.stock ?? 0) < req.quantityRequested
                ? Colors.red
                : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          DateFormat('MMM d, yyyy').format(req.createdAt),
          style: const TextStyle(fontFamily: fontAll, fontSize: 12),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Pending',
            style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              tooltip: 'Approve',
              onPressed: () => _approveRequest(req),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
              tooltip: 'Reject',
              onPressed: () => _rejectRequest(req),
            ),
          ],
        ),
      ]);
    }

    return rows;
  }

  Widget _buildHistoryTab() {
    return StreamBuilder<List<StockReplenishmentRequest>>(
      stream: db.stockReplenishmentRequestsDao.watchAllRequests(commissaryId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter to show only non-pending (approved/rejected) requests
        final allRequests = snapshot.data!
            .where((r) => r.status != 'pending')
            .toList();

        // Filter requests based on search
        final requests = allRequests.where((req) {
          if (searchQuery.isEmpty) return true;
          return req.id.toString().contains(searchQuery) ||
              req.status.toLowerCase().contains(searchQuery);
        }).toList();

        if (requests.isEmpty) {
          return emptyTables(
            message: allRequests.isEmpty
                ? 'No request history yet.'
                : 'No requests match your search.',
            onAddPressed: null,
            buttonType: EmptyButtonType.none,
          );
        }

        return FutureBuilder<List<List<dynamic>>>(
          future: _buildHistoryRows(requests),
          builder: (context, rowSnapshot) {
            if (!rowSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return buildUniversalTable(
              headers: [
                'Request ID',
                'Branch',
                'Item',
                'Qty Requested',
                'Date',
                'Reviewed',
                'Status',
                '',
              ],
              rows: rowSnapshot.data!,
              smallHeaderWidth: 20,
              largeHeaderWidth: 60,
            );
          },
        );
      },
    );
  }

  Future<List<List<dynamic>>> _buildHistoryRows(
    List<StockReplenishmentRequest> requests,
  ) async {
    List<List<dynamic>> rows = [];

    for (final req in requests) {
      final org = await db.organizationsDao.getOrganizationById(
        req.franchiseeId,
      );
      final item = await db.itemsDao.getItemById(req.itemId);

      final isApproved = req.status == 'approved';

      rows.add([
        Text('#${req.id}', style: const TextStyle(fontFamily: fontAll)),
        Text(
          org?.name ?? 'Unknown Branch',
          style: const TextStyle(fontFamily: fontAll),
        ),
        Text(
          item?.name ?? 'Unknown Item',
          style: const TextStyle(fontFamily: fontAll),
        ),
        Text(
          '${req.quantityRequested}',
          style: const TextStyle(fontFamily: fontAll),
        ),
        Text(
          DateFormat('MMM d, yyyy').format(req.createdAt),
          style: const TextStyle(fontFamily: fontAll, fontSize: 12),
        ),
        Text(
          req.reviewedAt != null
              ? DateFormat('MMM d, yyyy').format(req.reviewedAt!)
              : '-',
          style: const TextStyle(fontFamily: fontAll, fontSize: 12),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isApproved ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isApproved ? 'Approved' : 'Rejected',
            style: TextStyle(
              color: isApproved ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox.shrink(), // Empty cell for actions column
      ]);
    }

    return rows;
  }
}
