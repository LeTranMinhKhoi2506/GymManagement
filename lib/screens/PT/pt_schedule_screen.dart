import 'package:flutter/material.dart';
import '../../app/route/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PtScheduleScreen extends StatelessWidget {
  const PtScheduleScreen({super.key});

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
                "SCHEDULE",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                "MAY 2024 • TRAINING CYCLE ALPHA",
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildHorizontalCalendar(),
              const SizedBox(height: 30),
              
              // Firebase connection example: Fetching sessions
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('pt_sessions').orderBy('time').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Text("Error loading data", style: TextStyle(color: Colors.red));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    // Placeholder data if Firebase is empty
                    return Column(
                      children: [
                        _buildTimelineSession(
                          time: "09:00\nAM",
                          name: "Sarah Jenkins",
                          category: "HYPERTROPHY",
                          status: "COMPLETED",
                          statusColor: Colors.grey,
                          actionText: "VIEW SUMMARY",
                          isCurrent: false,
                        ),
                        _buildTimelineSession(
                          time: "11:30\nAM",
                          name: "Marcus Thorne",
                          category: "VO2 MAX",
                          status: "IN PROGRESS",
                          statusColor: const Color(0xFFD0FD3E),
                          actionText: "RESUME SESSION",
                          isCurrent: true,
                        ),
                        _buildTimelineSession(
                          time: "02:00\nPM",
                          name: "Elena Rossi",
                          category: "BODY RECOMP",
                          status: "UPCOMING",
                          statusColor: Colors.orangeAccent,
                          actionText: "CHECK-IN",
                          isCurrent: false,
                          hasTrailingIcon: true,
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      return _buildTimelineSession(
                        time: data['time'] ?? "--:--",
                        name: data['studentName'] ?? "Unknown",
                        category: data['category'] ?? "General",
                        status: data['status'] ?? "UPCOMING",
                        statusColor: _getStatusColor(data['status']),
                        actionText: data['actionText'] ?? "CHECK-IN",
                        isCurrent: data['status'] == "IN PROGRESS",
                      );
                    }).toList(),
                  );
                },
              ),
              
              const SizedBox(height: 30),
              _buildQuoteSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "COMPLETED": return Colors.grey;
      case "IN PROGRESS": return const Color(0xFFD0FD3E);
      case "UPCOMING": return Colors.orangeAccent;
      default: return Colors.blueAccent;
    }
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

  Widget _buildHorizontalCalendar() {
    final days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
    final dates = ["13", "14", "15", "16", "17", "18", "19"];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildDateItem(days[index], dates[index], index == 2), // Wed 15 is selected
          );
        }),
      ),
    );
  }

  Widget _buildDateItem(String day, String date, bool isSelected) {
    return Container(
      width: 65,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD0FD3E) : const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
          ]
        ],
      ),
    );
  }

  Widget _buildTimelineSession({
    required String time,
    required String name,
    required String category,
    required String status,
    required Color statusColor,
    required String actionText,
    required bool isCurrent,
    bool hasTrailingIcon = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 55,
            child: Column(
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isCurrent ? const Color(0xFFD0FD3E) : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: Container(
                    width: 1,
                    color: Colors.grey.withOpacity(0.3),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(20),
                border: isCurrent ? Border.all(color: const Color(0xFFD0FD3E).withOpacity(0.3), width: 1) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(category, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                            const SizedBox(width: 5),
                            Text(status, style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold)),
                          ],
                        ),
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
                            backgroundColor: isCurrent ? const Color(0xFFD0FD3E) : const Color(0xFF2C2C2E),
                            foregroundColor: isCurrent ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: Text(actionText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      if (hasTrailingIcon) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.visibility_outlined, color: Colors.white, size: 20),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: Colors.orangeAccent, size: 40),
          const SizedBox(height: 10),
          const Text(
            "\"The human body is the only machine that breaks down if it isn't used.\"",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          const Text(
            "— COACH NOTES ALPHA",
            style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.fitness_center, color: Colors.grey.withOpacity(0.2), size: 60),
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
        currentIndex: 1, // Schedule index
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, Routes.ptDashboard);
          if (index == 2) Navigator.pushReplacementNamed(context, Routes.ptStudentManagement);
          if (index == 3) Navigator.pushReplacementNamed(context, Routes.ptIncome);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: "SCHEDULE"),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "STUDENTS"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "ACCOUNT"),
        ],
      ),
    );
  }
}
