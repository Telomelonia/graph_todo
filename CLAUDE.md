# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GraphTodo is a Flutter application that implements an interactive graph-based todo management system. Users can create todo nodes on a canvas, connect them to show relationships, and visualize task completion through golden connections when both linked tasks are completed.

## Common Commands

### Development
- `flutter run` - Run the app in development mode
- `flutter run -d chrome` - Run the app in web browser
- `flutter run -d macos` - Run the app on macOS
- `flutter build apk` - Build Android APK
- `flutter build web` - Build for web deployment

### Dependencies and Maintenance
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies
- `flutter clean` - Clean build artifacts

### Testing and Quality
- `flutter test` - Run unit and widget tests
- `flutter test test/specific_test.dart` - Run a specific test file
- `flutter analyze` - Run static analysis (lint checking)

## Architecture

### Core Components

**State Management**: Uses Provider pattern with `CanvasProvider` as the main state manager for:
- Node creation, editing, and deletion
- Connection management between nodes
- Canvas pan/zoom operations with multi-touch support
- Tool mode management (node creation, connection, eraser modes)
- Canvas state including grid visibility and zoom level

**Data Models**:
- `TodoNode` (`lib/models/todo_node.dart`): Represents individual todo items with position, completion state, and visual properties
- `Connection` (`lib/models/connection.dart`): Represents relationships between nodes with golden state for completed connections

**UI Architecture**:
- `main.dart`: Entry point with Material app setup and home page
- `CanvasWidget`: Main interactive canvas with gesture handling for node creation and panning
- `TodoNodeWidget` (`lib/widgets/todo_node_widget.dart`): Individual node rendering with editing, animation, and drag functionality
- `ConnectionPainter` (`lib/widgets/connection_painter.dart`): Custom painter for drawing connections between nodes with visual states

### Key Features

**Interactive Canvas**: 
- Toggle button for node creation mode
- Click empty space to create nodes (when in node creation mode)
- Double-click nodes to edit text with zoom-in functionality
- Drag nodes to reposition
- Two-finger trackpad panning and scroll wheel panning
- Multi-touch zoom and pinch-to-zoom
- Scale-aware interactions with proper coordinate transformations

**Connection System**:
- Toggle connection mode via floating action button
- Select two nodes to create connections
- Golden connections appear when both connected nodes are completed
- Charging effects on connectors with animations

**Tools and Modes**:
- Eraser mode for deleting nodes and connections
- Connection mode with visual feedback
- Clear canvas functionality with confirmation dialog
- Mode indicators for current tool selection

**Visual Feedback**:
- Glow animations for completed nodes
- Color-coded connection states
- Optional grid background for positioning reference
- Zoom level indicator showing current scale percentage
- Enhanced visual effects and animations

### Dependencies

Key Flutter packages used:
- `provider ^6.1.1` - State management
- `shared_preferences ^2.2.2` - Local storage (prepared but not yet implemented)
- `uuid ^4.1.0` - Unique ID generation for nodes and connections
- `flutter_lints ^3.0.0` - Dart linting rules for code quality

## Testing Structure

The project includes comprehensive tests organized by component type:
- `test/models/` - Unit tests for data models (TodoNode, Connection)
- `test/providers/` - Tests for state management (CanvasProvider)
- `test/widgets/` - Widget tests for UI components
- Uses standard Flutter testing framework with `flutter_test` package