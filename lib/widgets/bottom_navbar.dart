import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/notification_screen.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (route) => false,
        );
        break;
      case 1:
        // TODO: Navigator ke TimelineScreen
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
        break;
      case 3:
        // TODO: Navigator ke ProfileScreen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFFEA8000),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Timeline'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notification'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
