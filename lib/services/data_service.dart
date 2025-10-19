import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/todo_node.dart';
import '../models/connection.dart';
import 'package:flutter/foundation.dart';

class DataService {
  static const String _fileExtension = 'graphtodo';
  static const String _currentVersion = '1.0.0';

  /// Export data to a JSON file with user-selected location
  static Future<String?> exportData({
    required List<TodoNode> nodes,
    required List<Connection> connections,
    required Map<String, dynamic> canvasState,
  }) async {
    try {
      // Create export data structure
      final exportData = {
        'version': _currentVersion,
        'exportDate': DateTime.now().toIso8601String(),
        'nodes': nodes.map((node) => node.toJson()).toList(),
        'connections': connections.map((conn) => conn.toJson()).toList(),
        'canvasState': canvasState,
      };

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      if (kIsWeb) {
        // For web, we'll return the JSON string and let the UI handle download
        return jsonString;
      } else {
        // For mobile/desktop, let user choose the save location
        final fileName = 'graphtodo_export_${DateTime.now().millisecondsSinceEpoch}.$_fileExtension';
        
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save GraphTodo Export',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: [_fileExtension],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(jsonString);
          return file.path;
        } else {
          // User cancelled the save dialog
          return 'cancelled';
        }
      }
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return null;
    }
  }

  /// Import data from a JSON file
  static Future<ImportResult> importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [_fileExtension, 'json'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String jsonString;
        
        if (kIsWeb) {
          // For web, read from bytes
          final bytes = result.files.single.bytes;
          if (bytes == null) {
            return ImportResult.error('Failed to read file');
          }
          jsonString = utf8.decode(bytes);
        } else {
          // For mobile/desktop, read from file path
          final file = File(result.files.single.path!);
          jsonString = await file.readAsString();
        }

        return _parseImportData(jsonString);
      } else {
        return ImportResult.cancelled();
      }
    } catch (e) {
      debugPrint('Error importing data: $e');
      return ImportResult.error('Failed to import file: ${e.toString()}');
    }
  }

  /// Parse and validate imported JSON data
  static ImportResult _parseImportData(String jsonString) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // Validate required fields
      if (!data.containsKey('nodes') || !data.containsKey('connections')) {
        return ImportResult.error('Invalid file format: missing required data');
      }

      // Parse nodes
      final List<TodoNode> nodes = [];
      final nodesList = data['nodes'] as List?;
      if (nodesList != null) {
        for (final nodeData in nodesList) {
          try {
            nodes.add(TodoNode.fromJson(nodeData as Map<String, dynamic>));
          } catch (e) {
            return ImportResult.error('Invalid node data: ${e.toString()}');
          }
        }
      }

      // Parse connections
      final List<Connection> connections = [];
      final connectionsList = data['connections'] as List?;
      if (connectionsList != null) {
        for (final connData in connectionsList) {
          try {
            connections.add(Connection.fromJson(connData as Map<String, dynamic>));
          } catch (e) {
            return ImportResult.error('Invalid connection data: ${e.toString()}');
          }
        }
      }

      // Parse canvas state (optional, with defaults)
      final Map<String, dynamic> canvasState = {
        'panOffset': {'dx': 0.0, 'dy': 0.0},
        'scale': 1.0,
        ...?data['canvasState'] as Map<String, dynamic>?,
      };

      // Version info (optional)
      final String? version = data['version'] as String?;
      final String? exportDate = data['exportDate'] as String?;

      return ImportResult.success(
        nodes: nodes,
        connections: connections,
        canvasState: canvasState,
        version: version,
        exportDate: exportDate,
      );
    } catch (e) {
      return ImportResult.error('Failed to parse file: ${e.toString()}');
    }
  }

  /// Validate that all connections reference existing nodes
  static bool validateConnections(List<TodoNode> nodes, List<Connection> connections) {
    final nodeIds = nodes.map((n) => n.id).toSet();
    
    for (final connection in connections) {
      if (!nodeIds.contains(connection.fromNodeId) || 
          !nodeIds.contains(connection.toNodeId)) {
        return false;
      }
    }
    return true;
  }
}

/// Result of an import operation
class ImportResult {
  final bool success;
  final bool cancelled;
  final String? error;
  final List<TodoNode>? nodes;
  final List<Connection>? connections;
  final Map<String, dynamic>? canvasState;
  final String? version;
  final String? exportDate;

  ImportResult._({
    required this.success,
    this.cancelled = false,
    this.error,
    this.nodes,
    this.connections,
    this.canvasState,
    this.version,
    this.exportDate,
  });

  factory ImportResult.success({
    required List<TodoNode> nodes,
    required List<Connection> connections,
    required Map<String, dynamic> canvasState,
    String? version,
    String? exportDate,
  }) {
    return ImportResult._(
      success: true,
      nodes: nodes,
      connections: connections,
      canvasState: canvasState,
      version: version,
      exportDate: exportDate,
    );
  }

  factory ImportResult.error(String message) {
    return ImportResult._(
      success: false,
      error: message,
    );
  }

  factory ImportResult.cancelled() {
    return ImportResult._(
      success: false,
      cancelled: true,
    );
  }
}