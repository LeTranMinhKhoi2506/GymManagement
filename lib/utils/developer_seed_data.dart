class DeveloperSeedData {
  static const List<Map<String, dynamic>> users = [
    {
      "uid": "admin_uid_01",
      "email": "admin@kinetic.com",
      "fullName": "Lê Trần Minh Khôi",
      "role": "admin",
      "status": "active",
      "createdAt": "2026-01-01T08:00:00Z",
      "phoneNumber": "0901234567",
      "address": "123 Đường 3/2, Quận 10, TP.HCM",
      "position": "Manager",
      "salary": 25000000.0,
      "gender": "Nam"
    },
    {
      "uid": "pt_uid_01",
      "email": "pt.hung@kinetic.com",
      "fullName": "Nguyễn Văn Hùng",
      "role": "trainer",
      "status": "active",
      "createdAt": "2026-01-15T09:00:00Z",
      "phoneNumber": "0912345678",
      "address": "456 Lê Hồng Phong, Quận 5, TP.HCM",
      "position": "PT/Trainer",
      "salary": 15000000.0,
      "gender": "Nam"
    },
    {
      "uid": "pt_uid_02",
      "email": "pt.linh@kinetic.com",
      "fullName": "Trần Thị Linh",
      "role": "trainer",
      "status": "active",
      "createdAt": "2026-02-01T10:00:00Z",
      "phoneNumber": "0923456789",
      "address": "789 Nguyễn Trãi, Quận 1, TP.HCM",
      "position": "PT/Trainer",
      "salary": 14500000.0,
      "gender": "Nữ"
    },
    {
      "uid": "receptionist_uid_01",
      "email": "receptionist.mai@kinetic.com",
      "fullName": "Phạm Thanh Mai",
      "role": "receptionist",
      "status": "active",
      "createdAt": "2026-01-20T08:30:00Z",
      "phoneNumber": "0934567890",
      "address": "101 Cách Mạng Tháng 8, Quận 3, TP.HCM",
      "position": "Receptionist",
      "salary": 8000000.0,
      "gender": "Nữ"
    },
    {
      "uid": "user_uid_01",
      "email": "customer.minh@gmail.com",
      "fullName": "Nguyễn Hoàng Minh",
      "role": "user",
      "status": "active",
      "createdAt": "2026-03-01T14:00:00Z",
      "phoneNumber": "0945678901",
      "address": "202 Điện Biên Phủ, Bình Thạnh, TP.HCM",
      "gender": "Nam"
    },
    {
      "uid": "user_uid_02",
      "email": "customer.vy@gmail.com",
      "fullName": "Trần Thảo Vy",
      "role": "user",
      "status": "active",
      "createdAt": "2026-03-05T15:30:00Z",
      "phoneNumber": "0956789012",
      "address": "303 Nam Kỳ Khởi Nghĩa, Quận 3, TP.HCM",
      "gender": "Nữ"
    }
  ];

  static const List<Map<String, dynamic>> members = [
    {
      "id": "user_uid_01",
      "fullName": "Nguyễn Hoàng Minh",
      "email": "customer.minh@gmail.com",
      "phoneNumber": "0945678901",
      "membershipType": "Standard 1 Month",
      "status": "Active",
      "isCurrentlyTraining": true,
      "nextRenewal": "2026-07-01T00:00:00Z",
      "memberSince": "2026-03-01T14:00:00Z",
      "ltv": 1500000.0
    },
    {
      "id": "user_uid_02",
      "fullName": "Trần Thảo Vy",
      "email": "customer.vy@gmail.com",
      "phoneNumber": "0956789012",
      "membershipType": "Pro Elite 3 Months",
      "status": "Active",
      "isCurrentlyTraining": false,
      "nextRenewal": "2026-06-05T00:00:00Z",
      "memberSince": "2026-03-05T15:30:00Z",
      "ltv": 4500000.0
    }
  ];

  static const List<Map<String, dynamic>> membershipPlans = [
    {
      "id": "plan_standard_1m",
      "name": "Standard 1 Month",
      "description": "Gói tập cơ bản không giới hạn thời gian tập trong 1 tháng",
      "price": 500000.0,
      "durationMonths": 1,
      "hasPT": false,
      "isActive": true
    },
    {
      "id": "plan_pro_elite_3m",
      "name": "Pro Elite 3 Months",
      "description": "Gói tập nâng cao kèm 12 buổi PT trong 3 tháng",
      "price": 4500000.0,
      "durationMonths": 3,
      "hasPT": true,
      "isActive": true
    },
    {
      "id": "plan_trial_7d",
      "name": "Trial 7 Days",
      "description": "Trải nghiệm tập thử 7 ngày miễn phí",
      "price": 0.0,
      "durationMonths": 0,
      "hasPT": false,
      "isActive": true
    }
  ];

  static const List<Map<String, dynamic>> products = [
    {
      "id": "prod_whey_01",
      "name": "Whey Protein Isolate 2kg",
      "category": "Supplements",
      "price": 1450000.0,
      "stock": 25,
      "imageUrl": "https://images.unsplash.com/photo-1579758629938-03607ccdbaba?w=500",
      "description": "Sữa bột bổ sung protein tinh khiết hấp thụ nhanh"
    },
    {
      "id": "prod_creatine_01",
      "name": "Creatine Monohydrate 300g",
      "category": "Supplements",
      "price": 650000.0,
      "stock": 15,
      "imageUrl": "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500",
      "description": "Tăng cường sức mạnh và kích thước cơ bắp"
    },
    {
      "id": "prod_belt_01",
      "name": "Đai lưng tập Gym Harbinger",
      "category": "Equipment",
      "price": 850000.0,
      "stock": 8,
      "imageUrl": "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500",
      "description": "Đai bảo vệ cột sống khi gánh tạ nặng"
    },
    {
      "id": "prod_water_01",
      "name": "Nước điện giải Revive 500ml",
      "category": "Drinks",
      "price": 15000.0,
      "stock": 120,
      "imageUrl": "https://images.unsplash.com/photo-1608885898957-a599fb1b467e?w=500",
      "description": "Nước điện giải bù khoáng Revive mát lạnh"
    }
  ];

  static const List<Map<String, dynamic>> equipment = [
    {
      "id": "equip_treadmill_01",
      "name": "Máy chạy bộ Matrix T50",
      "category": "Cardio",
      "status": "Operational",
      "serialNumber": "MXT50-2025-001",
      "location": "Khu Cardio",
      "purchaseDate": "2025-01-10T00:00:00Z",
      "lastMaintenanceDate": "2026-05-10T00:00:00Z",
      "nextMaintenanceDate": "2026-06-10T00:00:00Z",
      "maintenanceIntervalDays": 30,
      "notes": "Chạy êm, màn hình cảm ứng hoạt động tốt",
      "createdAt": "2025-01-10T08:00:00Z",
      "updatedAt": "2026-05-10T10:00:00Z",
      "createdBy": "admin_uid_01"
    },
    {
      "id": "equip_treadmill_02",
      "name": "Máy chạy bộ Matrix T50",
      "category": "Cardio",
      "status": "Under Maintenance",
      "serialNumber": "MXT50-2025-002",
      "location": "Khu Cardio",
      "purchaseDate": "2025-01-10T00:00:00Z",
      "lastMaintenanceDate": "2026-05-20T00:00:00Z",
      "nextMaintenanceDate": "2026-06-20T00:00:00Z",
      "maintenanceIntervalDays": 30,
      "notes": "Hỏng bàn chạy, đang đợi linh kiện thay thế",
      "createdAt": "2025-01-10T08:00:00Z",
      "updatedAt": "2026-05-20T09:00:00Z",
      "createdBy": "admin_uid_01"
    },
    {
      "id": "equip_smith_01",
      "name": "Khung gánh tạ Smith Machine",
      "category": "Strength",
      "status": "Operational",
      "serialNumber": "SM-2025-010",
      "location": "Khu Tạ nặng",
      "purchaseDate": "2025-03-15T00:00:00Z",
      "lastMaintenanceDate": "2026-05-15T00:00:00Z",
      "nextMaintenanceDate": "2026-08-15T00:00:00Z",
      "maintenanceIntervalDays": 90,
      "notes": "Bôi trơn đường ray định kỳ tốt",
      "createdAt": "2025-03-15T08:00:00Z",
      "updatedAt": "2026-05-15T11:00:00Z",
      "createdBy": "admin_uid_01"
    }
  ];

  static const List<Map<String, dynamic>> transactions = [
    {
      "id": "tx_rev_01",
      "type": "Revenue",
      "category": "Membership",
      "description": "Đóng phí Standard 1 Month - Nguyễn Hoàng Minh",
      "amount": 500000.0,
      "transactionDate": "2026-06-01T09:30:00Z",
      "paymentMethod": "Transfer",
      "status": "Completed",
      "relatedMemberId": "user_uid_01",
      "createdAt": "2026-06-01T09:30:00Z",
      "updatedAt": "2026-06-01T09:30:00Z",
      "createdBy": "receptionist_uid_01"
    },
    {
      "id": "tx_rev_02",
      "type": "Revenue",
      "category": "Product",
      "description": "Bán 1 hũ Whey Protein Isolate - Khách lẻ",
      "amount": 1450000.0,
      "transactionDate": "2026-06-01T10:15:00Z",
      "paymentMethod": "Cash",
      "status": "Completed",
      "createdAt": "2026-06-01T10:15:00Z",
      "updatedAt": "2026-06-01T10:15:00Z",
      "createdBy": "receptionist_uid_01"
    },
    {
      "id": "tx_exp_01",
      "type": "Expense",
      "category": "Utilities",
      "description": "Thanh toán tiền điện tháng 5/2026",
      "amount": 5200000.0,
      "transactionDate": "2026-06-02T15:00:00Z",
      "paymentMethod": "Transfer",
      "status": "Completed",
      "createdAt": "2026-06-02T15:00:00Z",
      "updatedAt": "2026-06-02T15:00:00Z",
      "createdBy": "admin_uid_01"
    }
  ];

  static const List<Map<String, dynamic>> payments = [
    {
      "id": "pm_01",
      "memberId": "user_uid_01",
      "memberName": "Nguyễn Hoàng Minh",
      "membershipType": "Standard 1 Month",
      "amount": 500000.0,
      "dueDate": "2026-07-01T00:00:00Z",
      "paymentDate": "2026-06-01T09:30:00Z",
      "status": "Paid",
      "paymentMethod": "Transfer",
      "paymentType": "Membership",
      "transactionId": "tx_rev_01",
      "createdAt": "2026-06-01T09:30:00Z",
      "updatedAt": "2026-06-01T09:30:00Z"
    },
    {
      "id": "pm_02",
      "memberId": "user_uid_02",
      "memberName": "Trần Thảo Vy",
      "membershipType": "Pro Elite 3 Months",
      "amount": 4500000.0,
      "dueDate": "2026-06-05T00:00:00Z",
      "status": "Pending",
      "paymentMethod": "Cash",
      "paymentType": "Membership",
      "createdAt": "2026-03-05T15:30:00Z",
      "updatedAt": "2026-03-05T15:30:00Z"
    }
  ];

  static const List<Map<String, dynamic>> payroll = [
    {
      "id": "pr_01",
      "staffId": "receptionist_uid_01",
      "staffName": "Phạm Thanh Mai",
      "position": "Receptionist",
      "baseSalary": 8000000.0,
      "paymentMonth": "2026-05-01T00:00:00Z",
      "workingDays": 22,
      "bonus": 500000.0,
      "deductions": 800000.0,
      "netSalary": 7700000.0,
      "status": "Paid",
      "paymentMethod": "Bank Transfer",
      "paymentDate": "2026-05-31T17:00:00Z",
      "createdAt": "2026-05-25T08:00:00Z",
      "updatedAt": "2026-05-31T17:00:00Z",
      "createdBy": "admin_uid_01"
    }
  ];

  static const List<Map<String, dynamic>> schedules = [
    {
      "id": "sch_01",
      "staffUid": "receptionist_uid_01",
      "staffName": "Phạm Thanh Mai",
      "task": "Trực quầy lễ tân ca sáng",
      "startTime": "2026-06-03T06:00:00Z",
      "endTime": "2026-06-03T14:00:00Z",
      "status": "pending"
    },
    {
      "id": "sch_02",
      "staffUid": "pt_uid_01",
      "staffName": "Nguyễn Văn Hùng",
      "task": "Huấn luyện học viên gói Pro Elite ca tối",
      "startTime": "2026-06-03T18:00:00Z",
      "endTime": "2026-06-03T20:00:00Z",
      "status": "pending"
    }
  ];

  static const List<Map<String, dynamic>> feedbacks = [
    {
      "id": "fb_01",
      "userId": "user_uid_01",
      "userName": "Nguyễn Hoàng Minh",
      "subject": "Ý kiến về máy chạy bộ",
      "message": "Máy Matrix T50 số 2 bị hỏng bàn chạy khoảng 1 tuần nay rồi, mong trung tâm sớm sửa chữa.",
      "status": "pending",
      "createdAt": "2026-05-28T10:00:00Z"
    }
  ];

  static const List<Map<String, dynamic>> categories = [
    {"id": "cat_news", "name": "Tin tức", "type": "Content", "itemCount": 2},
    {"id": "cat_promo", "name": "Khuyến mãi", "type": "Content", "itemCount": 1},
    {"id": "cat_tips", "name": "Kiến thức", "type": "Content", "itemCount": 2},
    {"id": "cat_event", "name": "Sự kiện", "type": "Content", "itemCount": 1},
    {"id": "cat_supp", "name": "Supplements", "type": "Product", "itemCount": 2},
    {"id": "cat_equip_prod", "name": "Equipment", "type": "Product", "itemCount": 1},
    {"id": "cat_cardio", "name": "Cardio", "type": "Equipment", "itemCount": 2},
    {"id": "cat_strength", "name": "Strength", "type": "Equipment", "itemCount": 1}
  ];

  static const List<Map<String, dynamic>> media = [
    {
      "id": "media_gym_1",
      "url": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800",
      "fileName": "kinetic_gym_main.jpg",
      "type": "image",
      "uploadedAt": "2026-05-01T08:00:00Z",
      "size": 245600
    },
    {
      "id": "media_yoga_1",
      "url": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800",
      "fileName": "yoga_class.jpg",
      "type": "image",
      "uploadedAt": "2026-05-02T09:30:00Z",
      "size": 185400
    },
    {
      "id": "media_whey_1",
      "url": "https://images.unsplash.com/photo-1579758629938-03607ccdbaba?w=800",
      "fileName": "whey_protein.jpg",
      "type": "image",
      "uploadedAt": "2026-05-03T10:00:00Z",
      "size": 312000
    },
    {
      "id": "media_workout_1",
      "url": "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800",
      "fileName": "workout_hardcore.jpg",
      "type": "image",
      "uploadedAt": "2026-05-04T11:00:00Z",
      "size": 420300
    }
  ];

  static const List<Map<String, dynamic>> contents = [
    {
      "id": "post_gym_opening",
      "title": "Khai trương phòng tập Kinetic Elite Quận 7",
      "body": "Chúng tôi hân hạnh thông báo chi nhánh mới Kinetic Elite sẽ chính thức khai trương tại Quận 7 vào ngày 15/06/2026. Phòng tập mới sở hữu không gian rộng hơn 1000m2, trang bị máy Matrix hiện đại nhất cùng đội ngũ PT chuyên nghiệp. Đặc biệt, giảm giá 30% cho 100 hội viên đăng ký đầu tiên. Hãy đến trải nghiệm ngay!",
      "imageUrl": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800",
      "category": "Tin tức",
      "author": "Lê Trần Minh Khôi",
      "createdAt": "2026-05-20T08:00:00Z",
      "isPublished": true
    },
    {
      "id": "post_summer_promo",
      "title": "Chương trình ưu đãi cực cháy chào hè 2026",
      "body": "Đón hè rực rỡ với ưu đãi giảm giá lên đến 20% cho tất cả các gói tập từ 3 tháng trở lên khi đăng ký trong tháng 6 này. Nhận ngay quà tặng là 1 bình nước giữ nhiệt Kinetic và 1 áo thun tập gym cao cấp. Đăng ký ngay hôm nay để có vóc dáng săn chắc tự tin đón hè nhé các bạn!",
      "imageUrl": "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800",
      "category": "Khuyến mãi",
      "author": "Lê Trần Minh Khôi",
      "createdAt": "2026-05-25T09:00:00Z",
      "isPublished": true
    },
    {
      "id": "post_nutrition_tips",
      "title": "Chế độ dinh dưỡng hoàn hảo cho người mới bắt đầu",
      "body": "Khi mới bắt đầu tập gym, chế độ dinh dưỡng đóng vai trò quyết định đến 70% sự thành công của bạn. Hãy đảm bảo bạn cung cấp đủ lượng Protein cần thiết (khoảng 1.5g - 2g trên mỗi kg thể trọng), bổ sung tinh bột hấp thụ chậm như yến mạch, khoai lang và không quên uống ít nhất 2-3 lít nước mỗi ngày. Tránh xa các thực phẩm nhiều dầu mỡ và đồ ngọt để đạt kết quả tốt nhất.",
      "imageUrl": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800",
      "category": "Kiến thức",
      "author": "Nguyễn Văn Hùng",
      "createdAt": "2026-05-28T14:30:00Z",
      "isPublished": true
    }
  ];
}
