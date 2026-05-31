import 'package:flutter/material.dart';
import '../../app/route/routes.dart';

class PtStudentManagementScreen extends StatelessWidget {
  const PtStudentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildStudentCard(
                    name: "Marcus Chen",
                    category: "HYPERTROPHY",
                    lastSession: "Oct 24, 2023",
                    imageUrl: "https://i.pravatar.cc/150?u=marcus_chen",
                    categoryColor: const Color(0xFFD0FD3E),
                  ),
                  _buildStudentCard(
                    name: "Sarah Jenkins",
                    category: "MOBILITY",
                    lastSession: "Oct 22, 2023",
                    imageUrl: "https://i.pravatar.cc/150?u=sarah_jenkins",
                    categoryColor: Colors.orangeAccent,
                  ),
                  _buildStudentCard(
                    name: "David Miller",
                    category: "WEIGHT LOSS",
                    lastSession: "Oct 19, 2023",
                    imageUrl: "https://i.pravatar.cc/150?u=david_miller",
                    categoryColor: Colors.deepOrangeAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFD0FD3E),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
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
          hintText: "Search students...",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = ["All", "Hypertrophy", "Mobility", "Weight Loss"];
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
                  child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
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
                  const Text("LAST SESSION", style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
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
                  child: const Text("View Progress", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                  child: const Text("Message", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
          if (index == 0) Navigator.pushReplacementNamed(context, Routes.ptDashboard);
          if (index == 1) Navigator.pushReplacementNamed(context, Routes.ptSchedule);
          if (index == 3) Navigator.pushReplacementNamed(context, Routes.ptIncome);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "SCHEDULE"),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: "STUDENTS"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "ACCOUNT"),
        ],
      ),
    );
  }
}
