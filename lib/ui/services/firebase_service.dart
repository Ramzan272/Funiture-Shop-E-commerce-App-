import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;

  static FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }
  static Future<bool> testConnection() async {
    try {
      await firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'connected'
      });
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }
  static Future<void> initializeFirestore() async {
    try {
      await firestore.enablePersistence();
    } catch (e) {
      print('Firestore persistence error: $e');
    }
  }
}
