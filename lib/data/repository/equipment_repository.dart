import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipment_model.dart';

class EquipmentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<EquipmentModel>> getAllEquipment() async {
    final snapshot =
        await _db.collection('equipment').orderBy('createdAt').get();
    return snapshot.docs
        .map((doc) => EquipmentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> createEquipment(EquipmentModel equipment) async {
    await _db
        .collection('equipment')
        .doc(equipment.id)
        .set(equipment.toMap());
  }

  Future<void> updateEquipment(EquipmentModel equipment) async {
    await _db
        .collection('equipment')
        .doc(equipment.id)
        .update(equipment.toMap());
  }

  Future<void> deleteEquipment(String id) async {
    await _db.collection('equipment').doc(id).delete();
  }
}
