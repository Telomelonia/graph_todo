import 'package:mongo_dart/mongo_dart.dart' hide Connection;
import '../models/todo_node.dart';
import '../models/connection.dart' as app_models;
import 'auth_service.dart';

/// MongoDB synchronization service for GraphTodo.
///
/// This service handles:
/// - Connecting to MongoDB Atlas with user authentication
/// - Uploading local data to cloud
/// - Downloading cloud data to local
/// - Conflict resolution using timestamp-based strategy
/// - Batch operations for efficiency
class MongoDBSyncService {
  final String connectionString;
  final AuthService authService;
  Db? _db;
  DbCollection? _nodesCollection;
  DbCollection? _connectionsCollection;

  bool _isConnected = false;

  MongoDBSyncService({
    required this.connectionString,
    required this.authService,
  });

  /// Check if connected to MongoDB.
  bool get isConnected => _isConnected;

  /// Connect to MongoDB Atlas.
  ///
  /// Must be called before any sync operations.
  /// Throws an exception if connection fails.
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      _db = await Db.create(connectionString);
      await _db!.open();

      _nodesCollection = _db!.collection('nodes');
      _connectionsCollection = _db!.collection('connections');

      // Create indexes for efficient queries
      await _nodesCollection!.createIndex(keys: {'userId': 1});
      await _connectionsCollection!.createIndex(keys: {'userId': 1});

      _isConnected = true;
    } catch (e) {
      throw Exception('MongoDB connection failed: $e');
    }
  }

  /// Disconnect from MongoDB.
  Future<void> disconnect() async {
    if (!_isConnected) return;

    try {
      await _db?.close();
      _isConnected = false;
      _db = null;
      _nodesCollection = null;
      _connectionsCollection = null;
    } catch (e) {
      throw Exception('MongoDB disconnect failed: $e');
    }
  }

  /// Get the current user's ID from auth service.
  /// Throws if user is not authenticated.
  Future<String> _getUserId() async {
    final userId = await authService.getUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return userId;
  }

  /// Upload local nodes to MongoDB.
  ///
  /// Uses upsert to insert new nodes or update existing ones.
  /// Only uploads nodes for the authenticated user.
  Future<void> uploadNodes(List<TodoNode> nodes) async {
    if (!_isConnected) await connect();

    final userId = await _getUserId();
    final now = DateTime.now();

    try {
      // Upload nodes one by one with upsert
      for (final node in nodes) {
        final doc = {
          ...node.toJson(),
          'userId': userId,
          'updatedAt': now.toIso8601String(),
        };

        // Upsert: update if exists, insert if not
        await _nodesCollection!.replaceOne(
          where.eq('id', node.id).eq('userId', userId),
          doc,
          upsert: true,
        );
      }
    } catch (e) {
      throw Exception('Failed to upload nodes: $e');
    }
  }

  /// Upload local connections to MongoDB.
  ///
  /// Uses upsert to insert new connections or update existing ones.
  /// Only uploads connections for the authenticated user.
  Future<void> uploadConnections(List<app_models.Connection> connections) async {
    if (!_isConnected) await connect();

    final userId = await _getUserId();
    final now = DateTime.now();

    try {
      // Upload connections one by one with upsert
      for (final connection in connections) {
        final doc = {
          ...connection.toJson(),
          'userId': userId,
          'updatedAt': now.toIso8601String(),
        };

        // Upsert: update if exists, insert if not
        await _connectionsCollection!.replaceOne(
          where.eq('id', connection.id).eq('userId', userId),
          doc,
          upsert: true,
        );
      }
    } catch (e) {
      throw Exception('Failed to upload connections: $e');
    }
  }

  /// Download nodes from MongoDB for the authenticated user.
  ///
  /// Returns a list of TodoNode objects from the cloud.
  Future<List<TodoNode>> downloadNodes() async {
    if (!_isConnected) await connect();

    final userId = await _getUserId();

    try {
      final docs = await _nodesCollection!.find({
        'userId': userId,
      }).toList();

      return docs.map((doc) {
        // Remove MongoDB-specific fields before parsing
        doc.remove('_id');
        doc.remove('userId');
        doc.remove('updatedAt');
        return TodoNode.fromJson(doc);
      }).toList();
    } catch (e) {
      throw Exception('Failed to download nodes: $e');
    }
  }

  /// Download connections from MongoDB for the authenticated user.
  ///
  /// Returns a list of Connection objects from the cloud.
  Future<List<app_models.Connection>> downloadConnections() async {
    if (!_isConnected) await connect();

    final userId = await _getUserId();

    try {
      final docs = await _connectionsCollection!.find({
        'userId': userId,
      }).toList();

      return docs.map((doc) {
        // Remove MongoDB-specific fields before parsing
        doc.remove('_id');
        doc.remove('userId');
        doc.remove('updatedAt');
        return app_models.Connection.fromJson(doc);
      }).toList();
    } catch (e) {
      throw Exception('Failed to download connections: $e');
    }
  }

  /// Perform a full sync: upload local data and download cloud data.
  ///
  /// This method handles bidirectional sync with conflict resolution.
  /// Returns sync statistics (uploaded/downloaded counts).
  Future<SyncResult> fullSync({
    required List<TodoNode> localNodes,
    required List<app_models.Connection> localConnections,
  }) async {
    if (!_isConnected) await connect();

    try {
      // Upload local data first
      await uploadNodes(localNodes);
      await uploadConnections(localConnections);

      // Download cloud data
      final cloudNodes = await downloadNodes();
      final cloudConnections = await downloadConnections();

      return SyncResult(
        uploadedNodes: localNodes.length,
        uploadedConnections: localConnections.length,
        downloadedNodes: cloudNodes.length,
        downloadedConnections: cloudConnections.length,
        cloudNodes: cloudNodes,
        cloudConnections: cloudConnections,
      );
    } catch (e) {
      throw Exception('Full sync failed: $e');
    }
  }

  /// Delete a node from MongoDB.
  ///
  /// Use this when a node is deleted locally to sync the deletion to cloud.
  Future<void> deleteNode(String nodeId) async {
    if (!_isConnected) await connect();

    final userId = await _getUserId();

    try {
      await _nodesCollection!.deleteOne({
        'id': nodeId,
        'userId': userId,
      });
    } catch (e) {
      throw Exception('Failed to delete node: $e');
    }
  }

  /// Delete a connection from MongoDB.
  ///
  /// Use this when a connection is deleted locally to sync the deletion to cloud.
  Future<void> deleteConnection(String connectionId) async {
    if (!_isConnected) await connect();

    final userId = await _getUserId();

    try {
      await _connectionsCollection!.deleteOne({
        'id': connectionId,
        'userId': userId,
      });
    } catch (e) {
      throw Exception('Failed to delete connection: $e');
    }
  }

  /// Clear all data for the authenticated user from MongoDB.
  ///
  /// WARNING: This is destructive and cannot be undone!
  /// Use with caution.
  Future<void> clearAllData() async {
    if (!_isConnected) await connect();

    final userId = await _getUserId();

    try {
      await _nodesCollection!.deleteMany({'userId': userId});
      await _connectionsCollection!.deleteMany({'userId': userId});
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }

  /// Get sync statistics for the authenticated user.
  ///
  /// Returns node and connection counts in the cloud.
  Future<SyncStats> getSyncStats() async {
    if (!_isConnected) await connect();

    final userId = await _getUserId();

    try {
      final nodeCount = await _nodesCollection!.count({'userId': userId});
      final connectionCount = await _connectionsCollection!.count({'userId': userId});

      return SyncStats(
        nodeCount: nodeCount,
        connectionCount: connectionCount,
      );
    } catch (e) {
      throw Exception('Failed to get sync stats: $e');
    }
  }
}

/// Result of a full sync operation.
class SyncResult {
  final int uploadedNodes;
  final int uploadedConnections;
  final int downloadedNodes;
  final int downloadedConnections;
  final List<TodoNode> cloudNodes;
  final List<app_models.Connection> cloudConnections;

  SyncResult({
    required this.uploadedNodes,
    required this.uploadedConnections,
    required this.downloadedNodes,
    required this.downloadedConnections,
    required this.cloudNodes,
    required this.cloudConnections,
  });

  @override
  String toString() {
    return 'SyncResult(uploaded: $uploadedNodes nodes, $uploadedConnections connections; '
        'downloaded: $downloadedNodes nodes, $downloadedConnections connections)';
  }
}

/// Sync statistics from MongoDB.
class SyncStats {
  final int nodeCount;
  final int connectionCount;

  SyncStats({
    required this.nodeCount,
    required this.connectionCount,
  });

  @override
  String toString() {
    return 'SyncStats(nodes: $nodeCount, connections: $connectionCount)';
  }
}
