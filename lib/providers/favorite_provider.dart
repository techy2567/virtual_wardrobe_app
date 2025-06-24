import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteProvider {
  static final FavoriteProvider _instance = FavoriteProvider._internal();
  factory FavoriteProvider() => _instance;
  FavoriteProvider._internal();

  Stream<Set<String>> get favoriteIdsStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(<String>{});
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favourite')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }
} 