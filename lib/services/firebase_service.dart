import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../models/todo_node.dart';
import '../models/connection.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  bool get isSignedIn => _auth.currentUser != null;

  // Authentication methods
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      if (kDebugMode) {
        developer.log('Successfully signed in anonymously: ${userCredential.user?.uid}', name: 'FirebaseService');
      }
      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error signing in anonymously: $e', name: 'FirebaseService', error: e);
        developer.log('Please enable Anonymous authentication in Firebase Console', name: 'FirebaseService');
      }
      return null;
    }
  }

  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error signing in with email/password: $e', name: 'FirebaseService', error: e);
      }
      return null;
    }
  }

  Future<User?> createUserWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error creating user with email/password: $e', name: 'FirebaseService', error: e);
      }
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error signing out: $e', name: 'FirebaseService', error: e);
      }
    }
  }

  // Todo Node methods
  Future<void> addNode(TodoNode node) async {
    if (currentUserId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('nodes')
          .doc(node.id)
          .set(node.toJson());
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error adding node: $e', name: 'FirebaseService', error: e);
      }
      rethrow;
    }
  }

  Future<void> updateNode(TodoNode node) async {
    if (currentUserId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('nodes')
          .doc(node.id)
          .update({
        ...node.toJson(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error updating node: $e', name: 'FirebaseService', error: e);
      }
      rethrow;
    }
  }

  Future<void> deleteNode(String nodeId) async {
    if (currentUserId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('nodes')
          .doc(nodeId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error deleting node: $e', name: 'FirebaseService', error: e);
      }
      rethrow;
    }
  }

  Stream<List<TodoNode>> getNodesStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('nodes')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TodoNode.fromJson(doc.data()))
          .toList();
    });
  }

  Future<List<TodoNode>> getNodes() async {
    if (currentUserId == null) return [];
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('nodes')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => TodoNode.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error getting nodes: $e', name: 'FirebaseService', error: e);
      }
      return [];
    }
  }

  // Connection methods
  Future<void> addConnection(Connection connection) async {
    if (currentUserId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('connections')
          .doc(connection.id)
          .set(connection.toJson());
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error adding connection: $e', name: 'FirebaseService', error: e);
      }
      rethrow;
    }
  }

  Future<void> updateConnection(Connection connection) async {
    if (currentUserId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('connections')
          .doc(connection.id)
          .update({
        ...connection.toJson(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error updating connection: $e', name: 'FirebaseService', error: e);
      }
      rethrow;
    }
  }

  Future<void> deleteConnection(String connectionId) async {
    if (currentUserId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('connections')
          .doc(connectionId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error deleting connection: $e', name: 'FirebaseService', error: e);
      }
      rethrow;
    }
  }

  Future<void> deleteConnectionsForNode(String nodeId) async {
    if (currentUserId == null) return;
    
    try {
      final connectionsSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('connections')
          .where('fromNodeId', isEqualTo: nodeId)
          .get();

      final connectionsSnapshot2 = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('connections')
          .where('toNodeId', isEqualTo: nodeId)
          .get();

      final batch = _firestore.batch();
      
      for (final doc in connectionsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      for (final doc in connectionsSnapshot2.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error deleting connections for node: $e', name: 'FirebaseService', error: e);
      }
      rethrow;
    }
  }

  Stream<List<Connection>> getConnectionsStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('connections')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Connection.fromJson(doc.data()))
          .toList();
    });
  }

  Future<List<Connection>> getConnections() async {
    if (currentUserId == null) return [];
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('connections')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Connection.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error getting connections: $e', name: 'FirebaseService', error: e);
      }
      return [];
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    if (currentUserId == null) return;
    
    try {
      final batch = _firestore.batch();
      
      // Delete all nodes
      final nodesSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('nodes')
          .get();
      
      for (final doc in nodesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete all connections
      final connectionsSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('connections')
          .get();
      
      for (final doc in connectionsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error clearing all data: $e', name: 'FirebaseService', error: e);
      }
      rethrow;
    }
  }
}