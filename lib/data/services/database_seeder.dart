import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/developer_seed_data.dart';

class DatabaseSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Function(String) onLog;

  DatabaseSeeder({required this.onLog});

  // Helper to parse date strings
  Timestamp _parseDate(dynamic dateStr) {
    if (dateStr == null) return Timestamp.now();
    try {
      final dt = DateTime.parse(dateStr.toString());
      return Timestamp.fromDate(dt);
    } catch (_) {
      return Timestamp.now();
    }
  }

  // Clear single collection
  Future<void> clearCollection(String collectionName) async {
    onLog("🗑️ Đang xóa collection '$collectionName'...");
    try {
      final snapshot = await _db.collection(collectionName).get();
      if (snapshot.docs.isEmpty) {
        onLog("✔️ Collection '$collectionName' đã trống.");
        return;
      }

      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
        // Delete subcollections for members
        if (collectionName == 'members') {
          final subSnapshot = await doc.reference.collection('activity_logs').get();
          for (var subDoc in subSnapshot.docs) {
            batch.delete(subDoc.reference);
          }
        }
      }
      await batch.commit();
      onLog("✔️ Đã xóa xong ${snapshot.docs.length} tài liệu trong '$collectionName'.");
    } catch (e) {
      onLog("❌ Lỗi khi xóa collection '$collectionName': $e");
    }
  }

  // Clear all collections
  Future<void> clearAll() async {
    onLog("⚡ Bắt đầu xóa toàn bộ CSDL Firestore...");
    final collections = [
      'users',
      'members',
      'membership_plans',
      'products',
      'equipment',
      'transactions',
      'payments',
      'payroll',
      'schedules',
      'feedbacks',
      'checkins'
    ];
    for (var col in collections) {
      await clearCollection(col);
    }
    onLog("🎉 Đã xóa sạch toàn bộ CSDL.");
  }

  // Seed default data for a collection
  Future<void> seedDefault(String collectionName) async {
    onLog("📥 Đang nạp dữ liệu mặc định cho '$collectionName'...");
    try {
      final batch = _db.batch();
      List<Map<String, dynamic>> sourceData = [];
      String idField = 'id';

      switch (collectionName) {
        case 'users':
          sourceData = DeveloperSeedData.users;
          idField = 'uid';
          break;
        case 'members':
          sourceData = DeveloperSeedData.members;
          idField = 'id';
          break;
        case 'membership_plans':
          sourceData = DeveloperSeedData.membershipPlans;
          idField = 'id';
          break;
        case 'products':
          sourceData = DeveloperSeedData.products;
          idField = 'id';
          break;
        case 'equipment':
          sourceData = DeveloperSeedData.equipment;
          idField = 'id';
          break;
        case 'transactions':
          sourceData = DeveloperSeedData.transactions;
          idField = 'id';
          break;
        case 'payments':
          sourceData = DeveloperSeedData.payments;
          idField = 'id';
          break;
        case 'payroll':
          sourceData = DeveloperSeedData.payroll;
          idField = 'id';
          break;
        case 'schedules':
          sourceData = DeveloperSeedData.schedules;
          idField = 'id';
          break;
        case 'feedbacks':
          sourceData = DeveloperSeedData.feedbacks;
          idField = 'id';
          break;
        default:
          onLog("⚠️ Collection '$collectionName' không được hỗ trợ.");
          return;
      }

      for (var item in sourceData) {
        final docId = item[idField]?.toString() ?? '';
        if (docId.isEmpty) continue;

        // Clone and convert date strings to Timestamps
        final Map<String, dynamic> firestoreMap = Map.from(item);
        
        // Convert date fields to Timestamps
        _convertDateFields(firestoreMap);

        final docRef = _db.collection(collectionName).doc(docId);
        batch.set(docRef, firestoreMap);
      }

      await batch.commit();
      onLog("✔️ Đã nạp thành công ${sourceData.length} dữ liệu mẫu vào '$collectionName'.");
    } catch (e) {
      onLog("❌ Lỗi khi nạp dữ liệu mẫu cho '$collectionName': $e");
    }
  }

  // Convert date fields in map
  void _convertDateFields(Map<String, dynamic> map) {
    const dateFields = [
      'createdAt',
      'updatedAt',
      'purchaseDate',
      'lastMaintenanceDate',
      'nextMaintenanceDate',
      'transactionDate',
      'dueDate',
      'paymentDate',
      'paymentMonth',
      'startTime',
      'endTime',
      'nextRenewal',
      'memberSince'
    ];
    for (var key in map.keys) {
      if (dateFields.contains(key) && map[key] is String) {
        map[key] = _parseDate(map[key]);
      }
    }
  }

  // Seed all default data
  Future<void> seedAllDefaults() async {
    onLog("⚡ Bắt đầu nạp tất cả dữ liệu mẫu mặc định...");
    final collections = [
      'users',
      'members',
      'membership_plans',
      'products',
      'equipment',
      'transactions',
      'payments',
      'payroll',
      'schedules',
      'feedbacks'
    ];
    for (var col in collections) {
      await seedDefault(col);
    }
    onLog("🎉 Đã hoàn tất nạp toàn bộ dữ liệu mẫu mặc định!");
  }

  // --- Dynamic Random Generators ---
  final _random = Random();

  final List<String> _ho = ['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Huỳnh', 'Phan', 'Vũ', 'Võ', 'Đặng', 'Bùi', 'Đỗ', 'Hồ', 'Ngô', 'Dương', 'Lý'];
  final List<String> _dem = ['Văn', 'Thị', 'Minh', 'Thanh', 'Hữu', 'Đức', 'Hoàng', 'Khánh', 'Ngọc', 'Tuấn', 'Phương', 'Thu', 'Hồng', 'Anh'];
  final List<String> _ten = ['An', 'Bình', 'Chi', 'Dũng', 'Em', 'Giang', 'Hùng', 'Hương', 'Hải', 'Khánh', 'Linh', 'Long', 'Mai', 'Minh', 'Nam', 'Oanh', 'Phúc', 'Quân', 'Sơn', 'Trang', 'Tùng', 'Vân', 'Vy', 'Yên', 'Quốc', 'Tú', 'Duy', 'Phong', 'Huy'];

  String _randomName() {
    final h = _ho[_random.nextInt(_ho.length)];
    final d = _dem[_random.nextInt(_dem.length)];
    final t = _ten[_random.nextInt(_ten.length)];
    return "$h $d $t";
  }

  String _removeDiacritics(String str) {
    var withDiacritics = 'áàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵđÁÀẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬÉÈẺẼẸÊẾỀỂỄỆÍÌỈĨỊÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÚÙỦŨỤƯỨỪỬỮỰÝỲỶỸÝĐ';
    var withoutDiacritics = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    for (int i = 0; i < withDiacritics.length; i++) {
      str = str.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return str;
  }

  String _randomEmail(String fullName) {
    final cleanName = _removeDiacritics(fullName).toLowerCase().replaceAll(' ', '.');
    final randNum = _random.nextInt(900) + 100;
    return "$cleanName$randNum@gmail.com";
  }

  String _randomPhone() {
    final prefixes = ['090', '091', '092', '093', '094', '096', '097', '098', '032', '035', '038', '077', '079', '083'];
    final prefix = prefixes[_random.nextInt(prefixes.length)];
    final suffix = _random.nextInt(9000000) + 1000000;
    return "$prefix$suffix";
  }

  // 1. Generate Random Members & Users
  Future<void> generateRandomMembers(int count) async {
    onLog("⚡ Bắt đầu sinh ngẫu nhiên $count Hội viên & Tài khoản tương ứng...");
    try {
      final batch = _db.batch();
      final plans = ['Standard 1 Month', 'Pro Elite 3 Months', 'Trial 7 Days'];
      final statuses = ['Active', 'Inactive', 'Expired', 'Payment Overdue'];

      for (int i = 0; i < count; i++) {
        final uid = "gen_user_${DateTime.now().microsecondsSinceEpoch}_$i";
        final name = _randomName();
        final email = _randomEmail(name);
        final phone = _randomPhone();
        final isFemale = name.contains('Thị') || name.contains('Vy') || name.contains('Mai') || name.contains('Linh') || name.contains('Trang') || name.contains('Oanh') || name.contains('Hương') || name.contains('Vân');
        final gender = isFemale ? 'Nữ' : 'Nam';
        
        final plan = plans[_random.nextInt(plans.length)];
        final status = statuses[_random.nextInt(statuses.length)];
        final isTraining = status == 'Active' && _random.nextBool();

        final createdDate = DateTime.now().subtract(Duration(days: _random.nextInt(180)));
        final renewalDate = createdDate.add(const Duration(days: 30));

        double ltv = 0.0;
        if (plan.contains('Standard')) ltv = 500000.0 * (_random.nextInt(5) + 1);
        if (plan.contains('Pro Elite')) ltv = 4500000.0 * (_random.nextInt(2) + 1);

        // 1. Write user doc
        final userMap = {
          'uid': uid,
          'email': email,
          'fullName': name,
          'role': 'user',
          'status': status.toLowerCase() == 'active' ? 'active' : 'inactive',
          'createdAt': Timestamp.fromDate(createdDate),
          'phoneNumber': phone,
          'address': "${_random.nextInt(500) + 1} Đường ${_random.nextInt(20) + 1}, Quận ${_random.nextInt(12) + 1}, TP.HCM",
          'gender': gender,
        };
        final userRef = _db.collection('users').doc(uid);
        batch.set(userRef, userMap);

        // 2. Write member doc
        final memberMap = {
          'fullName': name,
          'email': email,
          'phoneNumber': phone,
          'membershipType': plan,
          'status': status,
          'isCurrentlyTraining': isTraining,
          'nextRenewal': Timestamp.fromDate(renewalDate),
          'memberSince': Timestamp.fromDate(createdDate),
          'ltv': ltv,
        };
        final memberRef = _db.collection('members').doc(uid);
        batch.set(memberRef, memberMap);
      }

      await batch.commit();
      onLog("✔️ Đã sinh thành công $count hội viên & tài khoản đồng bộ.");
    } catch (e) {
      onLog("❌ Lỗi khi sinh hội viên ngẫu nhiên: $e");
    }
  }

  // 2. Generate Random Transactions
  Future<void> generateRandomTransactions(int count) async {
    onLog("⚡ Bắt đầu sinh ngẫu nhiên $count Giao dịch tài chính (Doanh thu & Chi phí)...");
    try {
      final batch = _db.batch();
      
      final revCategories = ['Membership', 'Training', 'Product', 'Service'];
      final expCategories = ['Equipment', 'Utilities', 'Maintenance', 'Marketing', 'Other'];
      final paymentMethods = ['Cash', 'Transfer', 'Card'];

      final revDescriptions = {
        'Membership': ['Đóng phí hội viên tháng mới', 'Gia hạn gói tập Standard', 'Mua gói tập Pro Elite', 'Phí tập thử qua cổng thanh toán'],
        'Training': ['Thanh toán gói PT 12 buổi', 'Mua gói kèm huấn luyện viên cá nhân', 'Đăng ký tập nhóm PT Group'],
        'Product': ['Mua sữa Whey Protein Isolate', 'Mua hũ Creatine tăng cơ', 'Mua đai lưng nâng tạ', 'Mua nước điện giải bù khoáng'],
        'Service': ['Thu phí thuê tủ khóa đồ cá nhân', 'Phí gửi xe theo tháng', 'Phí in thẻ hội viên mới'],
      };

      final expDescriptions = {
        'Equipment': ['Mua mới tạ đơn Rubber Dumbbell', 'Mua khung Smith Machine lắp bổ sung', 'Thanh toán tiền bóng tập yoga'],
        'Utilities': ['Đóng tiền điện tháng 5', 'Đóng tiền nước sạch sinh hoạt', 'Chi phí internet cáp quang tốc độ cao'],
        'Maintenance': ['Bảo trì định kỳ máy chạy Matrix', 'Sửa chữa vòi hoa sen nhà tắm', 'Bảo dưỡng điều hòa trung tâm'],
        'Marketing': ['Chạy quảng cáo Facebook Page', 'Thiết kế in ấn băng rôn khuyến mãi hè', 'Chi phí phát tờ rơi khu vực lân cận'],
        'Other': ['Mua văn phòng phẩm, giấy in', 'Mua nước tẩy rửa phòng tắm', 'Chi phí liên hoan nhẹ nhân viên'],
      };

      for (int i = 0; i < count; i++) {
        final txId = "gen_tx_${DateTime.now().microsecondsSinceEpoch}_$i";
        final isRevenue = _random.nextDouble() > 0.35; // 65% Revenue, 35% Expense
        final type = isRevenue ? 'Revenue' : 'Expense';
        
        String category = '';
        String desc = '';
        double amount = 0.0;

        if (isRevenue) {
          category = revCategories[_random.nextInt(revCategories.length)];
          final listDesc = revDescriptions[category]!;
          desc = listDesc[_random.nextInt(listDesc.length)];
          
          if (category == 'Membership') {
            amount = _random.nextBool() ? 500000.0 : 4500000.0;
          } else if (category == 'Training') {
            amount = 1500000.0 * (_random.nextInt(4) + 1);
          } else if (category == 'Product') {
            amount = (15000.0 * (_random.nextInt(5) + 1)) + (650000.0 * _random.nextInt(3));
          } else {
            amount = 100000.0 * (_random.nextInt(5) + 1);
          }
        } else {
          category = expCategories[_random.nextInt(expCategories.length)];
          final listDesc = expDescriptions[category]!;
          desc = listDesc[_random.nextInt(listDesc.length)];

          if (category == 'Equipment') {
            amount = 1000000.0 * (_random.nextInt(15) + 3);
          } else if (category == 'Utilities') {
            amount = 1500000.0 + _random.nextInt(4000000);
          } else if (category == 'Maintenance') {
            amount = 500000.0 + _random.nextInt(3000000);
          } else if (category == 'Marketing') {
            amount = 1000000.0 * (_random.nextInt(5) + 1);
          } else {
            amount = 100000.0 + _random.nextInt(1000000);
          }
        }

        final paymentMethod = paymentMethods[_random.nextInt(paymentMethods.length)];
        final date = DateTime.now().subtract(Duration(
          days: _random.nextInt(180), // spread in last 6 months
          hours: _random.nextInt(24),
          minutes: _random.nextInt(60),
        ));

        final txMap = {
          'id': txId,
          'type': type,
          'category': category,
          'description': desc,
          'amount': amount,
          'transactionDate': Timestamp.fromDate(date),
          'paymentMethod': paymentMethod,
          'status': 'Completed',
          'createdAt': Timestamp.fromDate(date),
          'updatedAt': Timestamp.fromDate(date),
          'createdBy': 'admin_uid_01',
        };

        final txRef = _db.collection('transactions').doc(txId);
        batch.set(txRef, txMap);
      }

      await batch.commit();
      onLog("✔️ Đã sinh thành công $count giao dịch tài chính.");
    } catch (e) {
      onLog("❌ Lỗi khi sinh giao dịch ngẫu nhiên: $e");
    }
  }

  // 3. Generate Random Products
  Future<void> generateRandomProducts(int count) async {
    onLog("⚡ Bắt đầu sinh ngẫu nhiên $count Sản phẩm...");
    try {
      final batch = _db.batch();
      final prodTemplates = [
        {'name': 'Bình nước giữ nhiệt Kinetic 800ml', 'category': 'Equipment', 'price': 250000.0},
        {'name': 'Găng tay tập tạ da bò cao cấp', 'category': 'Equipment', 'price': 320000.0},
        {'name': 'Áo thun tập gym nam thấm hút mồ hôi', 'category': 'Apparel', 'price': 180000.0},
        {'name': 'Quần đùi tập gym co giãn 4 chiều', 'category': 'Apparel', 'price': 220000.0},
        {'name': 'BCAA Amino Acid phục hồi cơ bắp', 'category': 'Supplements', 'price': 780000.0},
        {'name': 'Pre-Workout tăng sức mạnh bùng nổ', 'category': 'Supplements', 'price': 890000.0},
        {'name': 'Nước suối Aquafina 500ml', 'category': 'Drinks', 'price': 10000.0},
        {'name': 'Nước ngọt không calo Coca Light', 'category': 'Drinks', 'price': 18000.0},
      ];

      for (int i = 0; i < count; i++) {
        final prodId = "gen_prod_${DateTime.now().microsecondsSinceEpoch}_$i";
        final template = prodTemplates[_random.nextInt(prodTemplates.length)];
        final stock = _random.nextInt(90) + 10;
        final nameSuffix = _random.nextBool() ? " Pro" : " Elite";

        final prodMap = {
          'id': prodId,
          'name': "${template['name']}$nameSuffix",
          'category': template['category'],
          'price': template['price'],
          'stock': stock,
          'imageUrl': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500',
          'description': "Sản phẩm chất lượng cao hỗ trợ tập luyện thể hình cực tốt.",
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        final prodRef = _db.collection('products').doc(prodId);
        batch.set(prodRef, prodMap);
      }

      await batch.commit();
      onLog("✔️ Đã sinh thành công $count sản phẩm.");
    } catch (e) {
      onLog("❌ Lỗi khi sinh sản phẩm ngẫu nhiên: $e");
    }
  }

  // 4. Generate Random Equipment
  Future<void> generateRandomEquipment(int count) async {
    onLog("⚡ Bắt đầu sinh ngẫu nhiên $count Thiết bị phòng tập...");
    try {
      final batch = _db.batch();
      final equipNames = [
        {'name': 'Xe đạp thể thao Matrix U50', 'category': 'Cardio', 'loc': 'Khu Cardio'},
        {'name': 'Máy tập cơ ngực Chest Press', 'category': 'Strength', 'loc': 'Khu Máy tập'},
        {'name': 'Ghế tập bụng nghiêng Adjustable Bench', 'category': 'Strength', 'loc': 'Khu Tạ nặng'},
        {'name': 'Thảm tập Yoga chống trơn trượt', 'category': 'Accessories', 'loc': 'Phòng Yoga'},
        {'name': 'Bóng tạ thể lực Medicine Ball 5kg', 'category': 'Accessories', 'loc': 'Khu Functional'},
      ];
      final statuses = ['Operational', 'Under Maintenance', 'Out of Order'];

      for (int i = 0; i < count; i++) {
        final id = "gen_equip_${DateTime.now().microsecondsSinceEpoch}_$i";
        final template = equipNames[_random.nextInt(equipNames.length)];
        final status = statuses[_random.nextInt(statuses.length)];
        
        final purchaseDate = DateTime.now().subtract(Duration(days: _random.nextInt(365)));
        final lastMaint = purchaseDate.add(Duration(days: _random.nextInt(30)));
        final nextMaint = lastMaint.add(const Duration(days: 30));

        final equipMap = {
          'id': id,
          'name': template['name'],
          'category': template['category'],
          'status': status,
          'serialNumber': "SN-${_random.nextInt(89999) + 10000}",
          'location': template['loc'],
          'purchaseDate': Timestamp.fromDate(purchaseDate),
          'lastMaintenanceDate': Timestamp.fromDate(lastMaint),
          'nextMaintenanceDate': Timestamp.fromDate(nextMaint),
          'maintenanceIntervalDays': 30,
          'notes': status == 'Operational' ? 'Hoạt động tốt và trơn tru.' : 'Đang đợi kiểm tra định kỳ.',
          'createdAt': Timestamp.fromDate(purchaseDate),
          'updatedAt': Timestamp.now(),
          'createdBy': 'admin_uid_01',
        };

        final equipRef = _db.collection('equipment').doc(id);
        batch.set(equipRef, equipMap);
      }

      await batch.commit();
      onLog("✔️ Đã sinh thành công $count thiết bị.");
    } catch (e) {
      onLog("❌ Lỗi khi sinh thiết bị ngẫu nhiên: $e");
    }
  }

  // 5. Generate Random Feedbacks
  Future<void> generateRandomFeedbacks(int count) async {
    onLog("⚡ Bắt đầu sinh ngẫu nhiên $count Phản hồi hội viên...");
    try {
      final batch = _db.batch();
      final subjects = ['Máy tập bị hỏng', 'Điều hòa không mát', 'Thái độ PT', 'Nhà vệ sinh bẩn', 'Giờ mở cửa phòng gym'];
      final messages = [
        'Máy chạy bộ Matrix số 3 chạy bị giật giật rất nguy hiểm khi tập nhanh.',
        'Hôm nay phòng tập rất nóng, điều hòa khu tạ nặng hình như bị hỏng.',
        'Huấn luyện viên hướng dẫn rất nhiệt tình và thân thiện với học viên mới.',
        'Phòng thay đồ nam bị đọng nước bẩn, mong ban quản lý cho dọn dẹp thường xuyên.',
        'Hy vọng phòng tập mở cửa sớm hơn vào chủ nhật (từ 5h30 thay vì 7h00).'
      ];

      for (int i = 0; i < count; i++) {
        final id = "gen_fb_${DateTime.now().microsecondsSinceEpoch}_$i";
        final idx = _random.nextInt(subjects.length);
        final name = _randomName();
        final date = DateTime.now().subtract(Duration(days: _random.nextInt(30)));

        final fbMap = {
          'id': id,
          'userId': 'gen_user_random',
          'userName': name,
          'subject': subjects[idx],
          'message': messages[idx],
          'status': _random.nextBool() ? 'pending' : 'resolved',
          'createdAt': Timestamp.fromDate(date),
        };

        final fbRef = _db.collection('feedbacks').doc(id);
        batch.set(fbRef, fbMap);
      }

      await batch.commit();
      onLog("✔️ Đã sinh thành công $count phản hồi hội viên.");
    } catch (e) {
      onLog("❌ Lỗi khi sinh phản hồi ngẫu nhiên: $e");
    }
  }

  // 6. Generate Random Staff (Personnel)
  Future<void> generateRandomStaff(int count) async {
    onLog("⚡ Bắt đầu sinh ngẫu nhiên $count Nhân sự/Nhân viên...");
    try {
      final batch = _db.batch();
      final positions = ['PT/Trainer', 'Receptionist', 'Manager', 'Cleaner', 'Security'];
      final statuses = ['active', 'inactive'];

      for (int i = 0; i < count; i++) {
        final uid = "gen_staff_${DateTime.now().microsecondsSinceEpoch}_$i";
        final name = _randomName();
        final email = _randomEmail(name);
        final phone = _randomPhone();
        final isFemale = name.contains('Thị') || name.contains('Vy') || name.contains('Mai') || name.contains('Linh') || name.contains('Trang') || name.contains('Oanh') || name.contains('Hương') || name.contains('Vân');
        final gender = isFemale ? 'Nữ' : 'Nam';
        
        final position = positions[_random.nextInt(positions.length)];
        final status = statuses[_random.nextDouble() > 0.15 ? 0 : 1]; // 85% active

        final createdDate = DateTime.now().subtract(Duration(days: _random.nextInt(365)));
        
        double salary = 6000000.0;
        if (position == 'Manager') {
          salary = 20000000.0 + _random.nextInt(10000000);
        } else if (position == 'PT/Trainer') {
          salary = 12000000.0 + _random.nextInt(8000000);
        } else if (position == 'Receptionist') {
          salary = 8000000.0 + _random.nextInt(4000000);
        } else {
          salary = 6000000.0 + _random.nextInt(3000000);
        }

        final staffMap = {
          'uid': uid,
          'email': email,
          'fullName': name,
          'role': 'staff',
          'status': status,
          'createdAt': Timestamp.fromDate(createdDate),
          'phoneNumber': phone,
          'address': "${_random.nextInt(500) + 1} Đường ${_random.nextInt(20) + 1}, Quận ${_random.nextInt(12) + 1}, TP.HCM",
          'position': position,
          'salary': salary,
          'gender': gender,
        };

        final docRef = _db.collection('users').doc(uid);
        batch.set(docRef, staffMap);
      }

      await batch.commit();
      onLog("✔️ Đã sinh thành công $count nhân sự mới.");
    } catch (e) {
      onLog("❌ Lỗi khi sinh nhân sự ngẫu nhiên: $e");
    }
  }

  // 7. Generate Random Schedules
  Future<void> generateRandomSchedules(int count) async {
    onLog("⚡ Bắt đầu sinh ngẫu nhiên $count Lịch làm việc...");
    try {
      // Fetch staff members first
      final staffSnapshot = await _db.collection('users').where('role', isEqualTo: 'staff').get();
      List<DocumentSnapshot> staffList = staffSnapshot.docs;

      if (staffList.isEmpty) {
        onLog("⚠️ Chưa có nhân viên trong hệ thống. Đang tự động sinh 5 nhân viên...");
        await generateRandomStaff(5);
        final newStaffSnapshot = await _db.collection('users').where('role', isEqualTo: 'staff').get();
        staffList = newStaffSnapshot.docs;
      }

      final batch = _db.batch();
      final ptTasks = [
        'Huấn luyện học viên gói Pro Elite ca sáng',
        'Huấn luyện học viên gói Pro Elite ca tối',
        'Dạy lớp Group X đạp xe trong nhà',
        'Dạy lớp Yoga cơ bản'
      ];
      final receptionTasks = [
        'Trực quầy lễ tân ca sáng',
        'Trực quầy lễ tân ca chiều',
        'Kiểm tra hồ sơ đăng ký mới'
      ];
      final genericTasks = [
        'Họp giao ban tuần',
        'Kiểm tra định kỳ phòng tập',
        'Hỗ trợ khách hàng tại khu tạ'
      ];

      final statuses = ['pending', 'ongoing', 'completed'];

      for (int i = 0; i < count; i++) {
        final id = "gen_sch_${DateTime.now().microsecondsSinceEpoch}_$i";
        
        // Choose random staff
        final staffDoc = staffList[_random.nextInt(staffList.length)];
        final staffData = staffDoc.data() as Map<String, dynamic>;
        final staffUid = staffDoc.id;
        final staffName = staffData['fullName'] ?? 'Nhân viên';
        final position = staffData['position'] ?? '';

        String task = '';
        if (position == 'PT/Trainer') {
          task = ptTasks[_random.nextInt(ptTasks.length)];
        } else if (position == 'Receptionist') {
          task = receptionTasks[_random.nextInt(receptionTasks.length)];
        } else {
          task = genericTasks[_random.nextInt(genericTasks.length)];
        }

        // Generate schedule date (60% on today, 40% on nearby days)
        final bool isToday = _random.nextDouble() > 0.4;
        DateTime scheduleDate;
        if (isToday) {
          scheduleDate = DateTime.now();
        } else {
          scheduleDate = DateTime.now().add(Duration(days: _random.nextBool() ? 1 : -1));
        }

        final int startHour = _random.nextBool() ? 6 + _random.nextInt(4) : 14 + _random.nextInt(4);
        final int durationHours = 4 + _random.nextInt(5);

        final startTime = DateTime(scheduleDate.year, scheduleDate.month, scheduleDate.day, startHour, 0);
        final endTime = startTime.add(Duration(hours: durationHours));

        String status = 'pending';
        final now = DateTime.now();
        if (endTime.isBefore(now)) {
          status = 'completed';
        } else if (startTime.isBefore(now) && endTime.isAfter(now)) {
          status = 'ongoing';
        } else {
          status = statuses[_random.nextInt(statuses.length)];
        }

        final scheduleMap = {
          'id': id,
          'staffUid': staffUid,
          'staffName': staffName,
          'task': task,
          'startTime': Timestamp.fromDate(startTime),
          'endTime': Timestamp.fromDate(endTime),
          'status': status,
        };

        final docRef = _db.collection('schedules').doc(id);
        batch.set(docRef, scheduleMap);
      }

      await batch.commit();
      onLog("✔️ Đã sinh thành công $count lịch làm việc.");
    } catch (e) {
      onLog("❌ Lỗi khi sinh lịch làm việc ngẫu nhiên: $e");
    }
  }

  // 8. Generate Random Checkins
  Future<void> generateRandomCheckins(int count) async {
    onLog("⚡ Bắt đầu sinh ngẫu nhiên $count Lượt ra vào (Check-in/out)...");
    try {
      // Fetch members list first
      final membersSnapshot = await _db.collection('members').get();
      List<DocumentSnapshot> membersList = membersSnapshot.docs;

      if (membersList.isEmpty) {
        onLog("⚠️ Chưa có hội viên nào trong hệ thống. Đang tự động sinh 10 hội viên...");
        await generateRandomMembers(10);
        final newMembersSnapshot = await _db.collection('members').get();
        membersList = newMembersSnapshot.docs;
      }

      final batch = _db.batch();
      final zones = ['Khu vực chính (Check-in)', 'Khu vực chính (Check-out)', 'Khu Cardio (Check-in)', 'Phòng Yoga (Check-in)'];

      for (int i = 0; i < count; i++) {
        final id = "gen_checkin_${DateTime.now().microsecondsSinceEpoch}_$i";
        final memberDoc = membersList[_random.nextInt(membersList.length)];
        final memberData = memberDoc.data() as Map<String, dynamic>;
        final memberId = memberDoc.id;
        final userName = memberData['fullName'] ?? 'Hội viên';

        // Generate date within the past 48 hours (to look like active flow!)
        final date = DateTime.now().subtract(Duration(
          hours: _random.nextInt(48),
          minutes: _random.nextInt(60),
        ));

        final checkinMap = {
          'memberId': memberId,
          'userName': userName,
          'timestamp': Timestamp.fromDate(date),
          'zone': zones[_random.nextInt(zones.length)],
        };

        final docRef = _db.collection('checkins').doc(id);
        batch.set(docRef, checkinMap);
      }

      await batch.commit();
      onLog("✔️ Đã sinh thành công $count lượt ra vào.");
    } catch (e) {
      onLog("❌ Lỗi khi sinh lượt ra vào ngẫu nhiên: $e");
    }
  }
}
