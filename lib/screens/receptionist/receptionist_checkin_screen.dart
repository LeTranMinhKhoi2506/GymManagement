import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../PT/pt_dashboard_screen.dart'; // Import QRScannerDialog

class ReceptionistCheckInScreen extends StatefulWidget {
  const ReceptionistCheckInScreen({super.key});

  @override
  State<ReceptionistCheckInScreen> createState() => _ReceptionistCheckInScreenState();
}

class _ReceptionistCheckInScreenState extends State<ReceptionistCheckInScreen> {
  String _searchQuery = '';
  String _filterStatus = 'All'; // 'All', 'Active', 'Expired'
  final TextEditingController _searchController = TextEditingController();

  void _launchQRScanner(BuildContext context, Map<String, dynamic> memberData, String memberId) {
    String fullName = memberData['fullName'] ?? 'Khách hàng';
    String membershipType = memberData['membershipType'] ?? 'Standard';
    String currentStatus = memberData['status'] ?? 'Active';
    DateTime? nextRenewal = memberData['nextRenewal'] != null 
        ? (memberData['nextRenewal'] as Timestamp).toDate() 
        : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => QRScannerDialog(
        title: "QUÉT MÃ QR KHÁCH HÀNG",
        subtitle: "Đang quét mã thành viên của $fullName...",
        onSuccess: () async {
          final now = DateTime.now();
          bool isExpired = currentStatus != 'Active' || (nextRenewal != null && nextRenewal.isBefore(now));
          
          if (isExpired) {
            // Show expired dialog error
            _showStatusOverlay(
              success: false,
              title: "THẺ TẬP HẾT HẠN",
              message: "Khách hàng: $fullName\nGói tập: $membershipType đã hết hạn sử dụng hoặc bị khóa.",
            );
          } else {
            bool isTraining = memberData['isCurrentlyTraining'] ?? false;
            bool newTrainingState = !isTraining;

            // Update in Firestore
            await FirebaseFirestore.instance.collection('members').doc(memberId).update({
              'isCurrentlyTraining': newTrainingState,
            });

            // Log global check-in event for admin dashboard
            await FirebaseFirestore.instance.collection('checkins').add({
              'memberId': memberId,
              'userName': fullName,
              'timestamp': FieldValue.serverTimestamp(),
              'zone': newTrainingState ? 'Khu vực chính (Check-in)' : 'Khu vực chính (Check-out)',
            });

            // Log activity log inside member document
            await FirebaseFirestore.instance
                .collection('members')
                .doc(memberId)
                .collection('activity_logs')
                .add({
              'title': newTrainingState ? 'Check-in thành công' : 'Check-out thành công',
              'timestamp': FieldValue.serverTimestamp(),
              'amount': 0.0,
              'status': 'Paid',
              'type': 'Session',
            });

            // Show success overlay
            _showStatusOverlay(
              success: true,
              title: newTrainingState ? "CHECK-IN THÀNH CÔNG" : "CHECK-OUT THÀNH CÔNG",
              message: "Thành viên: $fullName\nGói: $membershipType\nTrạng thái: Cho phép vào phòng tập.",
            );
          }
        },
      ),
    );
  }

  void _quickRandomCheckin(BuildContext context) async {
    // Pick a random member from Firestore to simulate scanning
    final snapshot = await FirebaseFirestore.instance.collection('members').get();
    if (snapshot.docs.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không có thành viên nào trong cơ sở dữ liệu để quét.")),
      );
      return;
    }

    final randomIndex = Random().nextInt(snapshot.docs.length);
    final doc = snapshot.docs[randomIndex];
    final data = doc.data();

    if (!context.mounted) return;
    _launchQRScanner(context, data, doc.id);
  }

  void _showStatusOverlay({required bool success, required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: success ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                color: success ? Colors.greenAccent : Colors.redAccent,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: success ? Colors.greenAccent : Colors.redAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: success ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("XÁC NHẬN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "QUẢN LÝ CHECK-IN",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Quick QR Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _quickRandomCheckin(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            elevation: 5,
                          ),
                          icon: const Icon(Icons.qr_code_scanner, size: 22),
                          label: const Text(
                            "QUÉT QR NHANH (MÔ PHỎNG)",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search and Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm thành viên...",
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF1C1C1E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildFilterChip("Tất cả", "All"),
                          const SizedBox(width: 8),
                          _buildFilterChip("Đang tập", "Active"),
                          const SizedBox(width: 8),
                          _buildFilterChip("Hết hạn", "Expired"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Members List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('members').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("Chưa có thành viên nào trong danh sách.", style: TextStyle(color: Colors.grey)),
                        );
                      }

                      final now = DateTime.now();
                      var docs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final fullName = (data['fullName'] ?? '').toString().toLowerCase();
                        final email = (data['email'] ?? '').toString().toLowerCase();
                        final matchesSearch = fullName.contains(_searchQuery) || email.contains(_searchQuery);

                        final status = data['status'] ?? 'Active';
                        final isTraining = data['isCurrentlyTraining'] ?? false;
                        final nextRenewal = data['nextRenewal'] != null 
                            ? (data['nextRenewal'] as Timestamp).toDate() 
                            : null;
                        final isExpired = status != 'Active' || (nextRenewal != null && nextRenewal.isBefore(now));

                        if (_filterStatus == 'Active') {
                          return matchesSearch && isTraining;
                        } else if (_filterStatus == 'Expired') {
                          return matchesSearch && isExpired;
                        }
                        return matchesSearch;
                      }).toList();

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text("Không tìm thấy kết quả phù hợp.", style: TextStyle(color: Colors.grey)),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: docs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final fullName = data['fullName'] ?? 'Khách hàng';
                          final membershipType = data['membershipType'] ?? 'Standard';
                          final isTraining = data['isCurrentlyTraining'] ?? false;
                          final status = data['status'] ?? 'Active';
                          final nextRenewal = data['nextRenewal'] != null 
                              ? (data['nextRenewal'] as Timestamp).toDate() 
                              : null;
                          final isExpired = status != 'Active' || (nextRenewal != null && nextRenewal.isBefore(now));

                          return Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1E),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isTraining ? Colors.green.withValues(alpha: 0.15) : Colors.grey[900],
                                  child: Icon(
                                    isTraining ? Icons.login : Icons.person_outline,
                                    color: isTraining ? Colors.greenAccent : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fullName,
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Gói: $membershipType • HSD: ${nextRenewal != null ? DateFormat('dd/MM/yyyy').format(nextRenewal) : 'Vĩnh viễn'}",
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                      const SizedBox(height: 6),
                                      _buildStatusBadge(isExpired, isTraining),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.qr_code_2, color: Color(0xFFFF6B35), size: 26),
                                  onPressed: () => _launchQRScanner(context, data, doc.id),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isExpired, bool isTraining) {
    String label = "Chưa vào cửa";
    Color bg = Colors.grey.withValues(alpha: 0.1);
    Color fg = Colors.grey;

    if (isExpired) {
      label = "Thẻ hết hạn";
      bg = Colors.red.withValues(alpha: 0.1);
      fg = Colors.redAccent;
    } else if (isTraining) {
      label = "Đang trong phòng tập";
      bg = Colors.green.withValues(alpha: 0.1);
      fg = Colors.greenAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
