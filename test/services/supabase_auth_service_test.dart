import 'dart:async';

import 'package:commissary_app/database/app_database.dart';
import 'package:commissary_app/database/daos/organizations_dao.dart';
import 'package:commissary_app/database/daos/roles_dao.dart';
import 'package:commissary_app/database/daos/users_dao.dart';
import 'package:commissary_app/services/supabase_auth_service.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Mocks
class MockSupabaseClient extends Mock implements supabase.SupabaseClient {}

class MockGoTrueClient extends Mock implements supabase.GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock
    implements supabase.SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements supabase.PostgrestFilterBuilder {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockUsersDao extends Mock implements UsersDao {}

class MockOrganizationsDao extends Mock implements OrganizationsDao {}

class MockRolesDao extends Mock implements RolesDao {}

class MockUser extends Mock implements supabase.User {}

class MockSession extends Mock implements supabase.Session {}

class MockAuthResponse extends Mock implements supabase.AuthResponse {}

class MockUserResponse extends Mock implements supabase.UserResponse {}

class MockDataUser extends Mock implements User {}

class MockDataOrganization extends Mock implements Organization {}

class MockDataRole extends Mock implements Role {}

class MockAdminUserAttributes extends Mock implements supabase.AdminUserAttributes {}

// Fake classes to satisfy registerFallbackValue if needed
class FakeUsersCompanion extends Fake implements UsersCompanion {}

void main() {
  late SupabaseAuthService authService;
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockAppDatabase mockDb;
  late MockUsersDao mockUsersDao;
  late MockOrganizationsDao mockOrganizationsDao;
  late MockRolesDao mockRolesDao;

  // Test Data
  final testEmail = 'test@commissary.com';
  final testPassword = 'password123';
  final testAuthUserId = 'auth-user-id-123';
  final testOrgCloudId = 'org-cloud-id-123';

  // Local User Config
  final localUser = User(
    id: 1,
    cloudId: 'user-cloud-id',
    username: 'TestUser',
    email: testEmail,
    organizationId: 1,
    roleId: 1,
    isActive: true,
    passwordHash: AppDatabase.hashPassword(testPassword),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    needsSync: false,
    lastSyncedAt: DateTime.now(),
  );

  final localOrganization = Organization(
    id: 1,
    cloudId: testOrgCloudId,
    name: 'Test Commissary',
    type: 'commissary',
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    needsSync: false,
  );

  final localRole = Role(
    id: 1,
    cloudId: 'role-cloud-id',
    name: 'Admin',
    description: 'Admin Role',
    canViewInventory: true,
    canManageInventory: true,
    canViewReports: true,
    canManageEmployees: true,
    canManageRoles: true,
    canManageBranches: true,
    isSystemRole: true,
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    needsSync: false,
  );

  setUpAll(() {
    registerFallbackValue(FakeUsersCompanion());
    registerFallbackValue(MockAdminUserAttributes());
  });

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockDb = MockAppDatabase();
    mockUsersDao = MockUsersDao();
    mockOrganizationsDao = MockOrganizationsDao();
    mockRolesDao = MockRolesDao();

    // Setup Supabase Client
    when(() => mockSupabase.auth).thenReturn(mockAuth);

    // Setup Database
    when(() => mockDb.usersDao).thenReturn(mockUsersDao);
    when(() => mockDb.organizationsDao).thenReturn(mockOrganizationsDao);
    when(() => mockDb.rolesDao).thenReturn(mockRolesDao);

    // Initialize Service (it listens to auth state changes in constructor)
    when(() => mockAuth.onAuthStateChange).thenAnswer(
      (_) => Stream.value(
        supabase.AuthState(
          supabase.AuthChangeEvent.initialSession,
          null,
        ),
      ),
    );

    authService = SupabaseAuthService(supabase: mockSupabase, db: mockDb);
  });

  tearDown(() {
    authService.dispose();
  });

  group('SupabaseAuthService Tests', () {
    // Helper to mock successful local user lookup
    void mockLocalUserLookup() {
      when(() => mockUsersDao.getAllUsers())
          .thenAnswer((_) async => [localUser]);
      when(() => mockOrganizationsDao.getOrganizationById(any()))
          .thenAnswer((_) async => localOrganization);
      when(() => mockRolesDao.getRoleById(any()))
          .thenAnswer((_) async => localRole);
    }

    group('Happy Paths', () {
      test(
          'should return success when signIn with Supabase succeeds and local user exists',
          () async {
        // Arrange
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();

        when(() => mockUser.email).thenReturn(testEmail);
        when(() => mockUser.id).thenReturn(testAuthUserId);
        when(() => mockResponse.user).thenReturn(mockUser);
        when(() => mockResponse.session).thenReturn(MockSession());

        when(() => mockAuth.signInWithPassword(
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) async => mockResponse);

        mockLocalUserLookup();

        // Act
        final result =
            await authService.signIn(email: testEmail, password: testPassword);

        // Assert
        expect(result.success, isTrue);
        expect(result.localUser, isNotNull);
        expect(result.localUser!.email, testEmail);
        verify(() => mockAuth.signInWithPassword(
            email: testEmail, password: testPassword)).called(1);
      });

      test(
          'should return success when signIn fails online but succeeds offline',
          () async {
        // Arrange
        when(() => mockAuth.signInWithPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(const supabase.AuthException('Network error'));

        when(() => mockUsersDao.getUserByEmail(testEmail))
            .thenAnswer((_) async => localUser);
        when(() => mockOrganizationsDao.getOrganizationById(any()))
            .thenAnswer((_) async => localOrganization);
        when(() => mockRolesDao.getRoleById(any()))
            .thenAnswer((_) async => localRole);

        // Act
        final result =
            await authService.signIn(email: testEmail, password: testPassword);

        // Assert
        expect(result.success, isTrue);
        expect(result.message, contains('offline'));
        expect(result.localUser!.email, testEmail);
      });

      test('should clear current user when signOut is called', () async {
        // Arrange
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        // Act
        await authService.signOut();

        // Assert
        expect(authService.currentUser, isNull);
        verify(() => mockAuth.signOut()).called(1);
      });

      test('should return success when restoreSession finds valid session',
          () async {
        // Arrange
        final mockSession = MockSession();
        final mockUser = MockUser();
        final futureTime =
            DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;

        when(() => mockSession.user).thenReturn(mockUser);
        when(() => mockSession.expiresAt).thenReturn(futureTime);
        when(() => mockUser.email).thenReturn(testEmail);
        when(() => mockUser.id).thenReturn(testAuthUserId);
        
        when(() => mockAuth.currentSession).thenReturn(mockSession);
        
        mockLocalUserLookup();

        // Act
        final result = await authService.restoreSession();

        // Assert
        expect(result.success, isTrue);
        expect(result.user, mockUser);
      });

      test('should return new user id when createBranchAdminAuthUser succeeds',
          () async {
        // Arrange
        final newUserId = 'new-user-id';
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn(newUserId);
        when(() => mockResponse.user).thenReturn(mockUser);

        when(() => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => mockResponse);
        
        when(() => mockAuth.signOut()).thenAnswer((_) async {});
        // Mock session restoration attempts
        when(() => mockAuth.currentSession).thenReturn(null);

        // Act
        final result = await authService.createBranchAdminAuthUser(
            email: 'new@branch.com',
            password: 'password',
            organizationCloudId: 'org-id');

        // Assert
        expect(result, newUserId);
        verify(() => mockAuth.signUp(
              email: 'new@branch.com',
              password: 'password',
              data: any(named: 'data'),
            )).called(1);
      });

      test('should return true when deleteAuthUser succeeds', () async {
        // Arrange
        final mockAdmin = MockGoTrueAdminApi();
        when(() => mockAuth.admin).thenReturn(mockAdmin);
        when(() => mockAdmin.deleteUser(any())).thenAnswer((_) async {});

        // Act
        final result = await authService.deleteAuthUser(testAuthUserId);

        // Assert
        expect(result, isTrue);
        verify(() => mockAdmin.deleteUser(testAuthUserId)).called(1);
      });

      test('should return true when updateUserPassword succeeds', () async {
        // Arrange
        final mockAdmin = MockGoTrueAdminApi();
        when(() => mockAuth.admin).thenReturn(mockAdmin);
        when(() => mockAdmin.updateUserById(any(),
                attributes: any(named: 'attributes')))
            .thenAnswer((_) async => MockUserResponse());

        // Act
        final result =
            await authService.updateUserPassword(testAuthUserId, 'newPassword');

        // Assert
        expect(result, isTrue);
      });
      
      test('should return true for isSessionValid when session is active', () async {
         // Arrange
        final mockSession = MockSession();
        final futureTime =
            DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
        when(() => mockSession.expiresAt).thenReturn(futureTime);
        when(() => mockAuth.currentSession).thenReturn(mockSession);
        
        // Act
        final isValid = await authService.isSessionValid();
        
        // Assert
        expect(isValid, isTrue);
      });
    });

    group('Unhappy Paths', () {
      test(
          'should return failure when signIn with Supabase fails and offline fails',
          () async {
        // Arrange
        when(() => mockAuth.signInWithPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(const supabase.AuthException('Network error'));

        // Offline fail: user not found
        when(() => mockUsersDao.getUserByEmail(testEmail))
            .thenAnswer((_) async => null);

        // Act
        final result =
            await authService.signIn(email: testEmail, password: testPassword);

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('Invalid credentials'));
      });

      test('should return failure when signIn succeeds but user is not commissary',
          () async {
        // Arrange
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();
        when(() => mockUser.email).thenReturn(testEmail);
        when(() => mockResponse.user).thenReturn(mockUser);
        
         when(() => mockAuth.signInWithPassword(
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) async => mockResponse);

         // Mocks for local user lookup - returning franchisee
        when(() => mockUsersDao.getAllUsers())
            .thenAnswer((_) async => [localUser]); // Match logic usually checks email loop
        
        // Return franchisee organization
        final franchiseeOrg = Organization(
            id: 1, cloudId: 'id', name: 'Fran', type: 'franchisee', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now(), needsSync: false);
        
        when(() => mockOrganizationsDao.getOrganizationById(any()))
          .thenAnswer((_) async => franchiseeOrg);
        when(() => mockRolesDao.getRoleById(any()))
          .thenAnswer((_) async => localRole);
          
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        // Act
        final result =
            await authService.signIn(email: testEmail, password: testPassword);

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('Commissary users only'));
      });

      test('should return failure when signIn succeeds but local user not found',
          () async {
        // Arrange
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();
        when(() => mockUser.email).thenReturn(testEmail);
        when(() => mockResponse.user).thenReturn(mockUser);
        
        when(() => mockAuth.signInWithPassword(
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) async => mockResponse);

        // Local lookup finds nothing
        when(() => mockUsersDao.getAllUsers()).thenAnswer((_) async => []);
        
        // Cloud pull failure simulation
        when(() => mockSupabase.from(any())).thenThrow(Exception('Cloud error'));
        
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        // Act
        final result =
            await authService.signIn(email: testEmail, password: testPassword);

        // Assert
        expect(result.success, isFalse);
      });

      test('should return failure when restoreSession finds expired session',
          () async {
        // Arrange
        final mockSession = MockSession();
        final pastTime =
            DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
        when(() => mockSession.expiresAt).thenReturn(pastTime);
        when(() => mockAuth.currentSession).thenReturn(mockSession);

        // Act
        final result = await authService.restoreSession();

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('No active session'));
      });

      test('should return failure when restoreSession finds no session',
          () async {
        // Arrange
        when(() => mockAuth.currentSession).thenReturn(null);

        // Act
        final result = await authService.restoreSession();

        // Assert
        expect(result.success, isFalse);
      });

      test('should throw error when createBranchAdminAuthUser fails',
          () async {
        // Arrange
        when(() => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              data: any(named: 'data'),
            )).thenThrow(const supabase.AuthException('Creation failed'));

        // Act & Assert
        expect(
          () => authService.createBranchAdminAuthUser(
              email: 'new@branch.com',
              password: 'pass',
              organizationCloudId: 'id'),
          throwsA(isA<supabase.AuthException>()),
        );
      });

      test('should return false when deleteAuthUser fails', () async {
        // Arrange
        final mockAdmin = MockGoTrueAdminApi();
        when(() => mockAuth.admin).thenReturn(mockAdmin);
        when(() => mockAdmin.deleteUser(any())).thenThrow(Exception('Failed'));

        // Act
        final result = await authService.deleteAuthUser(testAuthUserId);

        // Assert
        expect(result, isFalse);
      });

      test('should return failure when offline signIn fails due to wrong password',
          () async {
       // Arrange
        when(() => mockAuth.signInWithPassword(
              email: testEmail,
              password: 'wrongpassword',
            )).thenThrow(const supabase.AuthException('Network error'));

        when(() => mockUsersDao.getUserByEmail(testEmail))
            .thenAnswer((_) async => localUser);
        
        // Act
        final result =
            await authService.signIn(email: testEmail, password: 'wrongpassword');

        // Assert
        expect(result.success, isFalse);
        expect(result.message, isNotNull);
      });
    });
  });
}

// Extra Mocks needed for specific tests
class MockGoTrueAdminApi extends Mock implements supabase.GoTrueAdminApi {}
