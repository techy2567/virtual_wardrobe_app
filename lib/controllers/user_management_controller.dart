import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ManagedUser {
  final String id;
  final String? name;
  final String? email;
  final String? role;

  ManagedUser({required this.id, this.name, this.email, this.role});

  factory ManagedUser.fromMap(Map<String, dynamic> map, String id) {
    return ManagedUser(
      id: id,
      name: map['name'],
      email: map['email'],
      role: map['role'],
    );
  }
}

class UserManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<ManagedUser> users = <ManagedUser>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    try {
      final snapshot = await _firestore.collection('users').get();
      users.value = snapshot.docs.map((doc) => ManagedUser.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    isLoading.value = true;
    try {
      await _firestore.collection('users').doc(userId).update({'role': newRole});
      await fetchUsers();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String userId) async {
    isLoading.value = true;
    try {
      await _firestore.collection('users').doc(userId).delete();
      await fetchUsers();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }
} 