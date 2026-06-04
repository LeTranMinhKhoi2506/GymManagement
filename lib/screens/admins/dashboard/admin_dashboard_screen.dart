import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/admin_controller.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/summary_cards.dart';
import '../../../common/widgets/admin_dashboard_widgets/revenue_chart.dart';
import '../../../common/widgets/admin_dashboard_widgets/member_flow_chart.dart';
import '../../../common/widgets/admin_dashboard_widgets/recent_checkins_log.dart';
import '../../../common/widgets/admin_dashboard_widgets/upcoming_classes_stream.dart';
import '../../../common/widgets/admin_dashboard_widgets/equipment_status_stream.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<AdminController>(context, listen: false).fetchDashboardStats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminController = Provider.of<AdminController>(context);

    if (adminController.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text("Lỗi hệ thống: ${adminController.errorMessage!}")),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          adminController.clearError();
        }
      });
    }

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
                                Expanded(
                                  flex: 2, 
                                  child: StreamBuilder(
                                    stream: adminController.paymentsUpdateStream,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.active) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          adminController.refreshData();
                                        });
                                      }
                                      return RevenueChart(controller: adminController);
                                    },
                                  )
                                ),
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
