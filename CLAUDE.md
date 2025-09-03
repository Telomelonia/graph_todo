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
- `flutter analyze` - Run static analysis (lint checking)

## Architecture

### Core Components

**State Management**: Uses Provider pattern with `CanvasProvider` as the main state manager for:
- Node creation, editing, and deletion
- Connection management between nodes
- Canvas pan/zoom operations
- Connection mode toggling

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
- Click empty space to create nodes
- Double-click nodes to edit text
- Drag nodes to reposition
- Pan canvas with multi-touch gestures

**Connection System**:
- Toggle connection mode via floating action button
- Select two nodes to create connections
- Golden connections appear when both connected nodes are completed

**Visual Feedback**:
- Glow animations for completed nodes
- Color-coded connection states
- Grid background for positioning reference

### Dependencies

Key Flutter packages used:
- `provider ^6.1.1` - State management
- `shared_preferences ^2.2.2` - Local storage (prepared but not yet implemented)
- `uuid ^4.1.0` - Unique ID generation for nodes and connections