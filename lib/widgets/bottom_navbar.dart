import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/timeline_screen.dart';
import '../screens/ai-chatbot_screen.dart';

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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TimelineScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiChatbotScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
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
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: 'Timeline',
        ),
        BottomNavigationBarItem(
          icon: Transform.translate(
            offset: const Offset(0, -4),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: currentIndex == 2
                    ? Border.all(color: const Color(0xFFEA8000), width: 2.5)
                    : null,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Image.asset(
                'Assets/images/DTC-AI Logo generate.jpg',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
          ),
          label: 'DTC AI',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: 'Notification',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
