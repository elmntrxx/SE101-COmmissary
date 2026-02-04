// lib/screens/requests/requests_page.dart
import 'dart:async';
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

class _RequestsPageState extends State<RequestsPage> with WidgetsBindingObserver {
  late AppDatabase db;
  int? currentUserId;
  int? commissaryId;
  String? _commissaryCloudId;
  StreamSubscription<StockRequestEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    db = database;
    _loadContext();
  }

  Future<void> _loadContext() async {
    final user = AppGlobals.instance.authService.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          currentUserId = user.id;
          commissaryId = user.organizationId;
        });
      }
      
      // Initialize realtime after we have commissaryId
      await _initializeRealtime();
    }
  }

  Future<void> _initializeRealtime() async {
    if (commissaryId == null) return;
    
    try {
      final org = await db.organizationsDao.getOrganizationById(commissaryId!);
      if (org?.cloudId != null) {
        _commissaryCloudId = org!.cloudId;
        
        // Attach to realtime service
        await realtimeStockRequestService.attach(_commissaryCloudId!);
        
        // Listen for new request events
        _eventSubscription = realtimeStockRequestService.eventStream.listen((event) {
          print('📬 New stock request received: ${event.cloudId}');
          // The StreamBuilder will automatically update, but we can trigger a refresh
          if (mounted) {
            setState(() {}); // Trigger rebuild to update any counters/badges
          }
        });
      }
    } catch (e) {
      print('⚠️ Failed to initialize realtime: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('📱 App lifecycle state changed: $state');
    switch (state) {
      case AppLifecycleState.paused:
        // Only pause when app truly goes to background
        realtimeStockRequestService.pause();
        break;
      case AppLifecycleState.resumed:
        realtimeStockRequestService.resume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Don't pause on inactive - this triggers too easily
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _eventSubscription?.cancel();
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
            'Approve request for ${request.quantityRequested} units?\n\nThis will deduct from commissary stock and add to branch stock immediately.'),
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
        throw Exception('Item not found in commissary (itemId: ${request.itemId})');
      }

      print('📦 Item found: ${item.name} (id=${item.id}, cloudId=${item.cloudId})');
      print('   Current stock: ${item.stock}, Requested: ${request.quantityRequested}');

      if (item.stock < request.quantityRequested) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Insufficient stock! Have: ${item.stock}, Requested: ${request.quantityRequested}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 2. Reduce commissary stock
      final newStock = item.stock - request.quantityRequested;
      final rowsUpdated = await db.itemsDao.updateStock(request.itemId, newStock);
      print('📦 updateStock returned: $rowsUpdated rows updated');
      print('📦 Reduced commissary stock for item ${item.name}: ${item.stock} → $newStock');

      // Verify the update worked
      final updatedItem = await db.itemsDao.getItemById(request.itemId);
      print('📦 Verification - Item after update: stock=${updatedItem?.stock}, needsSync=${updatedItem?.needsSync}');

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
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
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
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (commissaryId == null) {
      return const Center(child: CircularProgressIndicator());
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('No pending requests', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Request #${req.id}',
                              style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, h:mm a').format(req.createdAt),
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<Organization?>(
                                  future: db.organizationsDao.getOrganizationById(req.franchiseeId),
                                  builder: (context, orgSnapshot) {
                                    return Text(
                                      orgSnapshot.data?.name ?? 'Unknown Branch',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                FutureBuilder<Item?>(
                                  future: db.itemsDao.getItemById(req.itemId),
                                  builder: (context, itemSnapshot) {
                                    final item = itemSnapshot.data;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Item: ${item?.name ?? 'Unknown'}', style: const TextStyle(fontSize: 15)),
                                        if (item != null)
                                          Text('Current Commissary Stock: ${item.stock}', style: TextStyle(color: item.stock < req.quantityRequested ? Colors.red : Colors.green, fontSize: 12)),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                Text('Requested Qty: ${req.quantityRequested}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () => _approveRequest(req),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Approve'),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: () => _rejectRequest(req),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                child: const Text('Reject'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
