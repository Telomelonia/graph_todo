import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'providers/canvas_provider.dart';
import 'providers/auth_provider.dart';
import 'pages/auth_page.dart';
import 'pages/canvas_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GraphTodoApp());
}

class GraphTodoApp extends StatelessWidget {
  const GraphTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CanvasProvider()),
      ],
      child: MaterialApp(
        title: 'GraphTodo',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, CanvasProvider>(
      builder: (context, authProvider, canvasProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A1A1A),
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.indigo,
              ),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          // Initialize Firebase for the canvas when user is authenticated
          if (!canvasProvider.isInitialized) {
            Future.microtask(() => canvasProvider.initializeFirebase());
          }
          return const CanvasPage();
        } else {
          return const AuthPage();
        }
      },
    );
  }
}

