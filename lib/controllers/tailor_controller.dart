import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/tailor_model.dart';

class TailorController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<TailorModel> tailors = <TailorModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTailors();
  }

  Future<void> fetchTailors() async {
    isLoading.value = true;
    try {
      final snapshot = await _firestore.collection('tailors').orderBy('createdAt', descending: true).get();
      tailors.value = snapshot.docs.map((doc) => TailorModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTailor(String name, String phone, String address, String email, List<String> specialties, String organizationId, {String? contact}) async {
    isLoading.value = true;
    try {
      await _firestore.collection('tailors').add({
        'name': name,
        'phone': phone,
        'address': address,
        'email': email,
        'specialties': specialties,
        'organizationId': organizationId,
        'contact': contact,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': null,
      });
      await fetchTailors();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTailor(String id, String name, String phone, String address, String email, List<String> specialties, String organizationId, {String? contact}) async {
    isLoading.value = true;
    try {
      await _firestore.collection('tailors').doc(id).update({
        'name': name,
        'phone': phone,
        'address': address,
        'email': email,
        'specialties': specialties,
        'organizationId': organizationId,
        'contact': contact,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      await fetchTailors();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTailor(String id) async {
    isLoading.value = true;
    try {
      await _firestore.collection('tailors').doc(id).delete();
      await fetchTailors();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }
} 