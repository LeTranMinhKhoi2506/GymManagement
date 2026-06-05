import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app/route/routes.dart';
import '../../controllers/auth_controller.dart';
import '../PT/pt_dashboard_screen.dart'; // Import QRScannerDialog

class ReceptionistDashboardScreen extends StatefulWidget {
  const ReceptionistDashboardScreen({super.key});

  @override
  State<ReceptionistDashboardScreen> createState() => _ReceptionistDashboardScreenState();
}

class _ReceptionistDashboardScreenState extends State<ReceptionistDashboardScreen> {

  @override
  Widget build(BuildContext context) {
    // For rendering on Web & Android gracefully, wrap in a centered Container
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500), // Mobile-sized frame on web
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 25),
                  _buildGreeting(),
                  const SizedBox(height: 25),
                  
                  // Live Occupancy & Quick Check-in Card
                  _buildOccupancyAndCheckinRow(),
                  const SizedBox(height: 25),

                  _buildSectionTitle("TRUNG TÂM VẬN HÀNH & BÁN HÀNG"),
                  const SizedBox(height: 15),
                  _buildGridMenu(),
                  const SizedBox(height: 30),

                  _buildSectionTitle("HOẠT ĐỘNG GẦN ĐÂY"),
                  const SizedBox(height: 15),
                  _buildRecentCheckinsList(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[900],
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              "KINETIC RECEPTION",
              style: TextStyle(
                color: Color(0xFFFF6B35),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent, size: 24),
          onPressed: () async {
            await context.read<AuthController>().signOut();
            if (mounted) context.go(Routes.login);
          },
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final user = FirebaseAuth.instance.currentUser;
    String name = user?.displayName ?? "Lễ Tân";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
            children: [
              const TextSpan(text: "Xin chào,\n", style: TextStyle(color: Colors.white)),
              TextSpan(text: name, style: const TextStyle(color: Color(0xFFFF6B35))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Hệ thống trực ban lễ tân đã sẵn sàng. Chúc bạn một ngày làm việc hiệu quả.",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildOccupancyAndCheckinRow() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('members')
          .where('isCurrentlyTraining', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        int currentTrainees = snapshot.hasData ? snapshot.data!.docs.length : 0;
        int maxCapacity = 80;
        double occupancyRatio = currentTrainees / maxCapacity;
        String occupancyStatus = "Lưu lượng lý tưởng";
        Color occupancyColor = Colors.greenAccent;

        if (occupancyRatio > 0.8) {
          occupancyStatus = "Phòng tập khá đông";
          occupancyColor = Colors.orangeAccent;
        } else if (occupancyRatio > 0.95) {
          occupancyStatus = "Quá tải công suất";
          occupancyColor = Colors.redAccent;
        }

        return Column(
          children: [
            // Live Occupancy Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "LƯU LƯỢNG THỰC TẾ",
                          style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: "$currentTrainees ", style: const TextStyle(color: Colors.white)),
                              TextSpan(text: "/ $maxCapacity", style: const TextStyle(color: Colors.grey, fontSize: 18)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: occupancyColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              occupancyStatus,
                              style: TextStyle(color: occupancyColor, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.people_alt_outlined, color: Colors.white30, size: 50),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Entry Control Card (Quick Check-in Button)
            GestureDetector(
              onTap: () => context.go(Routes.receptionistCheckIn),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "KIỂM SOÁT RA VÀO",
                          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Quét mã QR Check-in",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGridMenu() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildMenuCard(
          icon: Icons.point_of_sale_rounded,
          title: "Bán hàng POS",
          subtitle: "Sản phẩm & Gói tập",
          color: Colors.orangeAccent,
          onTap: () => context.go(Routes.receptionistPOS),
        ),
        _buildMenuCard(
          icon: Icons.support_agent_rounded,
          title: "Hỗ trợ khách",
          subtitle: "Ý kiến & Sự cố",
          color: Colors.cyanAccent,
          onTap: () => context.go(Routes.receptionistSupport),
        ),
        _buildMenuCard(
          icon: Icons.fitness_center_rounded,
          title: "Cơ sở vật chất",
          subtitle: "Kiểm tra thiết bị",
          color: Colors.greenAccent,
          onTap: () => context.go(Routes.receptionistFacility),
        ),
        _buildMenuCard(
          icon: Icons.assignment_turned_in_rounded,
          title: "Check-in Hôm Nay",
          subtitle: "Lịch sử ra vào",
          color: Colors.purpleAccent,
          onTap: () => context.go(Routes.receptionistCheckIn),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildRecentCheckinsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('members')
          .orderBy('memberSince', descending: true) // Sort by recent activity
          .limit(4)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Chưa có hoạt động check-in nào.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String fullName = data['fullName'] ?? 'Khách hàng';
              String membershipType = data['membershipType'] ?? 'Standard';
              bool isTraining = data['isCurrentlyTraining'] ?? false;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isTraining ? Icons.login_rounded : Icons.logout_rounded,
                    color: isTraining ? Colors.greenAccent : Colors.grey,
                    size: 20,
                  ),
                ),
                title: Text(
                  fullName,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Gói tập: $membershipType",
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                trailing: Text(
                  isTraining ? "Đang tập" : "Đã về",
                  style: TextStyle(
                    color: isTraining ? Colors.greenAccent : Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

}
