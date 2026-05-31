import 'package:flutter/material.dart';
import '../../app/route/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PtDashboardScreen extends StatelessWidget {
  const PtDashboardScreen({super.key});

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
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildGreeting(),
              const SizedBox(height: 30),
              _buildStatsRow(),
              const SizedBox(height: 15),
              _buildEarningsCard(),
              const SizedBox(height: 30),
              _buildSectionTitle("OPERATIONAL PROTOCOL"),
              const SizedBox(height: 15),
              _buildOperationalProtocol(),
              const SizedBox(height: 30),
              _buildSectionTitle("MANAGEMENT HUB"),
              const SizedBox(height: 15),
              _buildMyScheduleCard(context),
              const SizedBox(height: 15),
              _buildHubSecondaryRow(context),
              const SizedBox(height: 30),
              _buildSectionHeader("RECENT ACTIVITY", () {}),
              const SizedBox(height: 15),
              _buildRecentActivityList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
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

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1),
            children: [
              TextSpan(text: "Xin chào,\n", style: TextStyle(color: Colors.white)),
              TextSpan(text: "Marcus Thorne", style: TextStyle(color: Color(0xFFD0FD3E))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Your engine is primed. 6 sessions locked in for today.",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallStatCard(
            icon: Icons.bolt,
            value: "6",
            label: "TODAY'S SESSIONS",
            iconColor: Color(0xFFD0FD3E),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildSmallStatCard(
            icon: Icons.people_outline,
            value: "12",
            label: "ACTIVE STUDENTS",
            iconColor: Colors.orangeAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard({required IconData icon, required String value, required String label, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 20),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD0FD3E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.black, size: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "+ 12% VS LW",
                  style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "\$145",
            style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Text(
            "TODAY'S EARNINGS",
            style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
    );
  }

  Widget _buildOperationalProtocol() {
    return Row(
      children: [
        Expanded(
          child: _buildProtocolButton(Icons.timer_outlined, "CLOCK IN", Colors.white),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildProtocolButton(Icons.person_search_outlined, "ATTENDANCE", Colors.orangeAccent),
        ),
      ],
    );
  }

  Widget _buildProtocolButton(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMyScheduleCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.ptSchedule),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("My Schedule", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Next session in 45 mins", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Icon(Icons.calendar_month, color: Color(0xFFD0FD3E), size: 30),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildAvatarStack(),
                const SizedBox(width: 10),
                const Text("+4", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Align(
          widthFactor: 0.6,
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.black,
            child: CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=student$index'),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHubSecondaryRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildHubCard(
            icon: Icons.person_search,
            title: "Student\nRoster",
            subtitle: "VIEW & MANAGE",
            iconColor: Colors.orangeAccent,
            onTap: () => Navigator.pushNamed(context, Routes.ptStudentManagement),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildHubCard(
            icon: Icons.bar_chart,
            title: "Earnings\nReport",
            subtitle: "MONTHLY INSIGHTS",
            iconColor: Colors.yellowAccent,
            onTap: () => Navigator.pushNamed(context, Routes.ptIncome),
          ),
        ),
      ],
    );
  }

  Widget _buildHubCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
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

  Widget _buildRecentActivityList() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const Divider(color: Colors.black, height: 1),
        itemBuilder: (context, index) {
          final items = [
            _ActivityItem(Icons.edit_note, "Note added for Elena S.", "Focus on eccentric tempo for squats...", "14:20", const Color(0xFFD0FD3E)),
            _ActivityItem(Icons.check_circle_outline, "Session Completed", "David Miller • Heavy Push Day", "12:45", Colors.orangeAccent),
            _ActivityItem(Icons.assignment_turned_in_outlined, "New Booking Request", "Marcus V. requested Tuesday at 08:00", "09:12", Colors.yellowAccent),
          ];
          final item = items[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text(item.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            trailing: Text(item.time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          );
        },
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
        currentIndex: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) {
          if (index == 1) Navigator.pushReplacementNamed(context, Routes.ptSchedule);
          if (index == 2) Navigator.pushReplacementNamed(context, Routes.ptStudentManagement);
          if (index == 3) Navigator.pushReplacementNamed(context, Routes.ptIncome);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "SCHEDULE"),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "STUDENTS"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "ACCOUNT"),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  _ActivityItem(this.icon, this.title, this.subtitle, this.time, this.color);
}
