import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:developer' as developer;
import '../models/todo_node.dart';
import '../models/connection.dart';
import '../services/firebase_service.dart';

class CanvasProvider with ChangeNotifier {
  final List<TodoNode> _nodes = [];
  final List<Connection> _connections = [];
  final Uuid _uuid = const Uuid();
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<List<TodoNode>>? _nodesSubscription;
  StreamSubscription<List<Connection>>? _connectionsSubscription;
  bool _isInitialized = false;

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
  bool get isInitialized => _isInitialized;
  FirebaseService get firebaseService => _firebaseService;


  // Initialize Firebase listeners
  Future<void> initializeFirebase() async {
    if (_isInitialized) return;
    
    if (_firebaseService.isSignedIn) {
      try {
        // Listen to nodes changes
        _nodesSubscription = _firebaseService.getNodesStream().listen((nodes) {
          _nodes.clear();
          _nodes.addAll(nodes);
          _updateConnectionStates();
          notifyListeners();
        });
        
        // Listen to connections changes
        _connectionsSubscription = _firebaseService.getConnectionsStream().listen((connections) {
          _connections.clear();
          _connections.addAll(connections);
          _updateConnectionStates();
          notifyListeners();
        });
        
        if (kDebugMode) {
          developer.log('Firebase initialized successfully for user: ${_firebaseService.currentUserId}', name: 'CanvasProvider');
        }
      } catch (e) {
        if (kDebugMode) {
          developer.log('Error initializing Firebase streams: $e', name: 'CanvasProvider', error: e);
        }
      }
    } else {
      if (kDebugMode) {
        developer.log('Cannot initialize Firebase: User not signed in', name: 'CanvasProvider');
      }
    }
    
    _isInitialized = true;
  }
  
  @override
  void dispose() {
    _nodesSubscription?.cancel();
    _connectionsSubscription?.cancel();
    super.dispose();
  }

  // Add a new node at the given position with immediate editing and zoom
  void addNode(Offset position, {String text = '', Size? viewSize}) async {
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
    
    // If Firebase is available, add to Firebase, otherwise add locally
    if (_firebaseService.isSignedIn) {
      try {
        await _firebaseService.addNode(node);
        // Node will be added to local list via stream listener
      } catch (e) {
        if (kDebugMode) {
          developer.log('Error adding node to Firebase: $e', name: 'CanvasProvider', error: e);
        }
        // Fall back to local storage
        _addNodeLocally(node);
      }
    } else {
      // Work offline - add locally
      _addNodeLocally(node);
    }
    
    _newlyCreatedNodeId = node.id; // Mark as newly created for immediate editing

    // Zoom to the new node for better editing experience
    if (viewSize != null) {
      zoomToNodeWithScreenSize(node.id, viewSize);
    }

    // Auto-exit add node mode after creating a node
    exitAddNodeMode();
  }
  
  // Helper method to add node locally
  void _addNodeLocally(TodoNode node) {
    _nodes.add(node);
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
  void updateNodeText(String nodeId, String newText) async {
    final index = _nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      final updatedNode = _nodes[index].copyWith(text: newText);
      try {
        await _firebaseService.updateNode(updatedNode);
      } catch (e) {
        if (kDebugMode) {
          developer.log('Error updating node text: $e', name: 'CanvasProvider', error: e);
        }
      }
    }
  }

  // Update node position
  void updateNodePosition(String nodeId, Offset newPosition) async {
    final index = _nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      final updatedNode = _nodes[index].copyWith(position: newPosition);
      try {
        await _firebaseService.updateNode(updatedNode);
      } catch (e) {
        if (kDebugMode) {
          developer.log('Error updating node position: $e', name: 'CanvasProvider', error: e);
        }
      }
    }
  }

  // Toggle node completion
  void toggleNodeCompletion(String nodeId) async {
    final index = _nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      final wasCompleted = _nodes[index].isCompleted;
      final updatedNode = _nodes[index].copyWith(
        isCompleted: !_nodes[index].isCompleted,
      );
      
      try {
        await _firebaseService.updateNode(updatedNode);
        
        // If node was just completed, trigger charging animations
        if (!wasCompleted && updatedNode.isCompleted) {
          _startChargingAnimations(nodeId);
        }
      } catch (e) {
        if (kDebugMode) {
          developer.log('Error updating node completion: $e', name: 'CanvasProvider', error: e);
        }
      }
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
  void removeNode(String nodeId) async {
    try {
      await _firebaseService.deleteNode(nodeId);
      await _firebaseService.deleteConnectionsForNode(nodeId);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error removing node: $e', name: 'CanvasProvider', error: e);
      }
    }
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

  // Create a connection between two nodes
  void createConnection(String fromNodeId, String toNodeId) async {
    // Check if connection already exists
    final exists = _connections.any(
          (conn) =>
      (conn.fromNodeId == fromNodeId && conn.toNodeId == toNodeId) ||
          (conn.fromNodeId == toNodeId && conn.toNodeId == fromNodeId),
    );

    if (!exists) {
      final newConnection = Connection(
        id: _uuid.v4(),
        fromNodeId: fromNodeId,
        toNodeId: toNodeId,
      );
      
      try {
        await _firebaseService.addConnection(newConnection);
      } catch (e) {
        if (kDebugMode) {
          developer.log('Error creating connection: $e', name: 'CanvasProvider', error: e);
        }
      }
    }
  }

  // Update connection green state based on node completion
  void _updateConnectionStates() async {
    for (int i = 0; i < _connections.length; i++) {
      final conn = _connections[i];
      try {
        final fromNode = _nodes.firstWhere((n) => n.id == conn.fromNodeId);
        final toNode = _nodes.firstWhere((n) => n.id == conn.toNodeId);

        final shouldBeGreen = fromNode.isCompleted && toNode.isCompleted;
        if (conn.isGreen != shouldBeGreen) {
          final updatedConnection = conn.copyWith(isGreen: shouldBeGreen);
          await _firebaseService.updateConnection(updatedConnection);
        }
      } catch (e) {
        // Node might not exist anymore, skip this connection
        continue;
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
  void clearCanvas() async {
    try {
      await _firebaseService.clearAllData();
      _panOffset = Offset.zero;
      _scale = 1.0;
      _isConnectMode = false;
      _isAddNodeMode = false;
      _isEraserMode = false;
      _selectedNodeForConnection = null;
      _draggedNode = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error clearing canvas: $e', name: 'CanvasProvider', error: e);
      }
    }
  }

  // Clear the newly created node flag when editing is complete
  void clearNewlyCreatedFlag() {
    _newlyCreatedNodeId = null;
    notifyListeners();
  }
}

