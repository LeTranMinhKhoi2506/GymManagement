import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'reports';

  Stream<List<ReportModel>> getReportsStream() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateReportStatus(String id, String status, {String? adminNote}) async {
    final Map<String, dynamic> data = {'status': status};
    if (adminNote != null) data['adminNote'] = adminNote;
    await _db.collection(_collection).doc(id).update(data);
  }

  Future<void> createReport(ReportModel report) async {
    await _db.collection(_collection).doc(report.id).set(report.toMap());
  }

  Future<void> deleteReport(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
