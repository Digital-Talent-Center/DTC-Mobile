import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';
import '../services/api_client.dart';
import '../widgets/bottom_navbar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final int _selectedNavIndex = 2;

  bool _loading = true;
  String? _error;
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await NotificationService.instance.list();
      if (!mounted) return;
      setState(() {
        _notifications = data;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.firstError;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat notifikasi. Periksa koneksi server.';
        _loading = false;
      });
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _markAsRead(AppNotification n) async {
    if (n.isRead) return;
    // Optimistic update.
    setState(() {
      _notifications = _notifications
          .map((e) => e.id == n.id ? e.copyWith(isRead: true) : e)
          .toList();
    });
    try {
      await NotificationService.instance.markAsRead(n.id);
    } catch (_) {
      _snack('Gagal menandai sudah dibaca.');
      _load();
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.instance.markAllAsRead();
      setState(() {
        _notifications =
            _notifications.map((e) => e.copyWith(isRead: true)).toList();
      });
    } on ApiException catch (e) {
      _snack(e.firstError);
    } catch (_) {
      _snack('Gagal menandai semua sudah dibaca.');
    }
  }

  Future<void> _clearAll() async {
    final toDelete = List<AppNotification>.from(_notifications);
    setState(() => _notifications = []);
    try {
      for (final n in toDelete) {
        await NotificationService.instance.delete(n.id);
      }
    } catch (_) {
      _snack('Sebagian notifikasi gagal dihapus.');
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _notifications.isEmpty ? null : _markAllAsRead,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA8000),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE0C3A0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Mark all as read',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _notifications.isEmpty ? null : _clearAll,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text('Clear All',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: BottomNavbar(currentIndex: _selectedNavIndex),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFEA8000)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.black26),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54)),
            TextButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );
    }
    if (_notifications.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFFEA8000),
        onRefresh: _load,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Center(
              child: Column(
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 56, color: Color(0xFFCCCCCC)),
                  SizedBox(height: 12),
                  Text('No recent notification',
                      style: TextStyle(fontSize: 14, color: Color(0xFFAAAAAA))),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: const Color(0xFFEA8000),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return _NotificationCard(
            notification: n,
            onTap: () => _markAsRead(n),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  // Konfigurasi warna/ikon per kategori (selaras dengan web).
  ({Color color, Color bg, IconData icon}) _config(String category) {
    switch (category) {
      case 'ACHIEVEMENT':
        return (
          color: const Color(0xFFEA8000),
          bg: const Color(0xFFFFF3E0),
          icon: Icons.emoji_events_outlined,
        );
      case 'ACTIVITY':
        return (
          color: const Color(0xFF2E9E3B),
          bg: const Color(0xFFE8F5E9),
          icon: Icons.event_available_outlined,
        );
      case 'SYSTEM':
        return (
          color: const Color(0xFF8B5CF6),
          bg: const Color(0xFFF3EEFF),
          icon: Icons.settings_outlined,
        );
      default:
        return (
          color: const Color(0xFF607D8B),
          bg: const Color(0xFFECEFF1),
          icon: Icons.notifications_outlined,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final read = notification.isRead;
    final cfg = _config(notification.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border(
                left: BorderSide(
                  color: read ? Colors.transparent : cfg.color,
                  width: 3.5,
                ),
              ),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Opacity(
              opacity: read ? 0.65 : 1,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cfg.bg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cfg.icon, color: cfg.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                notification.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: cfg.color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                notification.timeAgo,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black45),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            notification.message,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    if (!read)
                      Container(
                        margin: const EdgeInsets.only(left: 8, top: 4),
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: cfg.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
