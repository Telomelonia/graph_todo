# Cloud Sync Implementation Plan

**Goal**: Enable multi-device sync using MongoDB Atlas with Auth0 authentication while maintaining local Hive storage for offline use.

**Architecture**: Hybrid local-first with cloud sync
- Local storage: Hive (existing)
- Cloud storage: MongoDB Atlas (new)
- Authentication: Auth0 (new)
- Sync strategy: Manual sync with pull-to-refresh

---

## Phase 1: Setup & Dependencies ⏳

### 1.1 Project Setup
- [x] Create planDB.md task tracking document
- [ ] Add dependencies to pubspec.yaml:
  - [ ] `auth0_flutter` - Auth0 authentication SDK
  - [ ] `mongo_dart` - MongoDB client for Dart
  - [ ] `http` - HTTP requests for backend
  - [ ] `flutter_secure_storage` - Secure token storage
  - [ ] `connectivity_plus` - Network status detection

### 1.2 External Services Setup
- [ ] MongoDB Atlas:
  - [ ] Create free tier account at https://www.mongodb.com/cloud/atlas
  - [ ] Create cluster (M0 free tier)
  - [ ] Create database: `graphtodo`
  - [ ] Create collections: `nodes`, `connections`, `user_metadata`
  - [ ] Configure database user with read/write permissions
  - [ ] Get connection string
  - [ ] Set up IP whitelist (0.0.0.0/0 for mobile access)
- [ ] Auth0:
  - [ ] Create free account at https://auth0.com
  - [ ] Create new application (Native)
  - [ ] Configure callback URLs for Flutter
  - [ ] Get domain, client ID, and client secret
  - [ ] Set up user metadata for MongoDB user ID linking

---

## Phase 2: Backend Service Layer 🔧

### 2.1 Authentication Service
**File**: `lib/services/auth_service.dart`
- [ ] Implement Auth0 login flow
- [ ] Implement logout functionality
- [ ] Secure token storage using flutter_secure_storage
- [ ] Token refresh logic
- [ ] User profile retrieval (name, email, user ID)
- [ ] Auth state management (logged in/out)

### 2.2 MongoDB Sync Service
**File**: `lib/services/mongodb_sync_service.dart`
- [ ] MongoDB connection setup with Auth0 user ID
- [ ] Upload nodes to MongoDB (filtered by user ID)
- [ ] Upload connections to MongoDB (filtered by user ID)
- [ ] Download nodes from MongoDB
- [ ] Download connections from MongoDB
- [ ] Conflict resolution strategy:
  - [ ] Timestamp-based (use updatedAt field)
  - [ ] Last-write-wins for same timestamp
- [ ] Batch sync operations for efficiency
- [ ] Error handling and retry logic

### 2.3 Update Existing Services
**File**: `lib/services/hive_storage_service.dart`
- [ ] Add sync status tracking (lastSyncTime, syncInProgress)
- [ ] Add updatedAt timestamp to all save operations
- [ ] Add methods to get all data for sync
- [ ] Add methods to bulk update from sync

**File**: `lib/models/todo_node.dart`
- [ ] Add `updatedAt` DateTime field (HiveField 9)
- [ ] Add `syncedToCloud` boolean field (HiveField 10)
- [ ] Update constructor and copyWith

**File**: `lib/models/connection.dart`
- [ ] Add `updatedAt` DateTime field (HiveField)
- [ ] Add `syncedToCloud` boolean field (HiveField)
- [ ] Update constructor and copyWith

---

## Phase 3: State Management 📊

### 3.1 Auth Provider
**File**: `lib/providers/auth_provider.dart`
- [ ] Create AuthProvider extending ChangeNotifier
- [ ] Track authentication state
- [ ] Expose login/logout methods
- [ ] Expose user profile information
- [ ] Handle auth state changes

### 3.2 Sync Provider
**File**: `lib/providers/sync_provider.dart`
- [ ] Create SyncProvider extending ChangeNotifier
- [ ] Track sync status (idle, syncing, success, error)
- [ ] Expose sync method
- [ ] Track last sync time
- [ ] Handle sync errors with user-friendly messages

### 3.3 Update Canvas Provider
**File**: `lib/providers/canvas_provider.dart`
- [ ] Add sync status properties
- [ ] Add method to trigger sync
- [ ] Update node/connection operations to mark as unsynced
- [ ] Add timestamp tracking on all mutations

---

## Phase 4: UI Integration 🎨

### 4.1 Hamburger Menu Updates
**File**: Location TBD (need to find existing hamburger menu widget)
- [ ] Add sync button with refresh icon
- [ ] Show sync status (last synced time)
- [ ] Add login/logout button
- [ ] Display user profile when logged in
- [ ] Show offline indicator when no network

### 4.2 Sync Status Indicator
**File**: `lib/widgets/sync_status_widget.dart`
- [ ] Create widget showing sync status
- [ ] States: syncing (spinner), synced (checkmark), error (error icon)
- [ ] Show last sync timestamp
- [ ] Show sync progress (X/Y items synced)

### 4.3 Auth UI
**File**: `lib/widgets/auth_widget.dart` or integrate into existing menu
- [ ] Login button triggering Auth0 web view
- [ ] Logout button with confirmation
- [ ] User profile display (avatar, name, email)
- [ ] Handle auth callbacks

### 4.4 Main App Updates
**File**: `lib/main.dart`
- [ ] Add AuthProvider to MultiProvider
- [ ] Add SyncProvider to MultiProvider
- [ ] Initialize Auth0 on app start
- [ ] Check auth state on app start

---

## Phase 5: Data Migration & Testing 🧪

### 5.1 Testing Scenarios
- [ ] **First sync**: Local data → Cloud (upload)
- [ ] **Fresh install sync**: Cloud → Local (download)
- [ ] **Bidirectional sync**: Merge local changes + cloud changes
- [ ] **Conflict resolution**: Edit same node on two devices
- [ ] **Offline mode**: App works without login/internet
- [ ] **Network failure**: Graceful error handling
- [ ] **Token expiry**: Auto-refresh or re-login prompt
- [ ] **Large dataset**: Performance with 100+ nodes

### 5.2 Edge Cases
- [ ] Corrupted local data
- [ ] Corrupted cloud data
- [ ] Partial sync failure (some items succeed, some fail)
- [ ] Logout with unsynced changes (warn user)
- [ ] Delete local data with cloud backup
- [ ] MongoDB connection timeout

### 5.3 Hive Type Adapter Regeneration
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Verify new fields are properly serialized
- [ ] Test backward compatibility with existing saves

---

## Phase 6: Documentation & Polish 📝

### 6.1 Update Documentation
**File**: `CLAUDE.md`
- [ ] Add cloud sync architecture section
- [ ] Document Auth0 setup steps
- [ ] Document MongoDB setup steps
- [ ] Add new dependencies to list
- [ ] Document sync commands and usage
- [ ] Update testing guidelines

### 6.2 User Guide
- [ ] Create simple guide for first-time setup
- [ ] Explain sync behavior and timing
- [ ] Document privacy/data storage details
- [ ] Add troubleshooting section

### 6.3 Configuration Files
**File**: `lib/config/app_config.dart` (new)
- [ ] Store Auth0 configuration
- [ ] Store MongoDB configuration
- [ ] Environment-specific configs (dev/prod)
- [ ] Add to .gitignore for security

---

## Progress Tracking

**Current Status**: Phase 1 - Setup & Dependencies (Starting)

**Completed Tasks**: 1 / 60+
**Current Phase**: Phase 1
**Blockers**: None

**Next Steps**:
1. Add dependencies to pubspec.yaml
2. Set up MongoDB Atlas account
3. Set up Auth0 account
4. Create authentication service

---

## Notes & Decisions

### Architecture Decisions
- **Why Hybrid?**: Keep offline functionality, cloud sync is optional enhancement
- **Why Manual Sync?**: Simpler implementation, user control, less battery drain
- **Why Auth0?**: Industry standard, easy Flutter integration, generous free tier
- **Why MongoDB?**: Flexible schema, good Dart support, generous free tier

### Security Considerations
- Auth0 tokens stored in flutter_secure_storage (encrypted)
- MongoDB connection string not hardcoded (use environment config)
- User data filtered by Auth0 user ID (row-level security)
- No sensitive data in logs or error messages

### Performance Considerations
- Batch sync operations to reduce network calls
- Sync only changed items (use syncedToCloud flag)
- Compress large payloads if needed
- Add pagination if user has 1000+ nodes

### Future Enhancements (Out of Scope)
- Real-time sync with WebSockets
- Automatic background sync
- Conflict resolution UI (currently: last-write-wins)
- Team/shared workspaces
- Version history / undo
- Data export to other formats

---

**Last Updated**: 2025-12-02
**Version**: 0.7.0-dev (targeting v0.8.0 release)
