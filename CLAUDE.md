# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GraphTodo is a Flutter application that implements an interactive graph-based todo management system. Users can create todo nodes on a canvas, connect them to show relationships, and visualize task completion through golden connections when both linked tasks are completed.

**Current Version**: v0.5.0+ (evolved from v0.4.1)
**Target Platforms**: iOS, Android, Web, macOS, Windows
**Flutter SDK**: ^3.8.0

## Common Commands

### Development
- `flutter run` - Run the app in development mode (hot reload enabled)
- `flutter run -d chrome` - Run the app in web browser for testing
- `flutter run -d macos` - Run the app on macOS desktop
- `flutter run -d ios` - Run on iOS simulator
- `flutter run -d android` - Run on Android emulator/device

### Building
- `flutter build apk` - Build Android APK for release
- `flutter build appbundle` - Build Android App Bundle for Play Store
- `flutter build ios` - Build iOS app (requires Xcode on macOS)
- `flutter build web` - Build for web deployment
- `flutter build macos` - Build macOS desktop app
- `flutter build windows` - Build Windows desktop app

### Dependencies and Maintenance
- `flutter pub get` - Install dependencies (run after cloning or pubspec changes)
- `flutter pub upgrade` - Upgrade dependencies to latest compatible versions
- `flutter pub outdated` - Check for newer package versions
- `flutter clean` - Clean build artifacts (fixes most build issues)
- `flutter doctor` - Check Flutter installation and dependencies
- `flutter pub run build_runner build --delete-conflicting-outputs` - Regenerate Hive type adapters after model changes

### Testing and Quality
- `flutter test` - Run all unit and widget tests
- `flutter test test/specific_test.dart` - Run a specific test file
- `flutter test --coverage` - Run tests with coverage report
- `flutter analyze` - Run static analysis (dart linting)
- `dart format .` - Format all Dart code in the project

## Architecture

### Core Components

**State Management**: Uses Provider pattern with `CanvasProvider` as the main state manager for:
- Node creation, editing, and deletion
- Connection management between nodes
- Canvas pan/zoom operations with multi-touch support
- Tool mode management (node creation, connection, eraser modes)
- Canvas state including grid visibility and zoom level

**Data Models** (`lib/models/`):
- `TodoNode` (`todo_node.dart`): Represents individual todo items with position, completion state, title, description, icon, color, due date, and visual properties
- `Connection` (`connection.dart`): Represents relationships between nodes with golden state for completed connections and visual feedback
- Custom Hive adapters: `ColorAdapter`, `OffsetAdapter` for serializing Flutter types

**UI Architecture** (`lib/widgets/`):
- `main.dart`: Entry point with Material app setup and theme configuration
- `CanvasWidget`: Main interactive canvas with gesture handling, multi-touch support, and coordinate transformations
- `TodoNodeWidget` (`todo_node_widget.dart`): Individual node rendering with icon display, action buttons, animations, and drag functionality
- `IconSelectorWidget` (`icon_selector_widget.dart`): Searchable icon picker with 70+ curated skill tree icons across categories
- `ConnectionPainter` (`connection_painter.dart`): Custom painter for drawing connections with multiple visual states
- `InfoPanelWidget` (`info_panel_widget.dart`): Side panel for node title/description editing, icon selection, due date picker, and color customization
- `OrderedTodoListWidget` (`ordered_todo_list_widget.dart`): Dialog showing tasks sorted by due date with overdue/today indicators
- `InteractiveConnectionWidget` (`interactive_connection_widget.dart`): Enhanced connection system with visual feedback
- `ConnectionEndpointWidget` (`connection_endpoint_widget.dart`): Connection points with hover states and animations

**State Management** (`lib/providers/`):
- `CanvasProvider` (`canvas_provider.dart`): Centralized state management using Provider pattern

**Data Persistence** (`lib/services/`):
- `HiveStorageService` (`hive_storage_service.dart`): Hive-based local storage for automatic data persistence
- Stores nodes and connections in local Hive boxes with auto-save functionality
- Supports data import/export as JSON files for backup and cross-device sync

### Key Features

**Interactive Canvas**: 
- Click empty space to create nodes with intelligent positioning
- Double-click nodes to edit text with automatic zoom focus (14% screen ratio)
- Drag nodes to reposition with smooth animations
- Two-finger trackpad panning and scroll wheel panning
- Multi-touch zoom and pinch-to-zoom with center focus
- Scale-aware interactions with proper coordinate transformations
- Grid background toggle for precise positioning

**Node Management**:
- Individual node action buttons (edit, connect, delete)
- Icon-based visual representation with 70+ curated skill tree icons
- Searchable icon picker with categories (combat, magic, tech, creative, etc.)
- Custom color picker for node personalization
- Due date assignment with date picker interface
- Completion state with center hover animations
- Title and description editing in dedicated info panel
- Drag and drop repositioning with visual feedback

**Enhanced Connection System**:
- Intuitive connection creation between nodes
- Interactive connection endpoints with hover states
- Golden connections when both connected nodes are completed
- Connection deletion via action buttons or eraser mode
- Visual charging effects and animations
- Multiple connection states with color coding

**Advanced UI Features**:
- Info panel for node details and customization
- Due date management with ordered task list view (top-right info button)
- Overdue and today task indicators with color coding
- Tool mode management with visual indicators
- Clear canvas functionality with confirmation dialog
- Responsive design across all target platforms
- Enhanced visual effects and smooth animations
- Improved sensitivity and interaction responsiveness
- Dark/light theme support with automatic color conversion

### Dependencies

**Production Dependencies**:
- `provider ^6.1.1` - State management using Provider pattern
- `hive ^2.2.3` - Fast, lightweight NoSQL database for local storage
- `hive_flutter ^1.1.0` - Flutter integration for Hive database
- `uuid ^4.1.0` - Unique ID generation for nodes and connections
- `phosphor_flutter ^2.1.0` - Icon library for 70+ curated skill tree icons
- `intl ^0.19.0` - Date formatting and internationalization
- `file_picker ^8.1.2` - File selection for import/export functionality
- `path_provider ^2.1.1` - Access to platform-specific storage locations
- `shared_preferences ^2.2.2` - Simple key-value storage (legacy support)

**Development Dependencies**:
- `flutter_lints ^3.0.0` - Dart linting rules for code quality
- `flutter_test` - Testing framework for unit and widget tests
- `hive_generator ^2.0.1` - Code generation for Hive type adapters
- `build_runner ^2.4.6` - Build system for code generation

**Assets**:
- `assets/icons/` - App icons and UI assets including app_icon.svg

## Testing Structure

The project includes comprehensive test coverage organized by component type:
- `test/models/` - Unit tests for data models (TodoNode, Connection)
- `test/providers/` - Tests for state management (CanvasProvider)
- `test/widgets/` - Widget tests for UI components
- Uses standard Flutter testing framework with `flutter_test` package
- Run `flutter test --coverage` to generate coverage reports

## Development Guidelines

### Code Style
- Follow Dart/Flutter conventions and use `dart format .`
- Use meaningful variable and function names
- Keep widgets focused and composable
- Implement proper error handling
- Add comprehensive documentation for complex functions

### State Management
- Use Provider pattern consistently
- Keep business logic in providers, not widgets
- Use `Consumer` and `Provider.of` appropriately
- Implement proper disposal of resources

### Performance Considerations
- Use `const` constructors where possible
- Implement proper widget rebuilding optimization
- Handle canvas rendering efficiently for large node counts
- Optimize gesture handling for smooth interactions

### Working with Hive Database
- **Model Changes**: When adding/modifying fields in `TodoNode` or `Connection`, always regenerate adapters with `flutter pub run build_runner build --delete-conflicting-outputs`
- **Type Adapters**: Custom adapters exist for `Color` and `Offset` types in `lib/models/`
- **HiveField Annotations**: Each field must have a unique `@HiveField(n)` annotation where `n` is sequential
- **Data Storage**: Data is automatically saved to local Hive boxes on changes and app lifecycle events
- **Import/Export**: JSON-based import/export preserves Hive data structure for cross-device compatibility

### Testing Best Practices
- Write tests for all new features
- Test both happy path and edge cases
- Use widget tests for UI components
- Unit test business logic in providers and models

## Recent Improvements (v0.5.0+)

### v0.6.0 - Due Date Feature (November 2025)
- **Due Date Management**: Added optional due date field to TodoNode model with Hive persistence
- **Date Picker UI**: Integrated date picker in info panel next to icon selector with clear functionality
- **Ordered Task List**: New dialog (accessible via top-right info button) showing tasks sorted by due date
- **Visual Indicators**: Overdue tasks highlighted in red, today's tasks in orange, with status badges
- **Smart Filtering**: Empty state when no tasks have due dates, automatic date normalization for comparisons
- **Technical**: Extended TodoNode with `@HiveField(8)` for dueDate, added `OrderedTodoListWidget`, integrated `intl` package

### v0.5.0 - Icon System & Hive Storage
- **Major UI Transformation**: Replaced text-based nodes with icon-based skill tree interface
- **Icon System**: 70+ curated Phosphor icons across categories (combat, magic, tech, creative, business, etc.)
- **Hive Integration**: Replaced SharedPreferences with Hive for efficient local storage and auto-save
- **Enhanced Info Panel**: Dedicated title/description editing with searchable icon picker
- **Improved UX**: Double-tap nodes now opens info panel instead of inline editing
- **Visual Hierarchy**: Better task categorization and visual scanning with icons
- **Backward Compatibility**: Existing saves work seamlessly with new icon system
- **Technical**: Extended TodoNode model, new IconSelectorWidget, HiveStorageService, custom type adapters