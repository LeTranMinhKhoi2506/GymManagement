import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../app/route/routes.dart';
import '../../controllers/auth_controller.dart';

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

                      return _buildStudentCard(
                        name: name,
                        category: goal,
                        lastSession: data['lastSession'] ?? "Chưa có",
                        imageUrl: data['photoUrl'] ?? 'https://i.pravatar.cc/150?u=${doc.id}',
                        categoryColor: _getGoalColor(goal),
                        ptId: ptId,
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
          Row(
            children: [
              const Icon(Icons.notifications_none, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 26),
                onPressed: () async {
                  await context.read<AuthController>().signOut();
                  if (context.mounted) {
                    context.go(Routes.login);
                  }
                },
              ),
            ],
          ),
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
    required String name,
    required String category,
    required String lastSession,
    required String imageUrl,
    required Color categoryColor,
    required String ptId,
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
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showStudentProgressBottomSheet(ptId, name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text("Xem tiến độ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showSendMessageDialog(ptId, name),
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

  // Đối thoại (Dialog) thêm học viên mới
  void _showAddStudentDialog(String ptId) {
    String selectedGoal = "Hypertrophy";
    Map<String, dynamic>? selectedMemberData;
    String? selectedMemberDocId;

    showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('membership_plans').where('hasPT', isEqualTo: true).snapshots(),
          builder: (context, plansSnapshot) {
            if (plansSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)));
            }

            final ptPlans = plansSnapshot.data?.docs.map((doc) => doc.data() as Map<String, dynamic>).toList() ?? [];
            final ptPlanNames = ptPlans.map((p) => (p['name'] ?? '').toString()).where((n) => n.isNotEmpty).toList();

            if (ptPlanNames.isEmpty) {
              return AlertDialog(
                backgroundColor: const Color(0xFF1C1C1E),
                title: const Text("LỖI HỆ THỐNG", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                content: const Text("Chưa có gói tập kèm PT nào được cấu hình trong hệ thống.", style: TextStyle(color: Colors.white)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("ĐỒNG Ý", style: TextStyle(color: Color(0xFFD0FD3E)))),
                ],
              );
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('members').where('status', isEqualTo: 'Active').snapshots(),
              builder: (context, membersSnapshot) {
                if (membersSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)));
                }

                final validMembers = membersSnapshot.data?.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final mType = (data['membershipType'] ?? '').toString();
                  return ptPlanNames.contains(mType);
                }).toList() ?? [];

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

                              if (validMembers.isEmpty) ...[
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Text(
                                      "Không có thành viên nào đang sở hữu gói tập kèm PT hoạt động trong hệ thống.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("ĐỒNG Ý", style: TextStyle(color: Color(0xFFD0FD3E))),
                                    )
                                  ],
                                )
                              ] else ...[
                                const Text("CHỌN HỘI VIÊN (ĐÃ MUA GÓI PT)", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedMemberDocId,
                                      dropdownColor: const Color(0xFF1C1C1E),
                                      isExpanded: true,
                                      hint: const Text("Chọn hội viên...", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                      items: validMembers.map((doc) {
                                        final data = doc.data() as Map<String, dynamic>;
                                        final name = data['fullName'] ?? 'Không tên';
                                        final mType = data['membershipType'] ?? 'Gói';
                                        return DropdownMenuItem<String>(
                                          value: doc.id,
                                          child: Text("$name ($mType)"),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          final chosenDoc = validMembers.firstWhere((d) => d.id == value);
                                          setDialogState(() {
                                            selectedMemberDocId = value;
                                            selectedMemberData = chosenDoc.data() as Map<String, dynamic>;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                if (selectedMemberData != null) ...[
                                  const Text("SỐ ĐIỆN THOẠI", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                                    child: Text(
                                      selectedMemberData!['phoneNumber'] ?? "Chưa cập nhật SĐT",
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                ],

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
                                const SizedBox(height: 30),

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
                                        onPressed: () async {
                                          if (selectedMemberDocId == null || selectedMemberData == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Vui lòng chọn hội viên")),
                                            );
                                            return;
                                          }

                                          final name = selectedMemberData!['fullName'] ?? "Học viên";
                                          final phone = selectedMemberData!['phoneNumber'] ?? "";

                                          String goalCode = "HYPERTROPHY";
                                          if (selectedGoal == "Mobility") goalCode = "MOBILITY";
                                          if (selectedGoal == "Weight Loss") goalCode = "WEIGHT LOSS";

                                          String randomId = DateTime.now().millisecondsSinceEpoch.toString();

                                          await FirebaseFirestore.instance.collection('students').add({
                                            'ptId': ptId,
                                            'name': name,
                                            'goal': goalCode,
                                            'lastSession': 'Chưa dạy',
                                            'photoUrl': selectedMemberData!['profileImageUrl'] ?? 'https://i.pravatar.cc/150?u=$randomId',
                                            'phone': phone,
                                            'memberId': selectedMemberDocId,
                                            'createdAt': FieldValue.serverTimestamp(),
                                          });

                                          await FirebaseFirestore.instance.collection('pt_activities').add({
                                            'ptId': ptId,
                                            'type': 'booking',
                                            'title': 'Gán học viên mới',
                                            'subtitle': 'Đã nhận huấn luyện học viên $name mục tiêu $selectedGoal',
                                            'timestamp': FieldValue.serverTimestamp(),
                                          });

                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: const Color(0xFFD0FD3E),
                                                content: Text("Đã thêm thành công học viên $name!", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFD0FD3E),
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: const Text("THÊM MỚI", style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                )
                              ]
                            ],
                          ),
                        ),
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

  // Hiển thị Bottom Sheet lịch sử tiến độ / Nhật ký tập của học viên
  void _showStudentProgressBottomSheet(String ptId, String studentName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "TIẾN ĐỘ TẬP LUYỆN: $studentName",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                "Theo dõi nhật ký buổi dạy & chỉ số cơ thể của học viên",
                                style: TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddProgressDialog(ptId, studentName),
                          icon: const Icon(Icons.add, size: 14, color: Colors.black),
                          label: const Text("Đo chỉ số", style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD0FD3E),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // TabBar
                    const TabBar(
                      labelColor: Color(0xFFD0FD3E),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Color(0xFFD0FD3E),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(icon: Icon(Icons.history_edu, size: 18), text: "NHẬT KÝ BUỔI DẠY"),
                        Tab(icon: Icon(Icons.analytics_outlined, size: 18), text: "CHỈ SỐ CƠ THỂ"),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // TabBarView
                    Expanded(
                      child: TabBarView(
                        children: [
                          // TAB 1: NHẬT KÝ BUỔI DẠY (pt_journals)
                          _buildJournalsTab(scrollController, ptId, studentName),
                          
                          // TAB 2: CHỈ SỐ CƠ THỂ (pt_progress)
                          _buildBodyStatsTab(scrollController, ptId, studentName),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildJournalsTab(ScrollController scrollController, String ptId, String studentName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pt_journals')
          .where('ptId', isEqualTo: ptId)
          .where('studentName', isEqualTo: studentName)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Lỗi tải tiến độ học tập: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.history, color: Colors.grey, size: 40),
                SizedBox(height: 10),
                Text("Chưa có nhật ký ghi chép buổi tập nào.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text("Hãy bắt đầu dạy và hoàn thành ca để tạo ghi chép đầu tiên!", style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          );
        }

        // Sắp xếp các tài liệu cục bộ theo timestamp giảm dần (descending)
        final docs = List<QueryDocumentSnapshot>.from(snapshot.data!.docs);
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['timestamp'] != null ? (aData['timestamp'] as Timestamp).toDate() : DateTime(1970);
          final bTime = bData['timestamp'] != null ? (bData['timestamp'] as Timestamp).toDate() : DateTime(1970);
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          controller: scrollController,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var doc = docs[index];
            var data = doc.data() as Map<String, dynamic>;
            DateTime time = data['timestamp'] != null 
                ? (data['timestamp'] as Timestamp).toDate() 
                : DateTime.now();
            String dateStr = DateFormat('dd/MM/yyyy • HH:mm').format(time);

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Buổi học # ${snapshot.data!.docs.length - index}",
                        style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text("TRỌNG TÂM BUỔI TẬP", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                  Text(data['focus'] ?? "Chưa ghi nhận", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  const Text("NHẬT KÝ PT GHI CHÚ", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                  Text(
                    data['notes'] ?? "Không có ghi chú", 
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBodyStatsTab(ScrollController scrollController, String ptId, String studentName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pt_progress')
          .where('ptId', isEqualTo: ptId)
          .where('studentName', isEqualTo: studentName)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Lỗi tải chỉ số cơ thể: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.analytics_outlined, color: Colors.grey, size: 40),
                SizedBox(height: 10),
                Text("Chưa có chỉ số cơ thể nào.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text("Hãy đo đạc và nhập chỉ số đầu tiên để theo dõi tiến trình!", style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          );
        }

        // Sắp xếp các tài liệu cục bộ theo timestamp tăng dần (ascending) cho biểu đồ
        final docs = List<QueryDocumentSnapshot>.from(snapshot.data!.docs);
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['timestamp'] != null ? (aData['timestamp'] as Timestamp).toDate() : DateTime(1970);
          final bTime = bData['timestamp'] != null ? (bData['timestamp'] as Timestamp).toDate() : DateTime(1970);
          return aTime.compareTo(bTime);
        });

        final listData = docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        // Chuẩn bị dữ liệu vẽ biểu đồ cân nặng
        double maxWeight = 0;
        for (var data in listData) {
          double w = (data['weight'] as num?)?.toDouble() ?? 0;
          if (w > maxWeight) maxWeight = w;
        }

        return ListView(
          controller: scrollController,
          children: [
            // 1. Biểu đồ cột cân nặng trực quan
            const Text("TIẾN TRÌNH CÂN NẶNG (KG)", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 10),
            Container(
              height: 140,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(listData.length, (index) {
                  final data = listData[index];
                  double weight = (data['weight'] as num?)?.toDouble() ?? 0.0;
                  
                  DateTime time = data['timestamp'] != null 
                      ? (data['timestamp'] as Timestamp).toDate() 
                      : DateTime.now();
                  String dateLabel = DateFormat('dd/MM').format(time);

                  double ratio = maxWeight > 0 ? (weight / maxWeight) : 0.1;
                  double barHeight = (ratio * 70).clamp(10.0, 70.0);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        weight.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 14,
                        height: barHeight,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD0FD3E), Colors.greenAccent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dateLabel,
                        style: const TextStyle(color: Colors.grey, fontSize: 8),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Danh sách đo chi tiết
            const Text("LỊCH SỬ ĐO ĐẠC CHI TIẾT", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1.5),
                },
                children: [
                  // Table Header
                  const TableRow(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
                    ),
                    children: [
                      Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8), child: Text("Ngày đo", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8), child: Text("Cân nặng", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8), child: Text("Tỷ lệ mỡ", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8), child: Text("Khối cơ", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
                    ]
                  ),
                  // Table Rows
                  ...docs.reversed.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    double weight = (data['weight'] as num?)?.toDouble() ?? 0.0;
                    double fat = (data['bodyFat'] as num?)?.toDouble() ?? 0.0;
                    double muscle = (data['muscleMass'] as num?)?.toDouble() ?? 0.0;
                    
                    DateTime time = data['timestamp'] != null 
                        ? (data['timestamp'] as Timestamp).toDate() 
                        : DateTime.now();
                    String dateStr = DateFormat('dd/MM/yyyy').format(time);

                    return TableRow(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white12, width: 0.5)),
                      ),
                      children: [
                        Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8), child: Text(dateStr, style: const TextStyle(color: Colors.white70, fontSize: 11))),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8), child: Text("${weight.toStringAsFixed(1)} kg", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8), child: Text("${fat.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.orangeAccent, fontSize: 11))),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8), child: Text("${muscle.toStringAsFixed(1)} kg", style: const TextStyle(color: Colors.greenAccent, fontSize: 11))),
                      ]
                    );
                  })
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _showAddProgressDialog(String ptId, String studentName) {
    final TextEditingController weightController = TextEditingController();
    final TextEditingController fatController = TextEditingController();
    final TextEditingController muscleController = TextEditingController();

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
                      const Text("ĐO CHỈ SỐ CƠ THỂ", style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 12, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Cập nhật cho $studentName", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  const Text("CÂN NẶNG (KG)", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: "VD: 70.5",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  const Text("TỶ LỆ MỠ BODY FAT (%)", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: fatController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: "VD: 18.5",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  const Text("KHỐI LƯỢNG CƠ (KG)", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: muscleController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: "VD: 32.4",
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
                        String wStr = weightController.text.trim();
                        String fStr = fatController.text.trim();
                        String mStr = muscleController.text.trim();

                        double? w = double.tryParse(wStr);
                        double? f = double.tryParse(fStr);
                        double? m = double.tryParse(mStr);

                        if (w == null || f == null || m == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Vui lòng nhập đúng định dạng số hợp lệ cho các chỉ số")),
                          );
                          return;
                        }

                        // 1. Tạo bản ghi chỉ số cơ thể pt_progress
                        await FirebaseFirestore.instance.collection('pt_progress').add({
                          'ptId': ptId,
                          'studentName': studentName,
                          'weight': w,
                          'bodyFat': f,
                          'muscleMass': m,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        // 2. Tạo hoạt động pt_activities
                        await FirebaseFirestore.instance.collection('pt_activities').add({
                          'ptId': ptId,
                          'type': 'note',
                          'title': 'Cập nhật chỉ số cơ thể',
                          'subtitle': 'Học viên $studentName: Cân nặng ${w}kg, Mỡ $f%, Cơ ${m}kg',
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFFD0FD3E),
                              content: Text(
                                "Đã cập nhật thành công chỉ số cơ thể cho $studentName!",
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD0FD3E),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("CẬP NHẬT", style: TextStyle(fontWeight: FontWeight.bold)),
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

}
