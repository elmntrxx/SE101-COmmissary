# 🍗 Chicken Joo Commissary App Documentation
## Version 1.0.0

---

## 📋 Table of Contents

1. [File Structure & Description](#file-structure--description)
2. [Release Information](#release-information)
3. [Version 1.0.0 Overview](#version-100-overview)
4. [Features](#features)
5. [Technical Architecture](#technical-architecture)
6. [Database Schema](#database-schema)
7. [API Documentation](#api-documentation)
8. [Setup & Configuration](#setup--configuration)
9. [Security & Privacy](#security--privacy)
10. [Synchronization](#synchronization)
11. [Known Issues & Limitations](#known-issues--limitations)
12. [Screenshots](#screenshots)
13. [Contributing](#contributing)

---

## 📁 File Structure & Description

### Root Directory Files

```
commissary_app/
├── .env                         # Environment variables (Supabase credentials)
├── pubspec.yaml                 # Flutter dependencies and project configuration
├── README.md                    # Basic project readme
├── analysis_options.yaml        # Dart lint rules and static analysis
├── lib/                         # Main application source code
├── assets/                      # Static assets (images, logos)
├── supabase/                    # Supabase migrations and configuration
├── android/                     # Android platform-specific code
├── ios/                         # iOS platform-specific code
├── windows/                     # Windows platform-specific code
├── macos/                       # macOS platform-specific code
├── linux/                       # Linux platform-specific code
├── web/                         # Web platform-specific code
└── test/                        # Unit and widget tests
```

### Application Source (`lib/`)

#### Entry Points
- **`main.dart`** - Application entry point, initializes Flutter bindings, loads environment variables, sets up window size for desktop platforms, and launches the app
- **`app.dart`** - MaterialApp configuration, theme setup, route definitions, and navigation structure
- **`app_globals.dart`** - Global singleton pattern for accessing database, sync service, and authentication service throughout the app

#### Configuration (`lib/config/`)
- **`supabase_config.dart`** - Supabase configuration loader, reads credentials from `.env` file, provides URL and API keys

#### Data Layer (`lib/data/`)

**Legacy Database Provider**
- **`database_provider.dart`** - Singleton database provider (legacy implementation)

**Local Database (`lib/data/local/`)**
- **`app_database.dart`** - Alternative local database instance
- **`app_database.g.dart`** - Generated Drift code
- **`tables/`** - Legacy table definitions (items, roles, users)

#### Database Layer (`lib/database/`)

**Main Database**
- **`app_database.dart`** - Primary Drift database definition with all tables and DAOs, handles database initialization and connection
- **`app_database.g.dart`** - Auto-generated Drift code for type-safe database operations

**Tables (`lib/database/tables/`)**
| File | Description |
|------|-------------|
| `categories.dart` | Product category definitions (e.g., Chicken, Beverages, Sides) |
| `ingredients.dart` | Raw ingredient tracking with unit measurements and stock levels |
| `items.dart` | Inventory items/products with pricing, stock, and sales data |
| `organizations.dart` | Commissary and franchisee organization records |
| `recipe_ingredients.dart` | Mapping table linking items to their ingredient requirements |
| `roles.dart` | User roles with granular permission flags |
| `stock_change_requests.dart` | Stock adjustment requests (sales, spoilage, corrections) |
| `stock_replenishment_requests.dart` | Branch restocking requests from commissary |
| `users.dart` | User accounts with authentication and organization assignment |

**Data Access Objects (`lib/database/daos/`)**
| File | Description |
|------|-------------|
| `categories_dao.dart` | CRUD operations for categories |
| `ingredients_dao.dart` | Ingredient management, stock adjustments |
| `items_dao.dart` | Product/item operations with category joins |
| `organizations_dao.dart` | Organization management (commissary & franchisees) |
| `recipe_ingredients_dao.dart` | Recipe composition management |
| `roles_dao.dart` | Role and permission management |
| `stock_change_requests_dao.dart` | Stock change request processing |
| `stock_replenishment_requests_dao.dart` | Replenishment request workflow |
| `users_dao.dart` | User authentication and profile management |

**Models (`lib/database/models/`)**
- **`ingredient_usage.dart`** - Tracks ingredient consumption across products
- **`item_with_category.dart`** - Joined model for items with their category information
- **`recipe_ingredient_detail.dart`** - Detailed recipe breakdown with ingredient info

#### Screens (`lib/screens/`)

**Authentication**
- **`login/login_screen.dart`** - Email/password authentication with Supabase, session restoration, branded UI with gradient background

**Home & Navigation**
- **`home/home_screen.dart`** - Main dashboard with responsive sidebar navigation, connection status indicator, user profile menu

**Branch Management (`lib/screens/branches/`)**
- **`branches_page.dart`** - Main branch management screen with responsive layout detection
- **`branches_page_desktop.dart`** - Desktop-optimized layout with data tables
- **`branches_page_mobile.dart`** - Mobile-optimized layout with cards

**Inventory Management (`lib/screens/inventory_management/`)**
- **`inventory_management_page.dart`** - Tabbed interface for products and ingredients
- **`ingredients_tab.dart`** - Ingredient list with search, filter, add/edit/delete operations
- **`products_tab.dart`** - Product list with category filtering, recipe management
- **`widgets/ingredient_form_dialog.dart`** - Modal dialog for ingredient creation/editing
- **`widgets/item_form_dialog.dart`** - Modal dialog for product creation/editing with recipe builder

**Reports**
- **`reports/reports_page.dart`** - Cross-branch reporting with aggregated statistics, branch comparison, date filtering

**Settings**
- **`settings/settings_page.dart`** - Manual sync trigger, sync status display, app configuration

**Placeholder Screens**
- **`inventory/inventory_page.dart`** - Legacy inventory page (placeholder)
- **`ingredients/ingredients_page.dart`** - Ingredients overview (placeholder)
- **`requests/requests_page.dart`** - Stock requests management (placeholder)

#### Services (`lib/services/`)
- **`connectivity_service.dart`** - Network connectivity monitoring using connectivity_plus, detects online/offline status, notifies listeners on change
- **`supabase_auth_service.dart`** - Authentication service wrapping Supabase Auth, handles sign in/out, session management, user validation
- **`supabase_sync_service.dart`** - Cloud synchronization service, handles bidirectional sync with Supabase, conflict resolution, maintains sync state

#### Utilities (`lib/utils/`)
- **`design_constants.dart`** - UI constants (fonts, colors), responsive breakpoint helpers, common styling values
- **`sync_status.dart`** - Enumeration for sync states (idle, syncing, success, error)
- **`tables.dart`** - Reusable data table widgets and helpers

#### Widgets (`lib/widgets/`)
- **`connection_status_indicator.dart`** - Visual indicator showing online/offline status, sync state, tappable for manual sync

### Assets (`assets/`)
- **`chicken_joo_logo.png`** - Application logo used in login screen and branding

### Supabase Migrations (`supabase/migrations/`)
- **`001_add_missing_columns.sql`** - Initial schema extensions and column additions
- **`002_fix_rls_for_branch_operations.sql`** - Row Level Security policy definitions for multi-tenant access

### Key File Counts

| Category | Count | Description |
|----------|-------|-------------|
| **Dart Files** | 45+ | All source code files |
| **Screens** | 10 | User-facing screen components |
| **DAOs** | 9 | Data access objects for database operations |
| **Tables** | 9 | Database table definitions |
| **Services** | 3 | Business logic services |
| **Widgets** | 3 | Reusable UI components |
| **Utilities** | 3 | Helper classes and constants |
| **Models** | 3 | Complex data models with joins |

### Important Notes

**Files NOT in Git (User Must Create):**
1. `.env` - Supabase credentials (URL, anon key, service role key)
2. `google-services.json` - Firebase configuration (if using FCM)

**Generated Files (Auto-created by build_runner):**
- `*.g.dart` - Drift generated code for database operations
- `build/` - Compiled application artifacts

---

## 📦 Release Information

**Version:** 1.0.0+1  
**Release Date:** January 2026  
**Build Type:** Initial Release  
**Flutter SDK:** ^3.9.2  
**Dart SDK:** Compatible with Flutter 3.9.2  
**Package Name:** `com.chickenjoo.commissary`

### Quick Stats
- **Total Features:** 25+
- **Total Files:** 45+
- **Lines of Code:** ~8,000+
- **Supported Platforms:** Windows, macOS, Linux, iOS, Android, Web
- **Architecture:** Star Topology (Hub-Spoke)
- **Database:** Drift (SQLite) + Supabase (Cloud)

---

## 🚀 Version 1.0.0 Overview

Version 1.0.0 marks the initial stable release of the Chicken Joo Commissary App, establishing the foundation for franchise inventory management. This release focuses on core functionality, offline-first architecture, and multi-platform support.

### Key Highlights

- 🏢 **Franchise Management**: Central hub for managing multiple franchisee branches
- 📦 **Inventory Control**: Complete product and ingredient tracking system
- 🔄 **Offline-First**: Full functionality without internet with automatic cloud sync
- 🖥️ **Multi-Platform**: Runs on Windows, macOS, Linux, iOS, Android, and Web
- 🔐 **Secure Authentication**: Supabase Auth with PBKDF2 password hashing
- 📊 **Cross-Branch Reports**: Aggregated statistics and performance metrics
- 🎨 **Responsive Design**: Adapts to mobile and desktop screen sizes

### System Role

The Commissary App serves as the **central hub** in a star topology architecture:

```
                    ┌─────────────────┐
                    │    SUPABASE     │
                    │   (Cloud Hub)   │
                    └────────┬────────┘
                             │
             ┌───────────────┼───────────────┐
             │               │               │
   ┌─────────▼─────┐  ┌──────▼──────┐  ┌─────▼─────────┐
   │  COMMISSARY   │  │  BRANCH 1   │  │   BRANCH N    │
   │  (This App)   │  │ (Franchisee)│  │ (Franchisee)  │
   └───────────────┘  └─────────────┘  └───────────────┘
```

---

## ✨ Features

### 1. 🔐 Authentication System
- **Email/Password Login**: Secure authentication via Supabase Auth
- **Session Persistence**: Automatic session restoration on app restart
- **Commissary Enforcement**: Only commissary users can access this app
- **Branded Login Screen**: Custom gradient background with company logo

### 2. 🏠 Home Dashboard
- **Responsive Sidebar**: Collapsible navigation for desktop, drawer for mobile
- **Quick Access Menu**: One-click navigation to all major features
- **Connection Indicator**: Real-time online/offline status display
- **User Profile Menu**: Current user info with logout option
- **Manual Sync Trigger**: Force synchronization when needed

### 3. 🏪 Branch Management
- **Create Branches**: Add new franchisee locations with full details
- **View All Branches**: List all branches under the commissary network
- **Branch Details**: Address, phone, email, and status information
- **User Assignment**: Create and manage branch admin users
- **Status Tracking**: Active/inactive branch management
- **Responsive Views**: Optimized layouts for desktop tables and mobile cards

### 4. 📦 Inventory Management

#### Products Tab
- **Product Catalog**: Complete list of all inventory items
- **Add/Edit Products**: Full product information management
- **Category Assignment**: Organize products by category
- **Recipe Builder**: Define ingredient requirements for each product
- **Pricing Management**: Set selling price and track production cost
- **Stock Tracking**: Current stock levels with critical level alerts
- **Sales & Spoilage**: Track sold quantities and losses

#### Ingredients Tab
- **Ingredient List**: All raw materials inventory
- **Add/Edit Ingredients**: Name, unit, cost per unit management
- **Stock Adjustment**: Quick add/remove stock operations
- **Low Stock Filter**: Highlight items below critical level
- **Search & Sort**: Find ingredients quickly
- **Unit Tracking**: Support for various measurement units (kg, pcs, liters, etc.)

### 5. 📊 Reports & Analytics
- **Cross-Branch Overview**: Compare performance across all franchisees
- **Aggregated Statistics**:
  - Total items in network
  - Total units sold
  - Total spoilage losses
  - Low stock alert count
- **Branch Filtering**: Drill down to specific branch data
- **Time Period Selection**: Filter reports by date range
- **Export Ready**: Data formatted for external analysis

### 6. ⚙️ Settings & Configuration
- **Manual Sync**: Force data synchronization with cloud
- **Sync Status**: View last sync time and current state
- **Connection Status**: Network connectivity information
- **App Information**: Version and build details

### 7. 📝 Stock Requests (Framework Ready)
- **Replenishment Requests**: Framework for branch restock requests
- **Change Requests**: Stock adjustment approval workflow
- **Request Status Tracking**: Draft → Pending → Approved/Rejected → Fulfilled

---

## 🏗️ Technical Architecture

### Architecture Pattern: MVVM with Repository

```
┌─────────────────────────────────────────────────────────────┐
│                       UI Layer (Flutter)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Screens    │  │   Widgets    │  │    Dialogs   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     AppGlobals (Singleton)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Database   │  │  SyncService │  │  AuthService │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Access Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │     DAOs     │  │    Models    │  │    Tables    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Storage Layer                           │
│  ┌──────────────┐                    ┌──────────────┐      │
│  │ SQLite/Drift │◄──── Sync ────────►│   Supabase   │      │
│  │   (Local)    │                    │   (Cloud)    │      │
│  └──────────────┘                    └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

#### Frontend (Flutter)
| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter SDK | ^3.9.2 | Cross-platform UI framework |
| Dart | Latest | Programming language |
| Material Design 3 | Latest | UI component library |

#### Database & Storage
| Technology | Version | Purpose |
|------------|---------|---------|
| Drift | ^2.29.0 | Reactive SQLite ORM for Flutter |
| sqlite3_flutter_libs | ^0.5.40 | Native SQLite binaries |
| Supabase Flutter | ^2.3.4 | Cloud database and authentication |
| SharedPreferences | ^2.1.1 | Key-value local storage |

#### Networking & Connectivity
| Technology | Version | Purpose |
|------------|---------|---------|
| connectivity_plus | ^5.0.2 | Network status detection |
| Supabase Realtime | Included | Real-time data subscriptions |

#### Security
| Technology | Version | Purpose |
|------------|---------|---------|
| crypto | ^3.0.3 | PBKDF2 password hashing |
| uuid | ^4.0.0 | Unique identifier generation |
| Supabase Auth | Included | JWT-based authentication |

#### Development Tools
| Technology | Version | Purpose |
|------------|---------|---------|
| build_runner | ^2.4.11 | Code generation runner |
| drift_dev | ^2.29.0 | Drift code generator |
| flutter_lints | ^5.0.0 | Static analysis rules |
| flutter_dotenv | ^5.1.0 | Environment variable loading |

#### Desktop Support
| Technology | Source | Purpose |
|------------|--------|---------|
| window_size | GitHub | Window sizing for desktop platforms |

### State Management: Singleton Pattern

```dart
// AppGlobals provides global access to core services
class AppGlobals {
  static final AppGlobals _instance = AppGlobals._internal();
  static AppGlobals get instance => _instance;
  
  late final AppDatabase database;
  late final SupabaseSyncService syncService;
  late final SupabaseAuthService authService;
}

// Usage throughout the app
AppGlobals.instance.database.itemsDao.getAllItems();
AppGlobals.instance.syncService.syncAll();
AppGlobals.instance.authService.signOut();

// Convenience getters
database  // Global getter for database
syncService  // Global getter for sync service
authService  // Global getter for auth service
```

### Offline-First Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      USER ACTION                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Write to Local SQLite Database                  │
│                   (needsSync = true)                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Is Online?                                │
│              ┌─────────┴─────────┐                          │
│              │                   │                          │
│            Yes                   No                         │
│              │                   │                          │
│              ▼                   ▼                          │
│    ┌─────────────────┐  ┌─────────────────┐                │
│    │ Sync to Cloud   │  │ Queue for Later │                │
│    │ (needsSync=false)│  │ (Auto-retry)   │                │
│    └─────────────────┘  └─────────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗃️ Database Schema

### Entity Relationship Diagram

```
┌─────────────────┐       ┌─────────────────┐
│  Organizations  │       │      Roles      │
│─────────────────│       │─────────────────│
│ id (PK)         │       │ id (PK)         │
│ cloudId         │       │ cloudId         │
│ name            │       │ name            │
│ type            │       │ permissions...  │
│ parentCommissary│       └────────┬────────┘
└────────┬────────┘                │
         │                         │
         │    ┌────────────────────┘
         │    │
         ▼    ▼
┌─────────────────┐       ┌─────────────────┐
│      Users      │       │   Categories    │
│─────────────────│       │─────────────────│
│ id (PK)         │       │ id (PK)         │
│ cloudId         │       │ cloudId         │
│ email           │       │ name            │
│ organizationId  │───┐   │ description     │
│ roleId          │   │   └────────┬────────┘
└─────────────────┘   │            │
                      │            │
                      ▼            ▼
              ┌─────────────────────────────┐
              │           Items             │
              │─────────────────────────────│
              │ id (PK)                     │
              │ cloudId                     │
              │ name, description           │
              │ stock, criticalLevel        │
              │ sold, spoilage              │
              │ price, cost                 │
              │ organizationId (FK)         │
              │ categoryId (FK)             │
              └──────────────┬──────────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│RecipeIngredients│ │StockChangeReqs  │ │StockReplenishReqs│
│─────────────────│ │─────────────────│ │─────────────────│
│ itemId (FK)     │ │ itemId (FK)     │ │ itemId (FK)     │
│ ingredientId(FK)│ │ changeType      │ │ franchiseeId    │
│ quantity        │ │ quantityChange  │ │ commissaryId    │
└────────┬────────┘ │ status          │ │ quantityRequested│
         │          └─────────────────┘ │ status          │
         │                              └─────────────────┘
         ▼
┌─────────────────┐
│   Ingredients   │
│─────────────────│
│ id (PK)         │
│ cloudId         │
│ name            │
│ unit            │
│ stock           │
│ costPerUnit     │
│ commissaryId(FK)│
└─────────────────┘
```

### Table Definitions

#### Organizations
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | INTEGER | No | Auto-increment primary key |
| cloudId | TEXT | No | UUID for cloud synchronization |
| name | TEXT | No | Organization display name |
| type | TEXT | No | 'commissary' or 'franchisee' |
| address | TEXT | Yes | Physical street address |
| phone | TEXT | Yes | Contact phone number |
| email | TEXT | Yes | Contact email address |
| parentCommissaryId | TEXT | Yes | Cloud ID of parent commissary |
| isActive | BOOLEAN | No | Soft delete flag (default: true) |
| createdAt | DATETIME | No | Record creation timestamp |
| updatedAt | DATETIME | No | Last modification timestamp |
| lastSyncedAt | DATETIME | Yes | Last successful sync time |
| needsSync | BOOLEAN | No | Pending cloud sync flag |

#### Users
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | INTEGER | No | Auto-increment primary key |
| cloudId | TEXT | No | UUID for cloud synchronization |
| username | TEXT | No | Display name |
| email | TEXT | No | Login email (unique) |
| phone | TEXT | Yes | Contact phone number |
| passwordHash | TEXT | No | PBKDF2 hashed password |
| organizationId | INTEGER | No | FK to organizations table |
| roleId | INTEGER | No | FK to roles table |
| authUserId | TEXT | Yes | Supabase Auth user UUID |
| isActive | BOOLEAN | No | Account active status |
| createdAt | DATETIME | No | Account creation time |
| updatedAt | DATETIME | No | Last profile update |
| lastSyncedAt | DATETIME | Yes | Last sync timestamp |
| needsSync | BOOLEAN | No | Pending sync flag |

#### Roles
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | INTEGER | No | Auto-increment primary key |
| cloudId | TEXT | No | UUID for cloud sync |
| name | TEXT | No | Role name (e.g., 'Admin', 'Manager') |
| description | TEXT | Yes | Role description |
| canViewInventory | BOOLEAN | No | Permission: view inventory |
| canManageInventory | BOOLEAN | No | Permission: edit inventory |
| canManageEmployees | BOOLEAN | No | Permission: manage users |
| canManageRoles | BOOLEAN | No | Permission: edit roles |
| canViewReports | BOOLEAN | No | Permission: access reports |
| canManageBranches | BOOLEAN | No | Permission: manage branches |
| isSystemRole | BOOLEAN | No | Protected from deletion |
| createdAt | DATETIME | No | Creation timestamp |
| updatedAt | DATETIME | No | Modification timestamp |
| needsSync | BOOLEAN | No | Pending sync flag |

#### Items (Products)
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | INTEGER | No | Auto-increment primary key |
| cloudId | TEXT | No | UUID for cloud sync |
| name | TEXT | No | Product name |
| description | TEXT | Yes | Product description |
| stock | INTEGER | No | Current stock quantity |
| criticalLevel | INTEGER | No | Low stock alert threshold |
| sold | INTEGER | No | Total units sold |
| spoilage | INTEGER | No | Total units lost to spoilage |
| price | REAL | No | Selling price per unit |
| cost | REAL | No | Production cost per unit |
| organizationId | INTEGER | No | FK to owning organization |
| categoryId | INTEGER | Yes | FK to category |
| masterItemId | TEXT | Yes | Reference to master item |
| isActive | BOOLEAN | No | Product active status |
| createdAt | DATETIME | No | Creation timestamp |
| updatedAt | DATETIME | No | Modification timestamp |
| lastSyncedAt | DATETIME | Yes | Last sync time |
| needsSync | BOOLEAN | No | Pending sync flag |

#### Ingredients
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | INTEGER | No | Auto-increment primary key |
| cloudId | TEXT | No | UUID for cloud sync |
| name | TEXT | No | Ingredient name |
| unit | TEXT | No | Unit of measurement (kg, pcs, L) |
| stock | REAL | No | Current stock level |
| criticalLevel | REAL | No | Low stock threshold |
| costPerUnit | REAL | No | Cost per unit |
| commissaryId | INTEGER | No | FK to commissary organization |
| isActive | BOOLEAN | No | Ingredient active status |
| createdAt | DATETIME | No | Creation timestamp |
| updatedAt | DATETIME | No | Modification timestamp |
| lastSyncedAt | DATETIME | Yes | Last sync time |
| needsSync | BOOLEAN | No | Pending sync flag |

#### Recipe Ingredients
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | INTEGER | No | Auto-increment primary key |
| cloudId | TEXT | No | UUID for cloud sync |
| itemId | INTEGER | No | FK to items table |
| ingredientId | INTEGER | No | FK to ingredients table |
| quantity | REAL | No | Quantity of ingredient needed |
| createdAt | DATETIME | No | Creation timestamp |
| updatedAt | DATETIME | No | Modification timestamp |
| needsSync | BOOLEAN | No | Pending sync flag |

#### Stock Replenishment Requests
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | INTEGER | No | Auto-increment primary key |
| cloudId | TEXT | No | UUID for cloud sync |
| franchiseeId | INTEGER | No | FK to requesting branch |
| commissaryId | INTEGER | No | FK to fulfilling commissary |
| itemId | INTEGER | No | FK to requested item |
| quantityRequested | INTEGER | No | Amount requested |
| quantityApproved | INTEGER | Yes | Amount approved |
| status | TEXT | No | draft/pending/approved/rejected/fulfilled |
| requesterNotes | TEXT | Yes | Notes from branch |
| approverNotes | TEXT | Yes | Notes from commissary |
| requestedAt | DATETIME | No | Request creation time |
| processedAt | DATETIME | Yes | Approval/rejection time |
| fulfilledAt | DATETIME | Yes | Fulfillment time |
| needsSync | BOOLEAN | No | Pending sync flag |

#### Stock Change Requests
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | INTEGER | No | Auto-increment primary key |
| cloudId | TEXT | No | UUID for cloud sync |
| franchiseeId | INTEGER | No | FK to branch |
| itemId | INTEGER | No | FK to item |
| changeType | TEXT | No | sale/spoilage/adjustment/restock |
| quantityChange | INTEGER | No | Amount changed (+/-) |
| previousStock | INTEGER | No | Stock before change |
| newStock | INTEGER | No | Stock after change |
| status | TEXT | No | draft/pending/approved/rejected |
| notes | TEXT | Yes | Explanation for change |
| requestedAt | DATETIME | No | Request time |
| processedAt | DATETIME | Yes | Processing time |
| needsSync | BOOLEAN | No | Pending sync flag |

#### Categories
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | INTEGER | No | Auto-increment primary key |
| cloudId | TEXT | No | UUID for cloud sync |
| name | TEXT | No | Category name |
| description | TEXT | Yes | Category description |
| organizationId | INTEGER | No | FK to organization |
| isActive | BOOLEAN | No | Category active status |
| createdAt | DATETIME | No | Creation timestamp |
| updatedAt | DATETIME | No | Modification timestamp |
| needsSync | BOOLEAN | No | Pending sync flag |

---

## 📡 API Documentation

### Supabase Integration

#### Authentication Endpoints

**Sign In**
```dart
final response = await supabase.auth.signInWithPassword(
  email: 'user@example.com',
  password: 'password123',
);
```

**Sign Out**
```dart
await supabase.auth.signOut();
```

**Get Current User**
```dart
final user = supabase.auth.currentUser;
final session = supabase.auth.currentSession;
```

#### Database Operations

**Fetch Organizations**
```dart
final response = await supabase
  .from('organizations')
  .select()
  .eq('parent_commissary_id', commissaryCloudId);
```

**Insert Record**
```dart
await supabase.from('items').insert({
  'cloud_id': uuid.v4(),
  'name': 'Fried Chicken',
  'stock': 100,
  'price': 150.00,
  'organization_id': orgCloudId,
});
```

**Update Record**
```dart
await supabase
  .from('items')
  .update({'stock': newStock})
  .eq('cloud_id', itemCloudId);
```

**Delete Record**
```dart
await supabase
  .from('items')
  .delete()
  .eq('cloud_id', itemCloudId);
```

### Sync API

#### Sync Order (Dependency Resolution)
1. `organizations` - Must sync first (parent references)
2. `roles` - No dependencies
3. `users` - Depends on organizations, roles
4. `categories` - Depends on organizations
5. `items` - Depends on organizations, categories
6. `ingredients` - Depends on organizations
7. `recipe_ingredients` - Depends on items, ingredients
8. `stock_replenishment_requests` - Depends on organizations, items
9. `stock_change_requests` - Depends on organizations, items

#### Sync Response Format
```json
{
  "success": true,
  "synced_at": "2026-01-20T10:30:00Z",
  "records_pushed": 15,
  "records_pulled": 23,
  "conflicts_resolved": 2
}
```

### Rate Limits
- **Supabase Free Tier**: 500MB database, 1GB file storage
- **API Requests**: 500,000/month (free tier)
- **Realtime Connections**: 200 concurrent

---

## ⚙️ Setup & Configuration

### Prerequisites
- Flutter SDK ^3.9.2
- Dart SDK (included with Flutter)
- Supabase account and project
- IDE: VS Code or Android Studio

### Environment Setup

#### 1. Clone and Install
```bash
# Clone repository
git clone <repository-url>
cd commissary_app

# Install dependencies
flutter pub get
```

#### 2. Create Environment File
Create `.env` in project root:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
```

#### 3. Generate Drift Code
```bash
dart run build_runner build --delete-conflicting-outputs
```

#### 4. Supabase Setup
1. Create new Supabase project
2. Run migrations from `supabase/migrations/`
3. Configure Row Level Security policies
4. Copy project URL and anon key to `.env`

### Build Commands

#### Development
```bash
# Run on connected device
flutter run

# Run on specific platform
flutter run -d windows
flutter run -d macos
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

#### Production Build
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Desktop Configuration

The app configures window size on desktop platforms:
```dart
// In main.dart
if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  setWindowTitle('Chicken Joo Commissary');
  setWindowMinSize(const Size(1280, 720));
  setWindowMaxSize(const Size(1920, 1080));
}
```

### Database Location
- **Windows**: `%USERPROFILE%\Documents\chickenjoo_commissary.sqlite`
- **macOS**: `~/Documents/chickenjoo_commissary.sqlite`
- **Linux**: `~/Documents/chickenjoo_commissary.sqlite`
- **Mobile**: App-specific documents directory

---

## 🔐 Security & Privacy

### Authentication Security

#### Password Hashing
- **Algorithm**: PBKDF2 with HMAC-SHA256
- **Iterations**: 100,000
- **Key Length**: 32 bytes
- **Salt**: 16 cryptographically random bytes per password
- **Storage Format**: `base64(salt)$base64(hash)`

```dart
// Password hashing implementation
String hashPassword(String password) {
  final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
  final key = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  ).deriveKey(
    secretKey: SecretKey(utf8.encode(password)),
    nonce: salt,
  );
  return '${base64.encode(salt)}\$${base64.encode(key.bytes)}';
}
```

#### Session Management
- JWT tokens via Supabase Auth
- Automatic token refresh
- Session persistence in secure storage
- Logout clears all local session data

### Access Control

#### Role-Based Permissions
| Permission | Description |
|------------|-------------|
| canViewInventory | View products and ingredients |
| canManageInventory | Create, edit, delete inventory items |
| canManageEmployees | Create, edit user accounts |
| canManageRoles | Modify role permissions |
| canViewReports | Access reports and analytics |
| canManageBranches | Create and manage franchisee branches |

#### Commissary Enforcement
Only users with `organization.type = 'commissary'` can access this app. Branch users must use the separate franchisee application.

### Row Level Security (RLS)

Supabase RLS policies enforce data isolation:

```sql
-- Organizations: Commissary sees all, franchisee sees self only
CREATE POLICY "Commissary full access" ON organizations
  FOR ALL USING (
    auth.uid() IN (
      SELECT auth_user_id FROM users 
      WHERE organization_id IN (
        SELECT id FROM organizations WHERE type = 'commissary'
      )
    )
  );

-- Items: Access based on organization hierarchy
CREATE POLICY "Organization item access" ON items
  FOR ALL USING (
    organization_id IN (
      SELECT id FROM organizations 
      WHERE id = current_user_org() 
         OR parent_commissary_id = current_user_org_cloud_id()
    )
  );
```

### Data Encryption
- **In Transit**: TLS 1.3 for all Supabase connections
- **At Rest**: SQLite database stored in user documents (OS-level protection)
- **Credentials**: Environment variables, not hardcoded

### Privacy Considerations
- No third-party analytics or tracking
- Data stored locally and in your own Supabase instance
- User controls all data through Supabase dashboard
- Export and deletion available via Supabase

---

## 🔄 Synchronization

### Sync Strategy

The app uses a **last-write-wins** conflict resolution strategy with the following flow:

```
┌─────────────────────────────────────────────────────────────┐
│                    SYNC PROCESS                              │
│                                                              │
│  1. PULL: Fetch remote changes since last sync              │
│     └── Apply to local database                             │
│                                                              │
│  2. PUSH: Send local changes (needsSync = true)             │
│     └── Clear needsSync flag on success                     │
│                                                              │
│  3. RESOLVE: Handle conflicts                                │
│     └── Remote timestamp wins                               │
│                                                              │
│  4. UPDATE: Set lastSyncedAt timestamp                      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Sync Triggers
- **Automatic**: Every 5 minutes when online
- **Manual**: Via Settings page or connection indicator
- **On Reconnect**: Immediate sync when coming back online
- **On Data Change**: Sync queued for next cycle

### Sync Order

Tables are synced in dependency order to maintain referential integrity:

1. **organizations** - Root entity, no dependencies
2. **roles** - Independent entity
3. **users** - References organizations, roles
4. **categories** - References organizations
5. **items** - References organizations, categories
6. **ingredients** - References organizations
7. **recipe_ingredients** - References items, ingredients
8. **stock_replenishment_requests** - References organizations, items
9. **stock_change_requests** - References organizations, items

### Offline Behavior

| Scenario | Behavior |
|----------|----------|
| Creating records | Saved locally, queued for sync |
| Editing records | Saved locally, queued for sync |
| Deleting records | Soft delete locally, queued for sync |
| Viewing data | Full functionality from local database |
| Sync attempt | Fails gracefully, retries when online |

### Conflict Resolution

```dart
// Conflict resolution logic
if (remoteRecord.updatedAt > localRecord.updatedAt) {
  // Remote wins - apply remote changes
  await localDao.updateFromRemote(remoteRecord);
} else {
  // Local wins - push local changes
  await pushToRemote(localRecord);
}
```

### Sync Status Indicator

The connection status indicator shows:
- 🟢 **Online**: Connected and synced
- 🟡 **Syncing**: Synchronization in progress
- 🔴 **Offline**: No internet connection
- ⚠️ **Error**: Sync failed, tap to retry

---

## ⚠️ Known Issues & Limitations

### Known Issues

#### High Priority
- [ ] Initial sync may timeout with large datasets (>10,000 records)
- [ ] Desktop window position not persisted across restarts

#### Medium Priority
- [ ] Recipe ingredient quantities don't auto-deduct on sale
- [ ] Report date range picker timezone handling inconsistent
- [ ] Branch creation may fail silently if Supabase Auth quota exceeded

#### Low Priority
- [ ] Dark mode not fully implemented
- [ ] Some form validation messages truncated on small screens
- [ ] Export to CSV/PDF not yet implemented

### Limitations

#### Technical Limitations
- **Maximum Branches**: Limited by Supabase row limits
- **File Uploads**: Not supported in current version
- **Barcode Scanning**: Not implemented (planned for v1.1)
- **Multi-Language**: English only

#### Platform Limitations
- **iOS**: Requires macOS for building
- **Android**: Minimum API level 21 (Android 5.0)
- **Web**: Limited offline support (service worker not configured)
- **Desktop**: Window minimum size 1280x720

#### Sync Limitations
- **Conflict Resolution**: Last-write-wins only
- **Sync Interval**: Minimum 5 minutes (not configurable)
- **Offline Duration**: No limit, but large queue may slow sync

### Workarounds

#### For Large Dataset Sync
```bash
# Increase timeout in supabase_sync_service.dart
// Change from:
Duration(seconds: 30)
// To:
Duration(seconds: 120)
```

#### For Auth Quota Issues
- Create users in Supabase dashboard directly
- Use service role key for batch operations

---

## 📸 Screenshots

### Login Screen
*[Placeholder: Login screen with Chicken Joo branding and gradient background]*

### Home Dashboard
*[Placeholder: Main dashboard showing sidebar navigation and quick stats]*

### Branch Management
*[Placeholder: Branch list view with desktop data table layout]*

### Inventory - Products Tab
*[Placeholder: Products list with category badges and stock indicators]*

### Inventory - Ingredients Tab
*[Placeholder: Ingredients list with unit costs and low stock highlighting]*

### Add/Edit Product Dialog
*[Placeholder: Product form with recipe ingredient builder]*

### Reports Page
*[Placeholder: Cross-branch statistics with date filtering]*

### Settings Page
*[Placeholder: Settings with sync status and manual sync button]*

---

## 🤝 Contributing

### Development Workflow

#### 1. Setup Development Environment
```bash
# Fork and clone
git clone https://github.com/your-username/commissary_app.git
cd commissary_app

# Create feature branch
git checkout -b feature/your-feature-name

# Install dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs
```

#### 2. Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` before committing
- Format code with `dart format .`
- Maximum line length: 80 characters

#### 3. Database Changes
When modifying database schema:
1. Update table definitions in `lib/database/tables/`
2. Update or create DAO in `lib/database/daos/`
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Create Supabase migration in `supabase/migrations/`
5. Test sync functionality

#### 4. Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

#### 5. Commit Convention
Follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code formatting
- `refactor:` Code restructuring
- `test:` Test updates
- `chore:` Build/config changes

Example:
```bash
git commit -m "feat: add ingredient usage tracking"
git commit -m "fix: resolve sync conflict with deleted items"
```

#### 6. Pull Request
1. Push to your fork
2. Open PR against `main` branch
3. Fill in PR template
4. Wait for review

### Code Review Checklist
- [ ] Code follows style guidelines
- [ ] No linting errors
- [ ] Database migrations included if needed
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Tested on at least one platform

---

## 📞 Support & Contact

### Reporting Issues
Create GitHub issue with:
1. Platform and OS version
2. App version
3. Steps to reproduce
4. Expected vs actual behavior
5. Screenshots/logs if applicable

### Feature Requests
Create GitHub issue with:
1. Feature description
2. Use case explanation
3. Proposed implementation (optional)
4. Priority justification

---

## 📄 License

```
MIT License

Copyright (c) 2026 Chicken Joo Franchise

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🎉 Acknowledgments

Special thanks to:
- Flutter team for the amazing cross-platform framework
- Supabase team for the excellent backend-as-a-service
- Drift maintainers for reactive SQLite support
- The open-source community

---

**Version:** 1.0.0+1  
**Last Updated:** January 2026  
**Maintained by:** Chicken Joo Development Team

**🍗 Chicken Joo Commissary - Managing Your Franchise Network**

*Bringing efficiency to every branch, one sync at a time.*
