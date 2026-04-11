import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy UID của user đang đăng nhập
  String? get userId => _auth.currentUser?.uid;

  String _requireUserId() {
    final uid = userId;
    if (uid == null) {
      throw Exception('Chua dang nhap! Vui long nhan nut Login truoc.');
    }
    return uid;
  }

  DocumentReference<Map<String, dynamic>> get _userDoc {
    final uid = _requireUserId();
    return _db.collection('users').doc(uid);
  }

  CollectionReference<Map<String, dynamic>> _col(String name) {
    return _userDoc.collection(name);
  }

  Map<String, dynamic> _clean(Map<String, dynamic> data) {
    data.removeWhere((_, value) => value == null);
    return data;
  }

  Future<String> _upsertSubDoc({
    required String collection,
    required String prefix,
    int? localId,
    required Map<String, dynamic> data,
  }) async {
    await ensureUserRoot();

    final payload = _clean({
      ...data,
      'localId': localId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (localId != null) {
      final docId = '${prefix}_$localId';
      await _col(collection).doc(docId).set(payload, SetOptions(merge: true));
      return docId;
    }

    final docRef = await _col(collection).add(payload);
    return docRef.id;
  }

  Future<void> ensureUserRoot({
    String? fullName,
    String? role,
    Map<String, dynamic>? bodyMetrics, // Chứa height, weight, bmi
  }) async {
    await _userDoc.set(
      _clean({
        'fullName': fullName,
        'role': role,
        'bodyMetrics': bodyMetrics,
        'updatedAt': FieldValue.serverTimestamp(),
      }),
      SetOptions(merge: true),
    );
  }

  // 2. Chức năng Thuê PT (Thay vì Saving Goals)
  Future<String> upsertPTContract({
    required String ptId,
    required String slotId,
    required String startDate,
    required String endDate,
  }) async {
    return _upsertSubDoc(
      collection: 'pt_contracts',
      prefix: 'con',
      data: {
        'ptId': ptId,
        'slotId': slotId,
        'startDate': startDate,
        'endDate': endDate,
        'status': 'Active',
      },
    );
  }

  // 3. Chức năng Mua hàng/Thanh toán (Thay vì Transactions)
  Future<String> createOrder({
    required double totalAmount,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    return _upsertSubDoc(
      collection: 'orders',
      prefix: 'ord',
      data: {
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'items': items, // Danh sách món hàng từ giỏ hàng
        'status': 'Paid',
      },
    );
  }

  // 4. Chức năng Đặt chỗ Tủ đồ (Locker)
  Future<String> logLockerUsage({
    required String lockerId,
    required String lockerNumber,
  }) async {
    return _upsertSubDoc(
      collection: 'locker_logs',
      prefix: 'lock',
      data: {
        'lockerId': lockerId,
        'lockerNumber': lockerNumber,
        'startTime': FieldValue.serverTimestamp(),
        'status': 'Using',
      },
    );
  }
}