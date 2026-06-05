import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/route/routes.dart';

class PtStudentManagementScreen extends StatefulWidget {
  const PtStudentManagementScreen({super.key});

  @override
  State<PtStudentManagementScreen> createState() => _PtStudentManagementScreenState();
}

class _PtStudentManagementScreenState extends State<PtStudentManagementScreen> {
  String searchQuery = "";
  String selectedCategory = "Tất cả";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String ptId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildSearchBar(),
            ),
            _buildCategoryList(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('students')
                    .where('ptId', isEqualTo: ptId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text("Lỗi tải dữ liệu", style: TextStyle(color: Colors.red)));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Chưa có học viên nào", style: TextStyle(color: Colors.grey)));
                  }

                  // Lọc theo tìm kiếm và danh mục tại local
                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    
                    // Lọc bỏ học viên có số buổi còn lại <= 0
                    int remainingSessions = data['remainingSessions'] ?? 0;
                    if (remainingSessions <= 0) {
                      return false;
                    }

                    String name = (data['name'] ?? '').toString().toLowerCase();
                    String goal = (data['goal'] ?? '').toString().toUpperCase();

                    // Tìm kiếm theo tên
                    if (searchQuery.isNotEmpty && !name.contains(searchQuery.toLowerCase())) {
                      return false;
                    }

                    // Lọc theo tab mục tiêu
                    if (selectedCategory != "Tất cả") {
                      String mappedGoal = "";
                      if (selectedCategory == "Tăng cơ") mappedGoal = "HYPERTROPHY";
                      if (selectedCategory == "Linh hoạt") mappedGoal = "MOBILITY";
                      if (selectedCategory == "Giảm cân") mappedGoal = "WEIGHT LOSS";

                      // Hỗ trợ khớp cả tiếng Anh và tiếng Việt trong DB
                      if (goal != mappedGoal && goal != selectedCategory.toUpperCase()) {
                        return false;
                      }
                    }

                    return true;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(child: Text("Không tìm thấy học viên phù hợp", style: TextStyle(color: Colors.grey)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var doc = filteredDocs[index];
                      var data = doc.data() as Map<String, dynamic>;
                      String name = data['name'] ?? "Học viên";
                      String goal = data['goal'] ?? "CHƯA XÁC ĐỊNH";

                      int remainingSessions = data['remainingSessions'] ?? 0;

                      return _buildStudentCard(
                        docId: doc.id,
                        name: name,
                        category: goal,
                        lastSession: data['lastSession'] ?? "Chưa có",
                        imageUrl: data['photoUrl'] ?? 'https://i.pravatar.cc/150?u=${doc.id}',
                        categoryColor: _getGoalColor(goal),
                        ptId: ptId,
                        studentUid: data['memberId'] ?? '',
                        remainingSessions: remainingSessions,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(ptId),
        backgroundColor: const Color(0xFFD0FD3E),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }

  Color _getGoalColor(String? goal) {
    switch (goal?.toUpperCase()) {
      case 'HYPERTROPHY': return const Color(0xFFD0FD3E);
      case 'MOBILITY': return Colors.orangeAccent;
      case 'WEIGHT LOSS': return Colors.deepOrangeAccent;
      default: return Colors.blueAccent;
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildSafeAvatar('https://i.pravatar.cc/150?u=pt_marcus', 18),
              const SizedBox(width: 10),
              const Text(
                "KINETIC",
                style: TextStyle(
                  color: Color(0xFFD0FD3E),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Icon(Icons.notifications_none, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildSafeAvatar(String url, double radius) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[900],
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: Colors.white, size: radius),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            searchQuery = value.trim();
          });
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          icon: const Icon(Icons.search, color: Colors.grey, size: 20),
          hintText: "Tìm kiếm học viên...",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = "";
                    });
                  },
                  child: const Icon(Icons.clear, color: Colors.grey, size: 18),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = ["Tất cả", "Tăng cơ", "Linh hoạt", "Giảm cân"];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          bool isSelected = categories[index] == selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = categories[index];
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD0FD3E) : const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentCard({
    required String docId,
    required String name,
    required String category,
    required String lastSession,
    required String imageUrl,
    required Color categoryColor,
    required String ptId,
    required String studentUid,
    required int remainingSessions,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildSafeAvatar(imageUrl, 30),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: categoryColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          category,
                          style: TextStyle(color: categoryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showEditGoalDialog(context, docId, category),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(Icons.edit_rounded, color: categoryColor, size: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("BUỔI TRƯỚC", style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(lastSession, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    "CÒN LẠI: $remainingSessions BUỔI",
                    style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showBookScheduleBottomSheet(ptId, name, studentUid),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text("Đặt lịch", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final List<String> ids = [studentUid, ptId];
                    ids.sort();
                    final chatRoomId = ids.join('_');
                    context.push(
                      '${Routes.chat}?chatRoomId=$chatRoomId&otherUserId=$studentUid&otherUserName=$name'
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0FD3E),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text("Nhắn tin", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, String docId, String currentGoal) {
    String selectedGoal = currentGoal.toUpperCase();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildGoalOption(String label, String value) {
              bool isSelected = selectedGoal == value;
              return GestureDetector(
                onTap: () {
                  setDialogState(() {
                    selectedGoal = value;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD0FD3E).withValues(alpha: 0.1) : Colors.transparent,
                    border: Border.all(color: isSelected ? const Color(0xFFD0FD3E) : Colors.white10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFFD0FD3E) : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: Color(0xFFD0FD3E), size: 20),
                    ],
                  ),
                ),
              );
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF1C1C1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
              title: const Text(
                "CHỈNH SỬA MỤC TIÊU",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildGoalOption("TĂNG CƠ (HYPERTROPHY)", "HYPERTROPHY"),
                  const SizedBox(height: 10),
                  buildGoalOption("LINH HOẠT (MOBILITY)", "MOBILITY"),
                  const SizedBox(height: 10),
                  buildGoalOption("GIẢM CÂN (WEIGHT LOSS)", "WEIGHT LOSS"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("HỦY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('students').doc(docId).update({
                      'goal': selectedGoal,
                    });
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Cập nhật mục tiêu thành công!"),
                          backgroundColor: Color(0xFFD0FD3E),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0FD3E),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("LƯU", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Đối thoại (Dialog) thêm học viên mới
  void _showAddStudentDialog(String ptId) {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    String selectedGoal = "Hypertrophy"; // Mặc định
    int selectedMonths = 1; // Mặc định

    String foundUserName = "";
    String? foundUserId;
    String? foundUserPhotoUrl;
    bool isCheckingPhone = false;
    String phoneError = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white12),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "THÊM HỌC VIÊN MỚI",
                        style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 20),
  
                      // Số điện thoại
                      const Text("SỐ ĐIỆN THOẠI", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                onChanged: (value) async {
                                  String phone = value.trim();
                                  if (phone.length == 10) {
                                    setDialogState(() {
                                      isCheckingPhone = true;
                                      phoneError = "";
                                      foundUserName = "";
                                      foundUserId = null;
                                      foundUserPhotoUrl = null;
                                    });
                                    try {
                                      var snapshot = await FirebaseFirestore.instance
                                          .collection('users')
                                          .where('phoneNumber', isEqualTo: phone)
                                          .limit(1)
                                          .get();
                                      
                                      if (snapshot.docs.isEmpty) {
                                        snapshot = await FirebaseFirestore.instance
                                            .collection('users')
                                            .where('phone', isEqualTo: phone)
                                            .limit(1)
                                            .get();
                                      }

                                      if (snapshot.docs.isNotEmpty) {
                                        var userData = snapshot.docs.first.data();
                                        setDialogState(() {
                                          foundUserName = userData['fullName'] ?? 'Chưa đặt tên';
                                          foundUserId = snapshot.docs.first.id;
                                          foundUserPhotoUrl = userData['photoUrl'] ?? 'https://i.pravatar.cc/150?u=${snapshot.docs.first.id}';
                                          isCheckingPhone = false;
                                        });
                                      } else {
                                        setDialogState(() {
                                          phoneError = "Không tìm thấy số điện thoại trong hệ thống";
                                          isCheckingPhone = false;
                                        });
                                      }
                                    } catch (e) {
                                      setDialogState(() {
                                        phoneError = "Lỗi kiểm tra: $e";
                                        isCheckingPhone = false;
                                      });
                                    }
                                  } else {
                                    setDialogState(() {
                                      foundUserName = "";
                                      foundUserId = null;
                                      foundUserPhotoUrl = null;
                                      phoneError = "";
                                    });
                                  }
                                },
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  hintText: "VD: 0987654321",
                                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            if (isCheckingPhone)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(color: Color(0xFFD0FD3E), strokeWidth: 2),
                              )
                            else if (foundUserId != null)
                              const Icon(Icons.check_circle, color: Color(0xFFD0FD3E), size: 20)
                            else if (phoneError.isNotEmpty)
                              const Icon(Icons.error, color: Colors.redAccent, size: 20),
                          ],
                        ),
                      ),
                      if (phoneError.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(phoneError, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
                      ],
                      const SizedBox(height: 15),

                      // Tên học viên (Chỉ đọc)
                      const Text("HỌ VÀ TÊN", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Text(
                          foundUserName.isNotEmpty ? foundUserName : "Nhập số điện thoại để tra cứu...",
                          style: TextStyle(
                            color: foundUserName.isNotEmpty ? Colors.white : Colors.grey,
                            fontSize: 14,
                            fontWeight: foundUserName.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
  
                      // Mục tiêu Dropdown
                      const Text("MỤC TIÊU TẬP LUYỆN", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedGoal,
                            dropdownColor: const Color(0xFF1C1C1E),
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            items: const [
                              DropdownMenuItem(value: "Hypertrophy", child: Text("Tăng cơ (Hypertrophy)")),
                              DropdownMenuItem(value: "Mobility", child: Text("Linh hoạt (Mobility)")),
                              DropdownMenuItem(value: "Weight Loss", child: Text("Giảm cân (Weight Loss)")),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedGoal = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Thời gian tập Dropdown
                      const Text("THỜI GIAN TẬP (THÁNG)", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedMonths,
                            dropdownColor: const Color(0xFF1C1C1E),
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            items: List.generate(12, (index) {
                              int month = index + 1;
                              return DropdownMenuItem(
                                value: month,
                                child: Text("$month tháng"),
                              );
                            }),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedMonths = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Số tiền thanh toán (Tự gõ, dấu phẩy phân tách)
                      const Text("SỐ TIỀN THANH TOÁN (VNĐ)", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            ThousandSeparatorFormatter(),
                          ],
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            hintText: "VD: 1,500,000",
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
  
                      // Nút xác nhận
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("HỦY BỎ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: foundUserId == null || isCheckingPhone
                                  ? null
                                  : () async {
                                      String phone = phoneController.text.trim();
                                      String priceText = priceController.text.replaceAll(',', '').trim();
                                      double amount = double.tryParse(priceText) ?? 0.0;

                                      if (amount <= 0) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Vui lòng nhập số tiền thanh toán hợp lệ")),
                                        );
                                        return;
                                      }

                                      String goalCode = "HYPERTROPHY";
                                      if (selectedGoal == "Mobility") goalCode = "MOBILITY";
                                      if (selectedGoal == "Weight Loss") goalCode = "WEIGHT LOSS";

                                      DateTime startedAt = DateTime.now();
                                      DateTime endAt = DateTime(startedAt.year, startedAt.month + selectedMonths, startedAt.day, startedAt.hour, startedAt.minute);

                                      // 1. Thêm vào collection students
                                      await FirebaseFirestore.instance.collection('students').add({
                                        'ptId': ptId,
                                        'memberId': foundUserId,
                                        'name': foundUserName,
                                        'goal': goalCode,
                                        'lastSession': 'Chưa dạy',
                                        'photoUrl': foundUserPhotoUrl ?? 'https://i.pravatar.cc/150?u=$foundUserId',
                                        'phone': phone,
                                        'amount': amount,
                                        'remainingSessions': selectedMonths * 4,
                                        'createdAt': FieldValue.serverTimestamp(),
                                        'startedAt': Timestamp.fromDate(startedAt),
                                        'endAt': Timestamp.fromDate(endAt),
                                      });
  
                                      // 2. Thêm hoạt động hoạt động pt_activities
                                      await FirebaseFirestore.instance.collection('pt_activities').add({
                                        'ptId': ptId,
                                        'type': 'booking',
                                        'title': 'Gán học viên mới',
                                        'subtitle': 'Đã nhận huấn luyện học viên $foundUserName mục tiêu $selectedGoal ($selectedMonths tháng)',
                                        'timestamp': FieldValue.serverTimestamp(),
                                      });
  
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: const Color(0xFFD0FD3E),
                                            content: Text("Đã thêm thành công học viên $foundUserName!", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD0FD3E),
                                foregroundColor: Colors.black,
                                disabledBackgroundColor: Colors.white12,
                                disabledForegroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text("THÊM MỚI", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }



  // Dialog gửi tin nhắn nhanh động viên học viên
  void _showSendMessageDialog(String ptId, String studentName) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white12),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("NHẮN TIN KHÍCH LỆ", style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 12, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Gửi lời nhắn tới $studentName", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: messageController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: "Hôm nay tập rất tốt nhé! Về nhà nhớ bổ sung protein và uống đủ nước nha...",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        String message = messageController.text.trim();
                        if (message.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Vui lòng nhập nội dung tin nhắn")),
                          );
                          return;
                        }
  
                        // 1. Tạo bản ghi tin nhắn pt_messages
                        await FirebaseFirestore.instance.collection('pt_messages').add({
                          'ptId': ptId,
                          'studentName': studentName,
                          'message': message,
                          'timestamp': FieldValue.serverTimestamp(),
                          'status': 'sent',
                        });
  
                        // 2. Tạo hoạt động pt_activities
                        await FirebaseFirestore.instance.collection('pt_activities').add({
                          'ptId': ptId,
                          'type': 'note',
                          'title': 'Gửi tin nhắn khích lệ',
                          'subtitle': 'Lời nhắn tới $studentName: "$message"',
                          'timestamp': FieldValue.serverTimestamp(),
                        });
  
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.green,
                              content: Text("Đã gửi tin nhắn động viên học viên thành công!"),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD0FD3E),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("GỬI TIN NHẮN", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBookScheduleBottomSheet(String ptId, String studentName, String studentUid) {
    DateTime selectedDate = DateTime.now();
    TimeSlot? selectedSlot;
    bool isSaving = false;
    bool isRecurring = false;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final days = List.generate(7, (index) => startOfDay.add(Duration(days: index)));

    String getDayName(DateTime date) {
      int weekday = date.weekday;
      if (weekday == 7) return "CN";
      return "T${weekday + 1}";
    }

    final schedulesStream = FirebaseFirestore.instance
        .collection('schedules')
        .where('staffUid', isEqualTo: ptId)
        .snapshots();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return StreamBuilder<QuerySnapshot>(
                  stream: schedulesStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      debugPrint("Firestore Stream Error: ${snapshot.error}");
                    }
                    final schedules = snapshot.data?.docs ?? [];

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, color: Color(0xFFD0FD3E), size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "ĐẶT LỊCH DẠY: $studentName",
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            "Chọn ngày và khung giờ tập luyện (Khung giờ kẹt lịch sẽ bị vô hiệu hóa)",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 20),

                          // Ngày ngang
                          SizedBox(
                            height: 75,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: days.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final date = days[index];
                                final isSelected = DateUtils.isSameDay(date, selectedDate);
                                final isToday = DateUtils.isSameDay(date, now);

                                return GestureDetector(
                                  onTap: () {
                                    setSheetState(() {
                                      selectedDate = date;
                                      selectedSlot = null; // Reset slot khi đổi ngày
                                    });
                                  },
                                  child: Container(
                                    width: 55,
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFD0FD3E) : const Color(0xFF2C2C2E),
                                      borderRadius: BorderRadius.circular(15),
                                      border: isToday && !isSelected
                                          ? Border.all(color: const Color(0xFFD0FD3E), width: 1.5)
                                          : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          getDayName(date),
                                          style: TextStyle(
                                            color: isSelected ? Colors.black : Colors.grey,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          date.day.toString(),
                                          style: TextStyle(
                                            color: isSelected ? Colors.black : Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Khung giờ
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPeriodSection("BUỔI SÁNG", "Sáng", selectedDate, schedules, selectedSlot, (slot) {
                                    setSheetState(() {
                                      selectedSlot = slot;
                                    });
                                  }),
                                  const SizedBox(height: 20),
                                  _buildPeriodSection("BUỔI CHIỀU", "Chiều", selectedDate, schedules, selectedSlot, (slot) {
                                    setSheetState(() {
                                      selectedSlot = slot;
                                    });
                                  }),
                                  const SizedBox(height: 20),
                                  _buildPeriodSection("BUỔI TỐI", "Tối", selectedDate, schedules, selectedSlot, (slot) {
                                    setSheetState(() {
                                      selectedSlot = slot;
                                    });
                                  }),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ),

                          // Footer thông tin & nút Xác nhận
                          Container(
                            padding: const EdgeInsets.only(top: 15),
                            decoration: const BoxDecoration(
                              border: Border(top: BorderSide(color: Colors.white10, width: 1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "LOẠI LỊCH DẠY",
                                  style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setSheetState(() {
                                            isRecurring = false;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: !isRecurring ? const Color(0xFFD0FD3E) : const Color(0xFF2C2C2E),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Một lần",
                                              style: TextStyle(
                                                color: !isRecurring ? Colors.black : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setSheetState(() {
                                            isRecurring = true;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: isRecurring ? const Color(0xFFD0FD3E) : const Color(0xFF2C2C2E),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Cố định hàng tuần",
                                              style: TextStyle(
                                                color: isRecurring ? Colors.black : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                if (selectedSlot != null) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Lịch đã chọn:", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                      Text(
                                        "${DateFormat('dd/MM/yyyy').format(selectedDate)} • ${selectedSlot!.label}",
                                        style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                ],
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: selectedSlot == null || isSaving
                                        ? null
                                        : () async {
                                            setSheetState(() {
                                              isSaving = true;
                                            });

                                            try {
                                              // Lấy tên HLV
                                              final ptDoc = await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(ptId)
                                                  .get();
                                              final ptName = ptDoc.data()?['fullName'] ?? 'HLV';

                                              final slotStart = DateTime(
                                                selectedDate.year,
                                                selectedDate.month,
                                                selectedDate.day,
                                                selectedSlot!.startHour,
                                                selectedSlot!.startMinute,
                                              );
                                              final slotEnd = DateTime(
                                                selectedDate.year,
                                                selectedDate.month,
                                                selectedDate.day,
                                                selectedSlot!.endHour,
                                                selectedSlot!.endMinute,
                                              );

                                              final batch = FirebaseFirestore.instance.batch();
                                              final int count = isRecurring ? 10 : 1;
                                              for (int i = 0; i < count; i++) {
                                                DateTime start = slotStart.add(Duration(days: i * 7));
                                                DateTime end = slotEnd.add(Duration(days: i * 7));
                                                var docRef = FirebaseFirestore.instance.collection('schedules').doc();
                                                batch.set(docRef, {
                                                  'staffUid': ptId,
                                                  'staffName': ptName,
                                                  'studentUid': studentUid,
                                                  'studentName': studentName,
                                                  'task': 'Dạy học viên $studentName',
                                                  'startTime': Timestamp.fromDate(start),
                                                  'endTime': Timestamp.fromDate(end),
                                                  'status': 'pending',
                                                  'isRecurring': isRecurring,
                                                });
                                              }
                                              await batch.commit();

                                              // Log hoạt động
                                              await FirebaseFirestore.instance.collection('pt_activities').add({
                                                'ptId': ptId,
                                                'type': 'booking',
                                                'title': isRecurring ? 'Đặt lịch dạy cố định' : 'Đặt lịch dạy mới',
                                                'subtitle': isRecurring
                                                    ? 'Đã đặt ca dạy cố định hàng tuần (10 tuần) học viên $studentName lúc ${DateFormat('HH:mm').format(slotStart)}'
                                                    : 'Đã đặt ca dạy học viên $studentName lúc ${DateFormat('HH:mm').format(slotStart)} ngày ${DateFormat('dd/MM').format(slotStart)}',
                                                'timestamp': FieldValue.serverTimestamp(),
                                              });

                                              if (context.mounted) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: const Color(0xFFD0FD3E),
                                                    content: Text(
                                                      "Đặt lịch dạy học viên $studentName thành công!",
                                                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              setSheetState(() {
                                                isSaving = false;
                                              });
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Lỗi khi lưu lịch: $e"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD0FD3E),
                                      foregroundColor: Colors.black,
                                      disabledBackgroundColor: Colors.white12,
                                      disabledForegroundColor: Colors.grey,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: isSaving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                          )
                                        : const Text("XÁC NHẬN ĐẶT LỊCH", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPeriodSection(
    String title,
    String period,
    DateTime selectedDate,
    List<QueryDocumentSnapshot> schedules,
    TimeSlot? selectedSlot,
    Function(TimeSlot) onSelectSlot,
  ) {
    final periodSlots = _standardSlots.where((s) => s.period == period).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: periodSlots.length,
          itemBuilder: (context, index) {
            final slot = periodSlots[index];
            final slotStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, slot.startHour, slot.startMinute);
            final slotEnd = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, slot.endHour, slot.endMinute);

            final isPast = slotStart.isBefore(DateTime.now());

            final isBusy = schedules.any((doc) {
              var data = doc.data() as Map<String, dynamic>;
              if (data['startTime'] == null || data['endTime'] == null) return false;
              DateTime sStart = (data['startTime'] as Timestamp).toDate();
              DateTime sEnd = (data['endTime'] as Timestamp).toDate();
              return sStart.isBefore(slotEnd) && sEnd.isAfter(slotStart);
            });

            final isSelected = selectedSlot != null && selectedSlot.label == slot.label;

            Color bgColor = const Color(0xFF2C2C2E);
            Color textColor = Colors.white;
            Color borderColor = Colors.white12;
            String statusText = "Rảnh";
            Color statusColor = const Color(0xFFD0FD3E);

            if (isPast) {
              bgColor = const Color(0xFF1C1C1E);
              textColor = Colors.grey;
              borderColor = Colors.transparent;
              statusText = "Đã qua";
              statusColor = Colors.grey;
            } else if (isBusy) {
              bgColor = const Color(0xFF1C1C1E);
              textColor = Colors.grey;
              borderColor = Colors.transparent;
              statusText = "Kẹt lịch";
              statusColor = Colors.redAccent;
            } else if (isSelected) {
              bgColor = const Color(0xFFD0FD3E);
              textColor = Colors.black;
              borderColor = const Color(0xFFD0FD3E);
              statusText = "Đang chọn";
              statusColor = Colors.black87;
            }

            return GestureDetector(
              onTap: isPast || isBusy
                  ? null
                  : () {
                      onSelectSlot(slot);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.label,
                      style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

}

class TimeSlot {
  final String label;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String period;

  const TimeSlot({
    required this.label,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.period,
  });
}

const List<TimeSlot> _standardSlots = [
  // Sáng
  TimeSlot(label: "08:00 - 09:30", startHour: 8, startMinute: 0, endHour: 9, endMinute: 30, period: "Sáng"),
  TimeSlot(label: "09:30 - 11:00", startHour: 9, startMinute: 30, endHour: 11, endMinute: 0, period: "Sáng"),
  TimeSlot(label: "11:00 - 12:30", startHour: 11, startMinute: 0, endHour: 12, endMinute: 30, period: "Sáng"),
  
  // Chiều
  TimeSlot(label: "14:00 - 15:30", startHour: 14, startMinute: 0, endHour: 15, endMinute: 30, period: "Chiều"),
  TimeSlot(label: "15:30 - 17:00", startHour: 15, startMinute: 30, endHour: 17, endMinute: 0, period: "Chiều"),
  TimeSlot(label: "17:00 - 18:30", startHour: 17, startMinute: 0, endHour: 18, endMinute: 30, period: "Chiều"),
  
  // Tối
  TimeSlot(label: "18:30 - 20:00", startHour: 18, startMinute: 30, endHour: 20, endMinute: 0, period: "Tối"),
  TimeSlot(label: "20:00 - 21:30", startHour: 20, startMinute: 0, endHour: 21, endMinute: 30, period: "Tối"),
];

class ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }
    final numVal = int.tryParse(cleanText) ?? 0;
    String formatted = numVal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
