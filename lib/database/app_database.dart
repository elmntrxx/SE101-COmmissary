// lib/database/app_database.dart
import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// Tables
import 'tables/organizations.dart';
import 'tables/roles.dart';
import 'tables/users.dart';
import 'tables/categories.dart';
import 'tables/items.dart';
import 'tables/ingredients.dart';
import 'tables/recipe_ingredients.dart';
import 'tables/stock_replenishment_requests.dart';
import 'tables/stock_change_requests.dart';

// DAOs
import 'daos/organizations_dao.dart';
import 'daos/roles_dao.dart';
import 'daos/users_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/items_dao.dart';
import 'daos/ingredients_dao.dart';
import 'daos/stock_replenishment_requests_dao.dart';
import 'daos/stock_change_requests_dao.dart';

part 'app_database.g.dart';

/// Commissary App Database with star topology support
@DriftDatabase(
  tables: [
    Organizations,
    Roles,
    Users,
    Categories,
    Items,
    Ingredients,
    RecipeIngredients,
    StockReplenishmentRequests,
    StockChangeRequests,
  ],
  daos: [
    OrganizationsDao,
    RolesDao,
    UsersDao,
    CategoriesDao,
    ItemsDao,
    IngredientsDao,
    StockReplenishmentRequestsDao,
    StockChangeRequestsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  final bool _seedData;
  static const _uuid = Uuid();

  AppDatabase({bool seedData = true})
      : _seedData = seedData,
        super(_openConnection());

  AppDatabase.test(super.executor) : _seedData = false;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        print('🗄️ Creating commissary database...');
        await m.createAll();
        await _createIndexes();
        if (_seedData) {
          await _seedInitialData();
        }
        print('✅ Database created successfully!');
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Create indexes for optimal performance
  Future<void> _createIndexes() async {
    print('📑 Creating indexes...');

    // Organizations indexes
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_orgs_type ON organizations(type) WHERE is_active = 1');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_orgs_parent ON organizations(parent_commissary_id)');

    // Users indexes
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_users_org ON users(organization_id) WHERE is_active = 1');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)');

    // Items indexes
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_items_org ON items(organization_id) WHERE is_active = 1');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_items_master ON items(master_item_id)');

    // Ingredients indexes
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_ingredients_commissary ON ingredients(commissary_id) WHERE is_active = 1');

    // Requests indexes
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_replenish_status ON stock_replenishment_requests(status)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_changes_status ON stock_change_requests(status)');
  }

  /// Seed initial data for commissary app
  Future<void> _seedInitialData() async {
    print('🌱 Seeding initial data...');

    // Create default roles
    await _seedRoles();

    // Create commissary organization
    await _seedCommissaryOrganization();

    // Create admin user
    await _seedAdminUser();

    print('✅ Initial data seeded!');
  }

  Future<void> _seedRoles() async {
    final existingRoles = await select(roles).get();
    if (existingRoles.isNotEmpty) return;

    final defaultRoles = [
      RolesCompanion.insert(
        cloudId: _uuid.v4(),
        name: 'Commissary Admin',
        description: const Value('Full access to all commissary features'),
        canViewInventory: const Value(true),
        canManageInventory: const Value(true),
        canManageEmployees: const Value(true),
        canManageRoles: const Value(true),
        canViewReports: const Value(true),
        canManageBranches: const Value(true),
        isSystemRole: const Value(true),
      ),
      RolesCompanion.insert(
        cloudId: _uuid.v4(),
        name: 'Branch Admin',
        description: const Value('Manages a single branch'),
        canViewInventory: const Value(true),
        canManageInventory: const Value(true),
        canManageEmployees: const Value(true),
        canManageRoles: const Value(false),
        canViewReports: const Value(true),
        canManageBranches: const Value(false),
        isSystemRole: const Value(true),
      ),
      RolesCompanion.insert(
        cloudId: _uuid.v4(),
        name: 'Employee',
        description: const Value('Basic inventory access'),
        canViewInventory: const Value(true),
        canManageInventory: const Value(false),
        canManageEmployees: const Value(false),
        canManageRoles: const Value(false),
        canViewReports: const Value(false),
        canManageBranches: const Value(false),
        isSystemRole: const Value(true),
      ),
    ];

    for (final role in defaultRoles) {
      await into(roles).insert(role);
    }
    print('   ✓ Default roles created');
  }

  Future<void> _seedCommissaryOrganization() async {
    final existing = await (select(organizations)
          ..where((o) => o.type.equals('commissary')))
        .getSingleOrNull();
    if (existing != null) return;

    await into(organizations).insert(
      OrganizationsCompanion.insert(
        cloudId: _uuid.v4(),
        name: 'Chicken Joo Commissary',
        type: 'commissary',
        address: const Value('Main Office Address'),
        phone: const Value('0000000000'),
        email: const Value('admin@chickenjoo.com'),
      ),
    );
    print('   ✓ Commissary organization created');
  }

  Future<void> _seedAdminUser() async {
    final existingAdmin = await (select(users)
          ..where((u) => u.email.equals('admin@chickenjoo.com')))
        .getSingleOrNull();
    if (existingAdmin != null) return;

    // Get commissary org and admin role
    final commissary = await (select(organizations)
          ..where((o) => o.type.equals('commissary')))
        .getSingle();
    final adminRole = await (select(roles)
          ..where((r) => r.name.equals('Commissary Admin')))
        .getSingle();

    // Hash the password with salt (PBKDF2 format: salt$hash)
    final passwordHash = _hashPassword('admin123');

    await into(users).insert(
      UsersCompanion.insert(
        cloudId: _uuid.v4(),
        username: 'Administrator',
        email: 'admin@chickenjoo.com',
        phone: const Value('0000000000'),
        passwordHash: passwordHash,
        organizationId: commissary.id,
        roleId: adminRole.id,
      ),
    );
    print('   ✓ Admin user created (admin@chickenjoo.com / admin123)');
  }

  /// Generate a new UUID
  String generateUuid() => _uuid.v4();

  /// Hash password using PBKDF2 with random salt (format: salt$hash)
  static String _hashPassword(String password) {
    // Generate random salt
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    final salt = saltBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    // PBKDF2 parameters
    const int iterations = 100000;
    const int keyLength = 32;

    final hmac = Hmac(sha256, utf8.encode(password));
    final saltBytesEncoded = utf8.encode(salt);

    List<int> int32ToBytes(int i) {
      return <int>[
        (i >> 24) & 0xff,
        (i >> 16) & 0xff,
        (i >> 8) & 0xff,
        i & 0xff,
      ];
    }

    final blockIndexBytes = int32ToBytes(1);
    var u = hmac.convert([...saltBytesEncoded, ...blockIndexBytes]).bytes;
    final List<int> derivedBlock = List<int>.from(u);

    for (int i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (int j = 0; j < derivedBlock.length; j++) {
        derivedBlock[j] ^= u[j];
      }
    }

    final dk = derivedBlock.sublist(0, keyLength);
    final hashHex = dk.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '$salt\$$hashHex';
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'chickenjoo_commissary.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
