import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_node.dart';
import '../models/connection.dart';
import '../services/data_service.dart';
import '../services/hive_storage_service.dart';

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
  String? _nodeShowingInfo; // Track which node is showing info panel
  String? _nodeWithActiveButtons; // Track which node has active action buttons

  // Theme state
  bool _isDarkMode = true; // Default to dark mode

  // Auto-save state
  Timer? _autoSaveTimer;
  bool _isDirty = false; // Track if data needs saving
  static const Duration _autoSaveInterval = Duration(seconds: 3);

  // Constructor - initialize and load data
  CanvasProvider() {
    _initializeAndLoadData();
    _startAutoSaveTimer();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

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
  String? get nodeShowingInfo => _nodeShowingInfo;
  bool get isInfoPanelOpen => _nodeShowingInfo != null;
  String? get nodeWithActiveButtons => _nodeWithActiveButtons;
  bool get isDarkMode => _isDarkMode;


  // Add a new node at the given position with immediate editing and zoom
  void addNode(Offset position, {String text = '', Size? viewSize}) {
    // Calculate base node size as 20% of the smaller screen dimension
    double baseSize = 140.0; // fallback size
    if (viewSize != null) {
      baseSize = (viewSize.width < viewSize.height ? viewSize.width : viewSize.height) * 0.20;
    }

    // Calculate node size inversely proportional to scale
    // When zoomed in (scale > 1), nodes are smaller in canvas coordinates
    // When zoomed out (scale < 1), nodes are larger in canvas coordinates
    // This keeps the visual size consistent on screen
    final canvasRelativeSize = baseSize / _scale;

    // Theme-aware default color
    final defaultColor = _isDarkMode
        ? const Color(0xFF6366F1) // Dark mode: Indigo
        : const Color(0xFFA5B4FC); // Light mode: Light Indigo

    final node = TodoNode(
      id: _uuid.v4(),
      text: text.isEmpty ? '' : text, // Start with empty text for immediate editing
      position: position,
      size: canvasRelativeSize,
      color: defaultColor,
    );
    _nodes.add(node);
    _newlyCreatedNodeId = node.id; // Mark as newly created for immediate editing

    // Don't zoom or pan - just create the node at the clicked position
    // This prevents any zoom changes when creating nodes

    // Auto-exit add node mode after creating a node
    exitAddNodeMode();

    _markDirty(); // Mark data as changed
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

  // Center the node without changing zoom - maintains current zoom level
  void zoomToNodeForEditing(String nodeId, Size screenSize) {
    final node = _nodes.firstWhere((n) => n.id == nodeId);

    // Keep the current scale, don't change zoom at all
    // Just center the node at the current zoom level
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);

    // Set the pan offset so the node appears at screen center
    final targetPanOffset = screenCenter - (node.position * _scale);

    _panOffset = targetPanOffset;
    // _scale stays the same - no zoom change!
    notifyListeners();
  }

  // Update node text
  void updateNodeText(String nodeId, String newText) {
    final index = _nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      _nodes[index] = _nodes[index].copyWith(text: newText);
      _markDirty();
      notifyListeners();
    }
  }

  // Update node position
  void updateNodePosition(String nodeId, Offset newPosition) {
    final index = _nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      _nodes[index] = _nodes[index].copyWith(position: newPosition);
      _markDirty();
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
      _markDirty();
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
    _markDirty();
    notifyListeners();
  }

  // Canvas pan and zoom
  void updatePanOffset(Offset delta) {
    _panOffset += delta;
    _markDirty();
    notifyListeners();
  }

  void updateScale(double newScale) {
    _scale = newScale.clamp(0.3, 10.0);
    _markDirty();
    notifyListeners();
  }

  void zoom(double scaleDelta, Offset focalPoint) {
    final oldScale = _scale;
    final newScale = (_scale * scaleDelta).clamp(0.3, 10.0);

    if (newScale != oldScale) {
      // Adjust pan offset to keep focal point stationary during zoom
      final focalPointCanvas = screenToCanvas(focalPoint);
      _scale = newScale;
      final newFocalPointScreen = canvasToScreen(focalPointCanvas);
      _panOffset += focalPoint - newFocalPointScreen;
      _markDirty();
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
      _markDirty();
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

  // Theme management
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;

    // Convert all existing node colors to match the new theme
    _convertNodeColorsForTheme();

    notifyListeners();
  }

  // Map colors between dark and light themes
  void _convertNodeColorsForTheme() {
    // Color mappings: Dark mode -> Light mode
    final Map<int, int> darkToLight = {
      0xFF6366F1: 0xFFA5B4FC, // Indigo -> Light Indigo
      0xFFEF4444: 0xFFFCA5A5, // Red -> Light Red
      0xFFF59E0B: 0xFFFDE68A, // Yellow -> Light Yellow
      0xFF3B82F6: 0xFF93C5FD, // Blue -> Light Blue
      0xFF8B5CF6: 0xFFC4B5FD, // Purple -> Light Purple
      0xFFEC4899: 0xFFF9A8D4, // Pink -> Light Pink
      0xFFF97316: 0xFFFDBA74, // Orange -> Light Orange
      0xFF06B6D4: 0xFFA5F3FC, // Cyan -> Light Cyan
    };

    // Create reverse mapping: Light mode -> Dark mode
    final Map<int, int> lightToDark = {};
    darkToLight.forEach((dark, light) {
      lightToDark[light] = dark;
    });

    // Convert colors for all nodes
    for (var node in _nodes) {
      final currentColorValue = node.color.toARGB32();

      if (_isDarkMode) {
        // Switching to dark mode: convert light colors to dark
        if (lightToDark.containsKey(currentColorValue)) {
          node.color = Color(lightToDark[currentColorValue]!);
        }
      } else {
        // Switching to light mode: convert dark colors to light
        if (darkToLight.containsKey(currentColorValue)) {
          node.color = Color(darkToLight[currentColorValue]!);
        }
      }
    }
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
    } else {
      // Same node clicked twice - turn off connector mode
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
      _markDirty();
      notifyListeners();
    }
  }

  // Remove a specific connection by ID
  void removeConnection(String connectionId) {
    _connections.removeWhere((conn) => conn.id == connectionId);
    _markDirty();
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
        _markDirty();
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
    _nodeWithActiveButtons = null;
    _markDirty();
    notifyListeners();
  }

  // Clear the newly created node flag when editing is complete
  void clearNewlyCreatedFlag() {
    _newlyCreatedNodeId = null;
    notifyListeners();
  }

  // Info panel management
  void showNodeInfo(String nodeId) {
    _nodeShowingInfo = nodeId;
    notifyListeners();
  }

  void hideNodeInfo() {
    _nodeShowingInfo = null;
    notifyListeners();
  }

  // Update node description
  void updateNodeDescription(String nodeId, String newDescription) {
    final index = _nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      _nodes[index] = _nodes[index].copyWith(description: newDescription);
      _markDirty();
      notifyListeners();
    }
  }

  // Update node color
  void updateNodeColor(String nodeId, Color newColor) {
    final index = _nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      _nodes[index] = _nodes[index].copyWith(color: newColor);
      _markDirty();
      notifyListeners();
    }
  }

  // Update node icon
  void updateNodeIcon(String nodeId, String newIcon) {
    final index = _nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      _nodes[index] = _nodes[index].copyWith(icon: newIcon);
      _markDirty();
      notifyListeners();
    }
  }

  // Active buttons management
  void showNodeActionButtons(String nodeId) {
    _nodeWithActiveButtons = nodeId;
    notifyListeners();
  }

  void hideNodeActionButtons() {
    _nodeWithActiveButtons = null;
    notifyListeners();
  }

  // Toggle node action buttons
  void toggleNodeActionButtons(String nodeId) {
    if (_nodeWithActiveButtons == nodeId) {
      _nodeWithActiveButtons = null;
    } else {
      _nodeWithActiveButtons = nodeId;
    }
    notifyListeners();
  }

  // Export canvas data to file
  Future<String?> exportData() async {
    final canvasState = {
      'panOffset': {'dx': _panOffset.dx, 'dy': _panOffset.dy},
      'scale': _scale,
    };

    return await DataService.exportData(
      nodes: _nodes,
      connections: _connections,
      canvasState: canvasState,
    );
  }

  // Import canvas data from file
  Future<ImportResult> importData() async {
    return await DataService.importData();
  }

  // Load imported data into the canvas
  void loadImportedData(ImportResult result) {
    if (!result.success || result.nodes == null || result.connections == null) {
      return;
    }

    // Validate connections reference existing nodes
    if (!DataService.validateConnections(result.nodes!, result.connections!)) {
      throw Exception('Invalid data: connections reference non-existent nodes');
    }

    // Clear current data
    _nodes.clear();
    _connections.clear();

    // Load new data
    _nodes.addAll(result.nodes!);
    _connections.addAll(result.connections!);

    // Load canvas state if available
    if (result.canvasState != null) {
      final panData = result.canvasState!['panOffset'] as Map<String, dynamic>?;
      if (panData != null) {
        _panOffset = Offset(
          (panData['dx'] as num?)?.toDouble() ?? 0.0,
          (panData['dy'] as num?)?.toDouble() ?? 0.0,
        );
      }

      final scaleData = result.canvasState!['scale'] as num?;
      if (scaleData != null) {
        _scale = scaleData.toDouble().clamp(0.3, 10.0);
      }
    }

    // Reset UI state
    _isConnectMode = false;
    _isAddNodeMode = false;
    _isEraserMode = false;
    _selectedNodeForConnection = null;
    _draggedNode = null;
    _newlyCreatedNodeId = null;
    _nodeShowingInfo = null;
    _nodeWithActiveButtons = null;

    // Update connection states based on current node completion
    _updateConnectionStates();

    notifyListeners();
  }

  // Initialize and load data from Hive on startup
  Future<void> _initializeAndLoadData() async {
    try {
      // Load nodes from Hive
      final savedNodes = HiveStorageService.loadNodes();
      if (savedNodes.isNotEmpty) {
        _nodes.clear();
        _nodes.addAll(savedNodes);
      }

      // Load connections from Hive
      final savedConnections = HiveStorageService.loadConnections();
      if (savedConnections.isNotEmpty) {
        _connections.clear();
        _connections.addAll(savedConnections);
        _updateConnectionStates();
      }

      // Load canvas state from Hive
      final canvasState = HiveStorageService.loadCanvasState();
      _scale = canvasState['scale'] ?? 1.0;
      _panOffset = Offset(
        canvasState['panX'] ?? 0.0,
        canvasState['panY'] ?? 0.0,
      );

      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data from Hive: $e');
      // Continue with empty state if loading fails
    }
  }

  // Start the auto-save timer
  void _startAutoSaveTimer() {
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) {
      if (_isDirty) {
        _saveToHive();
      }
    });
  }

  // Mark data as dirty (needs saving)
  void _markDirty() {
    _isDirty = true;
  }

  // Save data to Hive
  Future<void> _saveToHive() async {
    try {
      await HiveStorageService.saveAllData(
        nodes: _nodes,
        connections: _connections,
        scale: _scale,
        panX: _panOffset.dx,
        panY: _panOffset.dy,
      );
      _isDirty = false;
      debugPrint('Auto-saved to Hive: ${_nodes.length} nodes, ${_connections.length} connections');
    } catch (e) {
      debugPrint('Error saving to Hive: $e');
    }
  }

  // Public method to force save (called on app pause/background)
  Future<void> saveToStorage() async {
    await _saveToHive();
  }
}

