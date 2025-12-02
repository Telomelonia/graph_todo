import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/mongodb_sync_service.dart';
import '../services/auth_service.dart';
import '../models/todo_node.dart';
import '../models/connection.dart';
import '../config/app_config.dart';

/// Sync status states.
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  notConfigured,
  notAuthenticated,
  offline,
}

/// Provider for cloud sync state management.
///
/// This provider handles:
/// - Sync status tracking
/// - Manual sync triggering
/// - Last sync time tracking
/// - Network connectivity monitoring
/// - Error handling
class SyncProvider extends ChangeNotifier {
  final AuthService _authService;
  MongoDBSyncService? _syncService;

  SyncStatus _status = SyncStatus.idle;
  String? _error;
  DateTime? _lastSyncTime;
  bool _isOnline = true;
  SyncStats? _syncStats;

  // Progress tracking
  int _uploadedNodes = 0;
  int _uploadedConnections = 0;
  int _downloadedNodes = 0;
  int _downloadedConnections = 0;

  SyncProvider({required AuthService authService})
      : _authService = authService {
    _checkConfiguration();
    _monitorConnectivity();
  }

  /// Current sync status.
  SyncStatus get status => _status;

  /// Error message from last sync operation.
  String? get error => _error;

  /// Last successful sync time.
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Whether the device is online.
  bool get isOnline => _isOnline;

  /// Sync statistics from MongoDB.
  SyncStats? get syncStats => _syncStats;

  /// Progress indicators.
  int get uploadedNodes => _uploadedNodes;
  int get uploadedConnections => _uploadedConnections;
  int get downloadedNodes => _downloadedNodes;
  int get downloadedConnections => _downloadedConnections;

  /// User-friendly status message.
  String get statusMessage {
    switch (_status) {
      case SyncStatus.idle:
        if (_lastSyncTime != null) {
          final duration = DateTime.now().difference(_lastSyncTime!);
          if (duration.inMinutes < 1) {
            return 'Synced just now';
          } else if (duration.inHours < 1) {
            return 'Synced ${duration.inMinutes}m ago';
          } else if (duration.inDays < 1) {
            return 'Synced ${duration.inHours}h ago';
          } else {
            return 'Synced ${duration.inDays}d ago';
          }
        }
        return 'Not synced yet';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.success:
        return 'Sync complete!';
      case SyncStatus.error:
        return 'Sync failed';
      case SyncStatus.notConfigured:
        return 'Cloud sync not configured';
      case SyncStatus.notAuthenticated:
        return 'Please login to sync';
      case SyncStatus.offline:
        return 'No internet connection';
    }
  }

  /// Check if cloud sync is properly configured.
  void _checkConfiguration() {
    if (!AppConfig.isCloudSyncConfigured) {
      _status = SyncStatus.notConfigured;
      notifyListeners();
    }
  }

  /// Monitor network connectivity.
  void _monitorConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _isOnline = result != ConnectivityResult.none;

      if (!_isOnline && _status == SyncStatus.syncing) {
        _status = SyncStatus.offline;
        _error = 'Lost internet connection during sync';
      } else if (_isOnline && _status == SyncStatus.offline) {
        _status = SyncStatus.idle;
        _error = null;
      }

      notifyListeners();
    });
  }

  /// Initialize MongoDB sync service.
  Future<void> _initializeSyncService() async {
    if (_syncService != null) return;

    _syncService = MongoDBSyncService(
      connectionString: AppConfig.mongoDBConnectionString,
      authService: _authService,
    );
  }

  /// Perform a full sync operation.
  ///
  /// Uploads local data and downloads cloud data.
  /// Returns the list of nodes and connections from the cloud.
  Future<Map<String, dynamic>?> sync({
    required List<TodoNode> localNodes,
    required List<Connection> localConnections,
  }) async {
    // Check configuration
    if (!AppConfig.isCloudSyncConfigured) {
      _status = SyncStatus.notConfigured;
      _error = 'Cloud sync is not configured. Update app_config.dart';
      notifyListeners();
      return null;
    }

    // Check authentication
    final isAuthenticated = await _authService.isAuthenticated();
    if (!isAuthenticated) {
      _status = SyncStatus.notAuthenticated;
      _error = 'Please login to sync your data';
      notifyListeners();
      return null;
    }

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _status = SyncStatus.offline;
      _error = 'No internet connection';
      _isOnline = false;
      notifyListeners();
      return null;
    }

    // Start sync
    _status = SyncStatus.syncing;
    _error = null;
    _uploadedNodes = 0;
    _uploadedConnections = 0;
    _downloadedNodes = 0;
    _downloadedConnections = 0;
    notifyListeners();

    try {
      // Initialize sync service
      await _initializeSyncService();

      // Perform full sync
      final result = await _syncService!.fullSync(
        localNodes: localNodes,
        localConnections: localConnections,
      );

      // Update progress
      _uploadedNodes = result.uploadedNodes;
      _uploadedConnections = result.uploadedConnections;
      _downloadedNodes = result.downloadedNodes;
      _downloadedConnections = result.downloadedConnections;

      // Get sync stats
      _syncStats = await _syncService!.getSyncStats();

      // Success
      _status = SyncStatus.success;
      _lastSyncTime = DateTime.now();
      notifyListeners();

      // Reset to idle after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (_status == SyncStatus.success) {
          _status = SyncStatus.idle;
          notifyListeners();
        }
      });

      return {
        'nodes': result.cloudNodes,
        'connections': result.cloudConnections,
      };
    } catch (e) {
      _status = SyncStatus.error;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Delete a node from the cloud.
  Future<bool> deleteNodeFromCloud(String nodeId) async {
    if (_syncService == null) return false;

    try {
      await _syncService!.deleteNode(nodeId);
      return true;
    } catch (e) {
      _error = 'Failed to delete node from cloud: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a connection from the cloud.
  Future<bool> deleteConnectionFromCloud(String connectionId) async {
    if (_syncService == null) return false;

    try {
      await _syncService!.deleteConnection(connectionId);
      return true;
    } catch (e) {
      _error = 'Failed to delete connection from cloud: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear all cloud data for the current user.
  /// WARNING: This is destructive!
  Future<bool> clearCloudData() async {
    if (_syncService == null) {
      await _initializeSyncService();
    }

    try {
      await _syncService!.clearAllData();
      _syncStats = SyncStats(nodeCount: 0, connectionCount: 0);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to clear cloud data: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get sync statistics from the cloud.
  Future<void> fetchSyncStats() async {
    if (_syncService == null) {
      await _initializeSyncService();
    }

    try {
      _syncStats = await _syncService!.getSyncStats();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch sync stats: $e';
      notifyListeners();
    }
  }

  /// Clear error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset sync state.
  void reset() {
    _status = SyncStatus.idle;
    _error = null;
    _uploadedNodes = 0;
    _uploadedConnections = 0;
    _downloadedNodes = 0;
    _downloadedConnections = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _syncService?.disconnect();
    super.dispose();
  }
}
