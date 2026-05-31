import 'package:flutter/material.dart';

class PtIncomeScreen extends StatelessWidget {
  const PtIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              const Text(
                "EARNINGS REPORT",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                "OCTOBER",
                style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildTotalCommissionCard(),
              const SizedBox(height: 15),
              _buildSecondaryStatsRow(),
              const SizedBox(height: 30),
              _buildWeeklyMomentumSection(),
              const SizedBox(height: 30),
              _buildSectionHeader("RECENT PAYOUTS", () {}),
              const SizedBox(height: 15),
              _buildRecentPayoutsList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=pt_marcus'),
            ),
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
    );
  }

  Widget _buildTotalCommissionCard() {
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
            children: const [
              Text(
                "TOTAL COMMISSION",
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "\$8,420",
                style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Icon(Icons.account_balance_wallet_outlined, color: Colors.grey.withOpacity(0.2), size: 60),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox("SESSIONS", "142", "+12%", const Color(0xFFD0FD3E)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatBox("BONUSES", "\$1,200", null, Colors.orangeAccent, showLeftBar: true),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  if (percentage != null) ...[
                    const SizedBox(width: 5),
                    Text(percentage, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                  ]
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyMomentumSection() {
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
                  Text("WEEKLY MOMENTUM", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text("Mon 21 - Sun 27", style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
              const Text(
                "PEAK PERFORMANCE",
                style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildMiniChart(),
        ],
      ),
    );
  }

  Widget _buildMiniChart() {
    final days = ["M", "T", "W", "T", "F", "S", "S"];
    final heights = [0.4, 0.6, 0.3, 0.8, 0.5, 0.9, 0.7];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        bool isWednesday = index == 2;
        return Column(
          children: [
            Container(
              width: 8,
              height: 100 * heights[index],
              decoration: BoxDecoration(
                color: isWednesday ? const Color(0xFFD0FD3E) : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              days[index],
              style: TextStyle(
                color: index >= 5 ? Colors.orangeAccent : (isWednesday ? Colors.white : Colors.grey),
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
            "VIEW ALL",
            style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPayoutsList() {
    return Column(
      children: [
        _buildPayoutItem(
          icon: Icons.account_balance_wallet,
          title: "Monthly Base Payout",
          date: "Oct 28, 2023 • Bank Transfer",
          amount: "+\$5,200.00",
          status: "COMPLETED",
          statusColor: const Color(0xFFD0FD3E),
        ),
        const SizedBox(height: 15),
        _buildPayoutItem(
          icon: Icons.fitness_center,
          title: "Personal Training (12 Sessions)",
          date: "Oct 26, 2023 • Student Group A",
          amount: "+\$1,440.00",
          status: "PENDING",
          statusColor: Colors.grey,
        ),
        const SizedBox(height: 15),
        _buildPayoutItem(
          icon: Icons.star,
          title: "Retention Bonus",
          date: "Oct 24, 2023 • Milestone 3",
          amount: "+\$800.00",
          status: "COMPLETED",
          statusColor: const Color(0xFFD0FD3E),
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
            child: Icon(icon, color: status == "PENDING" ? const Color(0xFFD0FD3E) : Colors.orangeAccent, size: 20),
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

  Widget _buildBottomNav() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD0FD3E),
        unselectedItemColor: Colors.grey,
        currentIndex: 3, // Account/Earnings index
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "SCHEDULE"),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "STUDENTS"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "ACCOUNT"),
        ],
      ),
    );
  }
}
