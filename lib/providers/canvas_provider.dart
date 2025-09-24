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
  bool _isAddNodeMode = false;
  bool _isEraserMode = false;
  String? _selectedNodeForConnection;
  TodoNode? _draggedNode;
  String? _newlyCreatedNodeId; // Track newly created node for immediate editing
  

  // Getters
  List<TodoNode> get nodes => List.unmodifiable(_nodes);
  List<Connection> get connections => List.unmodifiable(_connections);
  Offset get panOffset => _panOffset;
  double get scale => _scale;
  bool get isConnectMode => _isConnectMode;
  bool get isAddNodeMode => _isAddNodeMode;
  bool get isEraserMode => _isEraserMode;
  String? get selectedNodeForConnection => _selectedNodeForConnection;
  TodoNode? get draggedNode => _draggedNode;
  String? get newlyCreatedNodeId => _newlyCreatedNodeId;


  // Add a new node at the given position with immediate editing and zoom
  void addNode(Offset position, {String text = '', Size? viewSize}) {
    // Calculate base node size as 14% of the smaller screen dimension
    double baseSize = 60.0; // fallback size
    if (viewSize != null) {
      baseSize = (viewSize.width < viewSize.height ? viewSize.width : viewSize.height) * 0.14;
    }

    // Calculate node size inversely proportional to scale
    // When zoomed in (scale > 1), nodes are smaller in canvas coordinates
    // When zoomed out (scale < 1), nodes are larger in canvas coordinates
    // This keeps the visual size consistent on screen
    final canvasRelativeSize = baseSize / _scale;

    final node = TodoNode(
      id: _uuid.v4(),
      text: text.isEmpty ? '' : text, // Start with empty text for immediate editing
      position: position,
      size: canvasRelativeSize,
    );
    _nodes.add(node);
    _newlyCreatedNodeId = node.id; // Mark as newly created for immediate editing

    // Zoom to the new node for better editing experience
    if (viewSize != null) {
      zoomToNodeWithScreenSize(node.id, viewSize);
    }

    // Auto-exit add node mode after creating a node
    exitAddNodeMode();
    
    notifyListeners();
  }

  // Zoom to a specific node with proper screen size calculation
  void zoomToNodeWithScreenSize(String nodeId, Size screenSize, {double targetScale = 1.5}) {
    final node = _nodes.firstWhere((n) => n.id == nodeId);

    // Calculate the center of the screen
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);

    // Set the pan offset so the node appears at screen center
    final targetPanOffset = screenCenter - (node.position * targetScale);

    _panOffset = targetPanOffset;
    _scale = targetScale;
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
      final wasCompleted = _nodes[index].isCompleted;
      _nodes[index] = _nodes[index].copyWith(
        isCompleted: !_nodes[index].isCompleted,
      );
      
      // If node was just completed, trigger charging animations
      if (!wasCompleted && _nodes[index].isCompleted) {
        _startChargingAnimations(nodeId);
      }
      
      _updateConnectionStates();
      notifyListeners();
    }
  }

  // Start charging animations for connections involving the completed node
  void _startChargingAnimations(String completedNodeId) {
    final relatedConnections = _connections.where(
      (conn) => conn.fromNodeId == completedNodeId || conn.toNodeId == completedNodeId,
    );

    for (final connection in relatedConnections) {
      // Only start charging if the other node is not yet completed
      final otherNodeId = connection.fromNodeId == completedNodeId 
          ? connection.toNodeId 
          : connection.fromNodeId;
      final otherNode = _nodes.firstWhere((n) => n.id == otherNodeId);
      
      if (!otherNode.isCompleted) {
        _startConnectionChargingAnimation(connection.id, completedNodeId);
      }
    }
  }

  // Start charging animation for a specific connection
  void _startConnectionChargingAnimation(String connectionId, String completedNodeId) {
    final connectionIndex = _connections.indexWhere((c) => c.id == connectionId);
    if (connectionIndex != -1) {
      _connections[connectionIndex] = _connections[connectionIndex].copyWith(
        isCharging: true,
        chargingProgress: 0.0,
        chargingFromNodeId: completedNodeId,
      );
      
      // Simulate charging progress over time
      Future.delayed(Duration.zero, () async {
        for (double progress = 0.0; progress <= 1.0; progress += 0.05) {
          await Future.delayed(const Duration(milliseconds: 50));
          final index = _connections.indexWhere((c) => c.id == connectionId);
          if (index != -1 && _connections[index].isCharging) {
            _connections[index] = _connections[index].copyWith(
              chargingProgress: progress,
            );
            notifyListeners();
          }
        }
        
        // Stop charging animation
        final index = _connections.indexWhere((c) => c.id == connectionId);
        if (index != -1) {
          _connections[index] = _connections[index].copyWith(
            isCharging: false,
            chargingProgress: 0.0,
            chargingFromNodeId: null,
          );
          notifyListeners();
        }
      });
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
    _scale = newScale.clamp(0.1, 5.0);
    notifyListeners();
  }

  void zoom(double scaleDelta, Offset focalPoint) {
    final oldScale = _scale;
    final newScale = (_scale * scaleDelta).clamp(0.1, 5.0);

    if (newScale != oldScale) {
      // Adjust pan offset to keep focal point stationary during zoom
      final focalPointCanvas = screenToCanvas(focalPoint);
      _scale = newScale;
      final newFocalPointScreen = canvasToScreen(focalPointCanvas);
      _panOffset += focalPoint - newFocalPointScreen;
      notifyListeners();
    }
  }

  // Alternative zoom method that takes absolute scale value
  void setZoom(double newScale, Offset focalPoint) {
    final clampedScale = newScale.clamp(0.1, 5.0);

    if (clampedScale != _scale) {
      // Adjust pan offset to keep focal point stationary during zoom
      final focalPointCanvas = screenToCanvas(focalPoint);
      _scale = clampedScale;
      final newFocalPointScreen = canvasToScreen(focalPointCanvas);
      _panOffset += focalPoint - newFocalPointScreen;
      notifyListeners();
    }
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

  // Add node mode management
  void toggleAddNodeMode() {
    _isAddNodeMode = !_isAddNodeMode;
    notifyListeners();
  }

  void exitAddNodeMode() {
    _isAddNodeMode = false;
    notifyListeners();
  }

  // Eraser mode management
  void toggleEraserMode() {
    _isEraserMode = !_isEraserMode;
    // Exit other modes when entering eraser mode
    if (_isEraserMode) {
      _isConnectMode = false;
      _isAddNodeMode = false;
      _selectedNodeForConnection = null;
    }
    notifyListeners();
  }

  void exitEraserMode() {
    _isEraserMode = false;
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

  // Start connection from a specific node (hover functionality)
  void startConnectionFromNode(String nodeId) {
    _isConnectMode = true;
    _selectedNodeForConnection = nodeId;
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

  // Remove a specific connection by ID
  void removeConnection(String connectionId) {
    _connections.removeWhere((conn) => conn.id == connectionId);
    notifyListeners();
  }

  // Update connection endpoint to reconnect to a different node
  void updateConnectionEndpoint(String connectionId, bool isFromEndpoint, String newNodeId) {
    final connectionIndex = _connections.indexWhere((conn) => conn.id == connectionId);
    if (connectionIndex != -1) {
      final connection = _connections[connectionIndex];
      
      // Check if the new connection would be valid (not connecting node to itself)
      final otherNodeId = isFromEndpoint ? connection.toNodeId : connection.fromNodeId;
      if (newNodeId == otherNodeId) return;
      
      // Check if connection already exists
      final newFromNodeId = isFromEndpoint ? newNodeId : connection.fromNodeId;
      final newToNodeId = isFromEndpoint ? connection.toNodeId : newNodeId;
      
      final exists = _connections.any(
        (conn) =>
            conn.id != connectionId && // Don't check against the current connection
            ((conn.fromNodeId == newFromNodeId && conn.toNodeId == newToNodeId) ||
             (conn.fromNodeId == newToNodeId && conn.toNodeId == newFromNodeId)),
      );
      
      if (!exists) {
        _connections[connectionIndex] = connection.copyWith(
          fromNodeId: newFromNodeId,
          toNodeId: newToNodeId,
        );
        _updateConnectionStates();
        notifyListeners();
      }
    }
  }

  // Update connection green state based on node completion
  void _updateConnectionStates() {
    for (int i = 0; i < _connections.length; i++) {
      final conn = _connections[i];
      final fromNode = _nodes.firstWhere((n) => n.id == conn.fromNodeId);
      final toNode = _nodes.firstWhere((n) => n.id == conn.toNodeId);

      final shouldBeGreen = fromNode.isCompleted && toNode.isCompleted;
      if (conn.isGreen != shouldBeGreen) {
        _connections[i] = conn.copyWith(isGreen: shouldBeGreen);
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

  // Check if a screen point hits a node
  bool isPointOnNode(Offset screenPoint, TodoNode node) {
    final canvasPoint = screenToCanvas(screenPoint);
    final distance = (node.position - canvasPoint).distance;
    return distance <= node.size / 2;
  }

  // Clear all nodes and connections
  void clearCanvas() {
    _nodes.clear();
    _connections.clear();
    _panOffset = Offset.zero;
    _scale = 1.0;
    _isConnectMode = false;
    _isAddNodeMode = false;
    _isEraserMode = false;
    _selectedNodeForConnection = null;
    _draggedNode = null;
    notifyListeners();
  }

  // Clear the newly created node flag when editing is complete
  void clearNewlyCreatedFlag() {
    _newlyCreatedNodeId = null;
    notifyListeners();
  }
}

