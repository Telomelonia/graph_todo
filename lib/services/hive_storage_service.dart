import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_node.dart';
import '../models/connection.dart';
import '../models/offset_adapter.dart';
import '../models/color_adapter.dart';

/// Hive-based local storage service for persistent data storage
/// Provides efficient binary serialization with automatic save/load
class HiveStorageService {
  // Box names
  static const String _nodesBoxName = 'graph_todo_nodes';
  static const String _connectionsBoxName = 'graph_todo_connections';
  static const String _canvasStateBoxName = 'graph_todo_canvas_state';

  // Box instances
  static Box<TodoNode>? _nodesBox;
  static Box<Connection>? _connectionsBox;
  static Box<Map<dynamic, dynamic>>? _canvasStateBox;

  /// Initialize Hive and register all adapters
  /// Must be called before any other methods
  static Future<void> initialize() async {
    try {
      // Initialize Hive for Flutter (sets up path automatically)
      await Hive.initFlutter();

      // Register custom type adapters for dart:ui types
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(OffsetAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(ColorAdapter());
      }

      // Register generated adapters for models
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TodoNodeAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ConnectionAdapter());
      }

      // Open boxes for data storage
      _nodesBox = await Hive.openBox<TodoNode>(_nodesBoxName);
      _connectionsBox = await Hive.openBox<Connection>(_connectionsBoxName);
      _canvasStateBox = await Hive.openBox<Map<dynamic, dynamic>>(_canvasStateBoxName);
    } catch (e) {
      throw Exception('Failed to initialize Hive: $e');
    }
  }

  /// Save list of nodes to Hive
  static Future<void> saveNodes(List<TodoNode> nodes) async {
    if (_nodesBox == null) {
      throw Exception('Hive not initialized. Call initialize() first.');
    }

    try {
      // Clear existing data and save new nodes
      await _nodesBox!.clear();
      for (int i = 0; i < nodes.length; i++) {
        await _nodesBox!.put(i, nodes[i]);
      }
    } catch (e) {
      throw Exception('Failed to save nodes: $e');
    }
  }

  /// Load list of nodes from Hive
  static List<TodoNode> loadNodes() {
    if (_nodesBox == null) {
      throw Exception('Hive not initialized. Call initialize() first.');
    }

    try {
      // Return all values from the box as a list
      return _nodesBox!.values.toList();
    } catch (e) {
      // Return empty list if loading fails
      return [];
    }
  }

  /// Save list of connections to Hive
  static Future<void> saveConnections(List<Connection> connections) async {
    if (_connectionsBox == null) {
      throw Exception('Hive not initialized. Call initialize() first.');
    }

    try {
      // Clear existing data and save new connections
      await _connectionsBox!.clear();
      for (int i = 0; i < connections.length; i++) {
        await _connectionsBox!.put(i, connections[i]);
      }
    } catch (e) {
      throw Exception('Failed to save connections: $e');
    }
  }

  /// Load list of connections from Hive
  static List<Connection> loadConnections() {
    if (_connectionsBox == null) {
      throw Exception('Hive not initialized. Call initialize() first.');
    }

    try {
      // Return all values from the box as a list
      return _connectionsBox!.values.toList();
    } catch (e) {
      // Return empty list if loading fails
      return [];
    }
  }

  /// Save canvas state (pan offset and zoom scale)
  static Future<void> saveCanvasState({
    required double scale,
    required double panX,
    required double panY,
  }) async {
    if (_canvasStateBox == null) {
      throw Exception('Hive not initialized. Call initialize() first.');
    }

    try {
      final canvasState = {
        'scale': scale,
        'panX': panX,
        'panY': panY,
        'lastSaved': DateTime.now().toIso8601String(),
      };
      await _canvasStateBox!.put('state', canvasState);
    } catch (e) {
      throw Exception('Failed to save canvas state: $e');
    }
  }

  /// Load canvas state from Hive
  /// Returns default values if no state exists
  static Map<String, double> loadCanvasState() {
    if (_canvasStateBox == null) {
      throw Exception('Hive not initialized. Call initialize() first.');
    }

    try {
      final state = _canvasStateBox!.get('state');
      if (state == null) {
        return {'scale': 1.0, 'panX': 0.0, 'panY': 0.0};
      }

      return {
        'scale': (state['scale'] as num?)?.toDouble() ?? 1.0,
        'panX': (state['panX'] as num?)?.toDouble() ?? 0.0,
        'panY': (state['panY'] as num?)?.toDouble() ?? 0.0,
      };
    } catch (e) {
      // Return default values if loading fails
      return {'scale': 1.0, 'panX': 0.0, 'panY': 0.0};
    }
  }

  /// Save all data at once (nodes, connections, and canvas state)
  /// Useful for batch operations and periodic auto-saves
  static Future<void> saveAllData({
    required List<TodoNode> nodes,
    required List<Connection> connections,
    required double scale,
    required double panX,
    required double panY,
  }) async {
    try {
      // Save all data in parallel for better performance
      await Future.wait([
        saveNodes(nodes),
        saveConnections(connections),
        saveCanvasState(scale: scale, panX: panX, panY: panY),
      ]);
    } catch (e) {
      throw Exception('Failed to save all data: $e');
    }
  }

  /// Clear all stored data (useful for reset/logout)
  static Future<void> clearAllData() async {
    if (_nodesBox == null || _connectionsBox == null || _canvasStateBox == null) {
      throw Exception('Hive not initialized. Call initialize() first.');
    }

    try {
      await Future.wait([
        _nodesBox!.clear(),
        _connectionsBox!.clear(),
        _canvasStateBox!.clear(),
      ]);
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  /// Check if there is any saved data
  static bool hasData() {
    if (_nodesBox == null || _connectionsBox == null) {
      return false;
    }
    return _nodesBox!.isNotEmpty || _connectionsBox!.isNotEmpty;
  }

  /// Close all Hive boxes (call this when app is closing)
  static Future<void> close() async {
    await _nodesBox?.close();
    await _connectionsBox?.close();
    await _canvasStateBox?.close();
  }

  /// Get the total number of nodes stored
  static int getNodesCount() {
    return _nodesBox?.length ?? 0;
  }

  /// Get the total number of connections stored
  static int getConnectionsCount() {
    return _connectionsBox?.length ?? 0;
  }
}
