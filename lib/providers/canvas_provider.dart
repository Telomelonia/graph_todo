import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_node.dart';
import '../models/connection.dart';

class CanvasProvider with ChangeNotifier {
  final List<TodoNode> _nodes = [];
  final List<Connection> _connections = [];
  final Uuid _uuid = const Uuid();

  // Canvas transform properties
  Offset _panOffset = Offset.zero;
  double _scale = 1.0;

  // Interaction state
  bool _isConnectMode = false;
  String? _selectedNodeForConnection;
  TodoNode? _draggedNode;

  // Getters
  List<TodoNode> get nodes => List.unmodifiable(_nodes);
  List<Connection> get connections => List.unmodifiable(_connections);
  Offset get panOffset => _panOffset;
  double get scale => _scale;
  bool get isConnectMode => _isConnectMode;
  String? get selectedNodeForConnection => _selectedNodeForConnection;
  TodoNode? get draggedNode => _draggedNode;

  // Add a new node at the given position
  void addNode(Offset position, {String text = 'New Task'}) {
    final node = TodoNode(
      id: _uuid.v4(),
      text: text,
      position: position,
    );
    _nodes.add(node);
    notifyListeners();
  }

  // Update node text
  void updateNodeText(String nodeId, String newText) {
    final index = _nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      _nodes[index] = _nodes[index].copyWith(text: newText);
      notifyListeners();
    }
  }

  // Update node position
  void updateNodePosition(String nodeId, Offset newPosition) {
    final index = _nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      _nodes[index] = _nodes[index].copyWith(position: newPosition);
      notifyListeners();
    }
  }

  // Toggle node completion
  void toggleNodeCompletion(String nodeId) {
    final index = _nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      _nodes[index] = _nodes[index].copyWith(
        isCompleted: !_nodes[index].isCompleted,
      );
      _updateConnectionStates();
      notifyListeners();
    }
  }

  // Remove a node and its connections
  void removeNode(String nodeId) {
    _nodes.removeWhere((node) => node.id == nodeId);
    _connections.removeWhere(
          (conn) => conn.fromNodeId == nodeId || conn.toNodeId == nodeId,
    );
    notifyListeners();
  }

  // Canvas pan and zoom
  void updatePanOffset(Offset delta) {
    _panOffset += delta;
    notifyListeners();
  }

  void updateScale(double newScale) {
    _scale = newScale.clamp(0.5, 3.0);
    notifyListeners();
  }

  // Connection mode management
  void toggleConnectMode() {
    _isConnectMode = !_isConnectMode;
    _selectedNodeForConnection = null;
    notifyListeners();
  }

  void exitConnectMode() {
    _isConnectMode = false;
    _selectedNodeForConnection = null;
    notifyListeners();
  }

  // Handle node selection for connection
  void selectNodeForConnection(String nodeId) {
    if (!_isConnectMode) return;

    if (_selectedNodeForConnection == null) {
      _selectedNodeForConnection = nodeId;
    } else if (_selectedNodeForConnection != nodeId) {
      // Create connection between the two nodes
      createConnection(_selectedNodeForConnection!, nodeId);
      _selectedNodeForConnection = null;
      _isConnectMode = false;
    }
    notifyListeners();
  }

  // Create a connection between two nodes
  void createConnection(String fromNodeId, String toNodeId) {
    final newConnection = Connection(
      id: _uuid.v4(),
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
    );

    // Check if connection already exists
    final exists = _connections.any(
          (conn) =>
      (conn.fromNodeId == fromNodeId && conn.toNodeId == toNodeId) ||
          (conn.fromNodeId == toNodeId && conn.toNodeId == fromNodeId),
    );

    if (!exists) {
      _connections.add(newConnection);
      _updateConnectionStates();
      notifyListeners();
    }
  }

  // Update connection golden state based on node completion
  void _updateConnectionStates() {
    for (int i = 0; i < _connections.length; i++) {
      final conn = _connections[i];
      final fromNode = _nodes.firstWhere((n) => n.id == conn.fromNodeId);
      final toNode = _nodes.firstWhere((n) => n.id == conn.toNodeId);

      final shouldBeGolden = fromNode.isCompleted && toNode.isCompleted;
      if (conn.isGolden != shouldBeGolden) {
        _connections[i] = conn.copyWith(isGolden: shouldBeGolden);
      }
    }
  }

  // Drag operations
  void startDrag(TodoNode node) {
    _draggedNode = node;
  }

  void endDrag() {
    _draggedNode = null;
  }

  // Convert screen coordinates to canvas coordinates
  Offset screenToCanvas(Offset screenPoint) {
    return (screenPoint - _panOffset) / _scale;
  }

  // Convert canvas coordinates to screen coordinates
  Offset canvasToScreen(Offset canvasPoint) {
    return canvasPoint * _scale + _panOffset;
  }

  // Clear all nodes and connections
  void clearCanvas() {
    _nodes.clear();
    _connections.clear();
    _panOffset = Offset.zero;
    _scale = 1.0;
    _isConnectMode = false;
    _selectedNodeForConnection = null;
    _draggedNode = null;
    notifyListeners();
  }
}
