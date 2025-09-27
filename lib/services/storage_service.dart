import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_node.dart';
import '../models/connection.dart';

class StorageService {
  static const String _nodesKey = 'graph_todo_nodes';
  static const String _connectionsKey = 'graph_todo_connections';
  static const String _canvasStateKey = 'graph_todo_canvas_state';

  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void saveNodes(List<TodoNode> nodes) {
    if (_prefs == null) return;
    
    final nodeJsonList = nodes.map((node) => node.toJson()).toList();
    final jsonString = jsonEncode(nodeJsonList);
    _prefs!.setString(_nodesKey, jsonString);
  }

  static List<TodoNode> loadNodes() {
    if (_prefs == null) return [];
    
    final jsonString = _prefs!.getString(_nodesKey);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => TodoNode.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static void saveConnections(List<Connection> connections) {
    if (_prefs == null) return;
    
    final connectionJsonList = connections.map((conn) => conn.toJson()).toList();
    final jsonString = jsonEncode(connectionJsonList);
    _prefs!.setString(_connectionsKey, jsonString);
  }

  static List<Connection> loadConnections() {
    if (_prefs == null) return [];
    
    final jsonString = _prefs!.getString(_connectionsKey);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Connection.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static void saveCanvasState({
    required double scale,
    required double panX,
    required double panY,
  }) {
    if (_prefs == null) return;
    
    final canvasState = {
      'scale': scale,
      'panX': panX,
      'panY': panY,
    };
    final jsonString = jsonEncode(canvasState);
    _prefs!.setString(_canvasStateKey, jsonString);
  }

  static Map<String, double> loadCanvasState() {
    if (_prefs == null) return {'scale': 1.0, 'panX': 0.0, 'panY': 0.0};
    
    final jsonString = _prefs!.getString(_canvasStateKey);
    if (jsonString == null) return {'scale': 1.0, 'panX': 0.0, 'panY': 0.0};
    
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return {
        'scale': (json['scale'] ?? 1.0).toDouble(),
        'panX': (json['panX'] ?? 0.0).toDouble(),
        'panY': (json['panY'] ?? 0.0).toDouble(),
      };
    } catch (e) {
      return {'scale': 1.0, 'panX': 0.0, 'panY': 0.0};
    }
  }

  static void saveAllData({
    required List<TodoNode> nodes,
    required List<Connection> connections,
    required double scale,
    required double panX,
    required double panY,
  }) {
    saveNodes(nodes);
    saveConnections(connections);
    saveCanvasState(scale: scale, panX: panX, panY: panY);
  }

  static void clearAllData() {
    if (_prefs == null) return;
    
    _prefs!.remove(_nodesKey);
    _prefs!.remove(_connectionsKey);
    _prefs!.remove(_canvasStateKey);
  }
}