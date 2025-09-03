# GraphTodo

Interactive graph-based todo app built with Flutter. Create nodes, connect them, watch them turn gold when completed. It's giving productivity vibes but make it visual.

## What it does

- Click anywhere on canvas → new todo node spawns
- Double-click nodes → edit that text
- Drag nodes around → reorganize your chaos
- Toggle connection mode → link related todos
- Complete connected todos → golden connections (chef's kiss)

## Running this thing

```bash
flutter pub get
flutter run
```

For web: `flutter run -d chrome`

## Stack

- Flutter + Provider for state management
- Custom painters for the connection magic
- No external APIs, just pure local vibes
