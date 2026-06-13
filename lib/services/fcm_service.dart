import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../screens/my_achievements_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/timeline_screen.dart';
import 'api_client.dart';
import 'session.dart';

/// Handler top-level untuk background message (wajib top-level function).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

/// Layanan FCM: kelola token, tampilkan notifikasi foreground, handle tap.
///
/// Inisialisasi dipanggil setelah Firebase.initializeApp() dan saat user
/// sudah login (token Sanctum tersedia).
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  /// Navigator key global — di-set dari MaterialApp agar service bisa navigasi.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// Channel Android untuk notifikasi foreground.
  static const _androidChannel = AndroidNotificationChannel(
    'dtc_default_channel',
    'Notifikasi DTC',
    description: 'Channel utama notifikasi DTC Mobile',
    importance: Importance.high,
  );

  String? _currentToken;
  bool _initialized = false;

  /// Inisialisasi FCM. Aman dipanggil berulang (idempotent).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _requestPermission();
    await _setupLocalNotifications();
    _listenForegroundMessages();
    _listenNotificationTap();
    await _getTokenAndSend();
    _listenTokenRefresh();
  }

  /// Register/kirim ulang FCM token ke backend. Dipanggil setelah login/register.
  Future<void> registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        _currentToken = token;
        await sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('[FCM] registerToken error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Permission
  // ---------------------------------------------------------------------------

  Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('[FCM] requestPermission error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Token management
  // ---------------------------------------------------------------------------

  Future<void> _getTokenAndSend() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        _currentToken = token;
        debugPrint('[FCM] Token: $token');
        if (Session.instance.isLoggedIn) {
          await sendTokenToBackend(token);
        }
      }
    } catch (e) {
      debugPrint('[FCM] getToken error: $e');
    }
  }

  void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      _currentToken = token;
      debugPrint('[FCM] Token refreshed: $token');
      if (Session.instance.isLoggedIn) {
        await sendTokenToBackend(token);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Local notifications (foreground)
  // ---------------------------------------------------------------------------

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final data = message.data;

      final title = notification?.title ?? _titleFromData(data);
      final body = notification?.body ?? _bodyFromData(data);
      if (title.isEmpty && body.isEmpty) return;

      // Encode data payload ke JSON string sebagai payload local notification
      // agar bisa dibaca saat user tap.
      String? payload;
      if (data.isNotEmpty) {
        try {
          payload = jsonEncode(data);
        } catch (_) {
          payload = data['type'];
        }
      }

      _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title.isNotEmpty ? title : 'DTC Mobile',
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Notification type → default title/body (fallback jika server tidak kirim)
  // ---------------------------------------------------------------------------

  String _titleFromData(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'POST_LIKED':
        return 'Postingan kamu disukai';
      case 'POST_COMMENTED':
        return 'Komentar baru';
      case 'ACHIEVEMENT_APPROVED':
        return 'Achievement diterima';
      case 'ACHIEVEMENT_REJECTED':
        return 'Achievement ditolak';
      case 'POST_DELETED_BY_ADMIN':
        return 'Postingan dihapus';
      default:
        return '';
    }
  }

  String _bodyFromData(Map<String, dynamic> data) {
    final actorName = data['actor_name'] ?? '';
    switch (data['type']) {
      case 'POST_LIKED':
        return actorName.isNotEmpty
            ? '$actorName menyukai postingan kamu.'
            : 'Seseorang menyukai postingan kamu.';
      case 'POST_COMMENTED':
        final preview = data['comment_preview'] ?? '';
        if (actorName.isNotEmpty && preview.isNotEmpty) {
          return '$actorName mengomentari postingan kamu: $preview';
        }
        return actorName.isNotEmpty
            ? '$actorName mengomentari postingan kamu.'
            : 'Ada komentar baru di postingan kamu.';
      case 'ACHIEVEMENT_APPROVED':
        return 'Achievement kamu berhasil disetujui.';
      case 'ACHIEVEMENT_REJECTED':
        return 'Achievement kamu ditolak. Silakan cek alasan penolakan.';
      case 'POST_DELETED_BY_ADMIN':
        final reason = data['reason'] ?? 'Melanggar aturan komunitas';
        return 'Postingan kamu dihapus karena $reason.';
      default:
        return '';
    }
  }

  // ---------------------------------------------------------------------------
  // Notification tap handling
  // ---------------------------------------------------------------------------

  void _listenNotificationTap() {
    // Tap saat app di background → dibuka dari system tray.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationRoute(message.data);
    });

    // Tap saat app terminated → cek initial message.
    _messaging.getInitialMessage().then((message) {
      if (message != null) _handleNotificationRoute(message.data);
    });
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    Map<String, dynamic> data = {};
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.payload!);
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {
        // payload bukan JSON valid → arahkan ke NotificationScreen.
      }
    }
    _handleNotificationRoute(data);
  }

  /// Routing berdasarkan type notifikasi dari data payload.
  void _handleNotificationRoute(Map<String, dynamic> data) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    final type = data['type'] as String? ?? '';

    switch (type) {
      case 'POST_LIKED':
      case 'POST_COMMENTED':
        // Arahkan ke TimelineScreen agar user bisa melihat postingan.
        // Tidak ada halaman detail post khusus di project ini.
        nav.push(
          MaterialPageRoute(builder: (_) => const TimelineScreen()),
        );
        break;

      case 'ACHIEVEMENT_APPROVED':
      case 'ACHIEVEMENT_REJECTED':
        nav.push(
          MaterialPageRoute(builder: (_) => const MyAchievementsScreen()),
        );
        break;

      case 'POST_DELETED_BY_ADMIN':
        // Postingan sudah dihapus → jangan arahkan ke detail post.
        nav.push(
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
        break;

      default:
        // Type tidak dikenal → arahkan ke NotificationScreen.
        nav.push(
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Backend communication
  // ---------------------------------------------------------------------------

  Future<void> sendTokenToBackend(String token) async {
    if (!Session.instance.isLoggedIn) return;
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      await ApiClient.instance.post('/fcm-token', body: {
        'token': token,
        'platform': platform,
      });
      debugPrint('[FCM] Token sent to backend');
    } catch (e) {
      debugPrint('[FCM] sendTokenToBackend error: $e');
    }
  }

  Future<void> deleteTokenFromBackend() async {
    if (_currentToken == null || _currentToken!.isEmpty) return;
    try {
      await ApiClient.instance.delete('/fcm-token', body: {
        'token': _currentToken,
      });
      debugPrint('[FCM] Token deleted from backend');
    } catch (e) {
      debugPrint('[FCM] deleteTokenFromBackend error: $e');
    }
  }
}
