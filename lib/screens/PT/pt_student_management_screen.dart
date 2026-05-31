import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../app/route/routes.dart';

class PtStudentManagementScreen extends StatelessWidget {
  const PtStudentManagementScreen({super.key});

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

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return _buildStudentCard(
                        name: data['name'] ?? "Học viên",
                        category: data['goal'] ?? "CHƯA XÁC ĐỊNH",
                        lastSession: data['lastSession'] ?? "Chưa có",
                        imageUrl: data['photoUrl'] ?? 'https://i.pravatar.cc/150?u=${snapshot.data!.docs[index].id}',
                        categoryColor: _getGoalColor(data['goal']),
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
        onPressed: () {
          // Navigator to add student or similar
        },
        backgroundColor: const Color(0xFFD0FD3E),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
      bottomNavigationBar: _buildBottomNav(context),
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
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey, size: 20),
          hintText: "Tìm kiếm học viên...",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
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
          bool isSelected = index == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepOrangeAccent : const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              categories[index],
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
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
                  border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
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
                  onPressed: () {},
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
                  onPressed: () {},
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

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD0FD3E),
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // Students index
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) {
          if (index == 0) context.go(Routes.ptDashboard);
          if (index == 1) context.go(Routes.ptSchedule);
          if (index == 3) context.go(Routes.ptIncome);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "TRANG CHỦ"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "LỊCH DẠY"),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: "HỌC VIÊN"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "TÀI KHOẢN"),
        ],
      ),
    );
  }
}
