import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/organization_model.dart';

class OrganizationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<OrganizationModel> organizations = <OrganizationModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrganizations();
  }

  Future<void> fetchOrganizations() async {
    isLoading.value = true;
    try {
      final snapshot = await _firestore.collection('organizations').orderBy('createdAt', descending: true).get();
      organizations.value = snapshot.docs.map((doc) => OrganizationModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addOrganization(String name, {String? description}) async {
    isLoading.value = true;
    try {
      final docRef = await _firestore.collection('organizations').add({
        'name': name,
        'description': description,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': null,
      });
      await fetchOrganizations();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrganization(String id, String name, {String? description}) async {
    isLoading.value = true;
    try {
      await _firestore.collection('organizations').doc(id).update({
        'name': name,
        'description': description,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      await fetchOrganizations();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteOrganization(String id) async {
    isLoading.value = true;
    try {
      await _firestore.collection('organizations').doc(id).delete();
      await fetchOrganizations();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }
} 