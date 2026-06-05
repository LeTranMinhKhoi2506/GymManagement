import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../app/route/routes.dart';

class PtIncomeScreen extends StatelessWidget {
  const PtIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String ptId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 30),
              const Text(
                "BÁO CÁO THU NHẬP",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                "THÁNG HIỆN TẠI",
                style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              // Total Commission Card with Firebase
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pt_payouts')
                    .where('ptId', isEqualTo: ptId)
                    .snapshots(),
                builder: (context, snapshot) {
                  double totalCommission = 0;
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      totalCommission += (doc.data() as Map<String, dynamic>)['amount'] ?? 0.0;
                    }
                  }
                  return _buildTotalCommissionCard(totalCommission, currencyFormat);
                },
              ),
              
              const SizedBox(height: 15),
              
              // Secondary Stats (Sessions & Bonuses) - Hoàn toàn động
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pt_sessions')
                    .where('ptId', isEqualTo: ptId)
                    .where('status', isEqualTo: 'HOÀN THÀNH')
                    .snapshots(),
                builder: (context, sessionSnapshot) {
                  int sessionsCount = sessionSnapshot.hasData ? sessionSnapshot.data!.docs.length : 0;
                  
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('pt_payouts')
                        .where('ptId', isEqualTo: ptId)
                        .where('type', isEqualTo: 'bonus')
                        .snapshots(),
                    builder: (context, bonusSnapshot) {
                      double bonusSum = 0;
                      if (bonusSnapshot.hasData) {
                        for (var doc in bonusSnapshot.data!.docs) {
                          bonusSum += (doc.data() as Map<String, dynamic>)['amount'] ?? 0.0;
                        }
                      }
                      return _buildSecondaryStatsRow(sessionsCount.toString(), currencyFormat.format(bonusSum));
                    }
                  );
                },
              ),
              
              const SizedBox(height: 30),
              _buildWeeklyMomentumSection(ptId),
              const SizedBox(height: 30),
              _buildSectionHeader("CÁC KHOẢN THANH TOÁN GẦN ĐÂY", () {}),
              const SizedBox(height: 15),
              
              // Recent Payouts List with Firebase
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pt_payouts')
                    .where('ptId', isEqualTo: ptId)
                    .orderBy('timestamp', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Text("Lỗi tải dữ liệu", style: TextStyle(color: Colors.red));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Chưa có thanh toán nào", style: TextStyle(color: Colors.grey)));
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      DateTime date = data['timestamp'] != null 
                          ? (data['timestamp'] as Timestamp).toDate() 
                          : DateTime.now();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildPayoutItem(
                          icon: _getPayoutIcon(data['type']),
                          title: data['title'] ?? "Thanh toán",
                          date: "${DateFormat('dd/MM/yyyy').format(date)} • ${data['method'] ?? 'Chuyển khoản'}",
                          amount: "+${currencyFormat.format(data['amount'] ?? 0)}",
                          status: data['status'] ?? "HOÀN THÀNH",
                          statusColor: data['status'] == 'ĐANG CHỜ' ? Colors.grey : const Color(0xFFD0FD3E),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPayoutIcon(String? type) {
    switch (type) {
      case 'bonus': return Icons.star;
      case 'session': return Icons.fitness_center;
      default: return Icons.account_balance_wallet;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.go(Routes.login);
                }
              },
            ),
          ],
        ),
      ],
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

  Widget _buildTotalCommissionCard(double amount, NumberFormat formatter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TỔNG HOA HỒNG",
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                formatter.format(amount),
                style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Icon(Icons.account_balance_wallet_outlined, color: Colors.grey.withValues(alpha: 0.1), size: 60),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStatsRow(String sessions, String bonus) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox("SỐ CA DẠY", sessions, "+12%", const Color(0xFFD0FD3E)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatBox("TIỀN THƯỞNG", bonus, null, Colors.orangeAccent, showLeftBar: true),
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, String? percentage, Color color, {bool showLeftBar = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (showLeftBar)
            Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              margin: const EdgeInsets.only(right: 15),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    if (percentage != null) ...[
                      const SizedBox(width: 5),
                      Text(percentage, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tải dữ liệu thu nhập thực tế trong tuần để vẽ biểu đồ
  Widget _buildWeeklyMomentumSection(String ptId) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pt_payouts')
          .where('ptId', isEqualTo: ptId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeekDate))
          .snapshots(),
      builder: (context, snapshot) {
        List<double> weeklyEarnings = List.filled(7, 0.0);

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            if (data['timestamp'] != null && data['amount'] != null) {
              DateTime time = (data['timestamp'] as Timestamp).toDate();
              int dayIndex = time.weekday - 1; // 0 (Mon) -> 6 (Sun)
              if (dayIndex >= 0 && dayIndex < 7) {
                weeklyEarnings[dayIndex] += (data['amount'] as num).toDouble();
              }
            }
          }
        }

        double maxEarning = 0;
        for (var amount in weeklyEarnings) {
          if (amount > maxEarning) maxEarning = amount;
        }

        List<double> heights = List.filled(7, 0.0);
        for (int i = 0; i < 7; i++) {
          if (maxEarning > 0) {
            heights[i] = 0.1 + (weeklyEarnings[i] / maxEarning) * 0.8;
          } else {
            heights[i] = 0.15; // Mức mặc định cực nhỏ khi chưa có ca dạy
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("HIỆU SUẤT TUẦN", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text("Doanh thu tích lũy tuần này", style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                  Text(
                    maxEarning > 0 
                      ? "ĐỈNH: ${NumberFormat.compact(locale: 'vi_VN').format(maxEarning)}" 
                      : "KHÔNG CÓ DỮ LIỆU",
                    style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildMiniChart(weeklyEarnings, heights),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMiniChart(List<double> earnings, List<double> heights) {
    final days = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
    final formatter = NumberFormat.compact(locale: 'vi_VN');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        bool isToday = index == DateTime.now().weekday - 1;
        double amount = earnings[index];

        return Column(
          children: [
            if (amount > 0)
              Text(
                formatter.format(amount),
                style: const TextStyle(color: Colors.greenAccent, fontSize: 8, fontWeight: FontWeight.bold),
              )
            else
              const Text("", style: TextStyle(fontSize: 8)),
            const SizedBox(height: 5),
            Container(
              width: 8,
              height: 100 * heights[index],
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFFD0FD3E) : (amount > 0 ? Colors.greenAccent : Colors.grey.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              days[index],
              style: TextStyle(
                color: index >= 5 ? Colors.orangeAccent : (isToday ? Colors.white : Colors.grey),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            "XEM TẤT CẢ",
            style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutItem({
    required IconData icon,
    required String title,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: status == "ĐANG CHỜ" ? const Color(0xFFD0FD3E) : Colors.orangeAccent, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(status, style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

}
