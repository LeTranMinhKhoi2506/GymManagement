import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';
import '../../common/styles/sidebar_widget.dart';
import '../../common/styles/header_widget.dart';
import '../../common/styles/summary_cards.dart';
import '../../common/styles/revenue_chart.dart';
import '../../common/styles/member_flow_chart.dart';
import '../../common/styles/recent_checkins_log.dart';
import '../../common/styles/upcoming_classes_stream.dart';
import '../../common/styles/equipment_status_stream.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminController>(context, listen: false).fetchDashboardStats());
  }

  @override
  Widget build(BuildContext context) {
    final adminController = Provider.of<AdminController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: adminController.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Row(
            children: [
              const SidebarWidget(),
              Expanded(
                child: Column(
                  children: [
                    const HeaderWidget(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SummaryCards(controller: adminController),
                            const SizedBox(height: 32),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: RevenueChart(data: adminController.monthlyRevenue)),
                                const SizedBox(width: 32),
                                Expanded(flex: 1, child: MemberFlowChart(controller: adminController)),
                              ],
                            ),
                            const SizedBox(height: 32),
                            UpcomingClassesStream(controller: adminController),
                            const SizedBox(height: 32),
                            RecentCheckinsLog(controller: adminController),
                            const SizedBox(height: 32),
                            EquipmentStatusStream(controller: adminController),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
