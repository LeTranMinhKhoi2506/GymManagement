import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/membership_plan_model.dart';
import 'dart:developer' as dev;

class MembershipRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'membership_plans';

  // Lấy danh sách gói tập
  Stream<List<MembershipPlan>> getMembershipPlans() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MembershipPlan.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Thêm gói tập mới
  Future<void> addPlan(MembershipPlan plan) async {
    try {
      await _db.collection(_collection).add(plan.toMap());
    } catch (e) {
      dev.log("MembershipRepository - addPlan error: $e");
      rethrow;
    }
  }

  // Cập nhật gói tập
  Future<void> updatePlan(MembershipPlan plan) async {
    try {
      await _db.collection(_collection).doc(plan.id).update(plan.toMap());
    } catch (e) {
      dev.log("MembershipRepository - updatePlan error: $e");
      rethrow;
    }
  }

  // Xóa (hoặc ẩn) gói tập
  Future<void> deletePlan(String id) async {
    try {
      // Thay vì xóa vĩnh viễn, ta có thể cập nhật isActive = false
      await _db.collection(_collection).doc(id).delete();
    } catch (e) {
      dev.log("MembershipRepository - deletePlan error: $e");
      rethrow;
    }
  }
}
