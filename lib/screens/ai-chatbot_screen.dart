import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/api_config.dart';
import '../models/chat_session.dart';
import '../services/chatbot_service.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/chatbot_sidebar.dart';

/// Halaman DTC AI — embed Botpress webchat di dalam WebView.
/// Pendekatan sama seperti DTC-Platform (web) yang menggunakan
/// inject.js + config.js dari Botpress Cloud.
class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({Key? key}) : super(key: key);

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  static const int _navIndex = 2;

  // ── Botpress configuration (sama dengan DTC-Platform) ──
  static const _bpInject =
      'https://cdn.botpress.cloud/webchat/v3.6/inject.js';
  static const _bpConfig =
      'https://files.bpcontent.cloud/2026/06/11/18/20260611183647-A3ATWCTL.js';
  static const _bpClientId = 'e09f61e4-1a6a-43ed-9227-e6ff570b4f5a';

  late final WebViewController _webController;
  bool _isLoading = true;
  bool _hasError = false;

  // ── Sidebar conversation history ──
  List<ChatSession> _sessions = [];
  String? _activeConvoId;
  Timer? _syncTimer;

  // ── HTML yang dimuat di WebView ──
  // CSS menyembunyikan header & sidebar bawaan Botpress (kita punya sendiri).
  // JS helper dipanggil dari Flutter via runJavaScript().
  static final _botpressHtml = r'''
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:100%;height:100%;overflow:hidden;background:#F5F0E8}
#bp-embedded-webchat{width:100%;height:100%}
</style>
</head>
<body>
<div id="bp-embedded-webchat"></div>
<script src="''' +
      _bpInject +
      r'''"></script>
<script src="''' +
      _bpConfig +
      r'''"></script>
<script>
var BP_KEY="bp-webchat-''' +
      _bpClientId +
      r'''-client";
var BP_CSS="header,[class*=Header],[data-testid*=header]{display:none!important}"
  +"[class*=Sidebar],[class*=sidebar],[class*=History],[class*=history],"
  +"[class*=ConversationList],[class*=conversationList]{display:none!important}"
  +"button[aria-label*=istory],button[aria-label*=onversation],"
  +"[class*=BackButton],[class*=backButton]{display:none!important}"
  +":host{width:100%!important;height:100%!important}";

function injectShadowCSS(el,id,css){
  if(el.shadowRoot){
    if(!el.shadowRoot.getElementById(id)){
      var s=document.createElement("style");
      s.id=id;s.textContent=css;
      el.shadowRoot.prepend(s);
    }
    el.shadowRoot.querySelectorAll("*").forEach(function(c){injectShadowCSS(c,id,css)});
  }
  for(var i=0;i<el.children.length;i++) injectShadowCSS(el.children[i],id,css);
}

setInterval(function(){
  var el=document.getElementById("bp-embedded-webchat");
  if(el) injectShadowCSS(el,"dtc-bp",BP_CSS);
},500);

function getConvoId(){
  try{
    var d=JSON.parse(localStorage.getItem(BP_KEY)||"{}");
    return (d.state&&d.state.conversationId)||"";
  }catch(e){return "";}
}

function switchConvo(cid){
  try{
    var d=JSON.parse(localStorage.getItem(BP_KEY)||'{"state":{}}');
    if(!d.state) d.state={};
    d.state.conversationId=cid;
    localStorage.setItem(BP_KEY,JSON.stringify(d));
    location.reload();
  }catch(e){}
}

function newConvo(){
  try{
    var d=JSON.parse(localStorage.getItem(BP_KEY)||'{"state":{}}');
    if(d.state) delete d.state.conversationId;
    localStorage.setItem(BP_KEY,JSON.stringify(d));
    location.reload();
  }catch(e){}
}

function clearAllConvo(){
  localStorage.removeItem(BP_KEY);
  location.reload();
}

window.addEventListener("load", function() {
  var checkInterval = setInterval(function() {
    if (window.botpress && typeof window.botpress.on === "function") {
      clearInterval(checkInterval);
      window.botpress.on("message", function(event) {
        if (event.direction === "outgoing") {
          var text = "";
          if (event.payload && typeof event.payload.text === "string") {
            text = event.payload.text;
          } else if (typeof event.preview === "string") {
            text = event.preview;
          }
          text = text.trim();
          if (text.length >= 2) {
            var cid = getConvoId();
            if (cid && window.DtcAiChannel) {
              window.DtcAiChannel.postMessage(JSON.stringify({
                event: "message_sent",
                cid: cid,
                text: text
              }));
            }
          }
        }
      });
    }
  }, 100);
});
</script>
</body>
</html>
''';

  // ──────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadSessions();
    _initWebView();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // WebView
  // ──────────────────────────────────────────────

  void _initWebView() {
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'DtcAiChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message) as Map<String, dynamic>;
            final event = data['event'] as String;
            final cid = data['cid'] as String;
            final text = data['text'] as String;
            
            if (event == 'message_sent') {
              _handleMessageSent(cid, text);
            }
          } catch (e) {
            debugPrint('Error from JS Channel: $e');
          }
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _hasError = false;
          });
          _startSync();
        },
        onWebResourceError: (WebResourceError error) {
          if (!mounted) return;
          if (error.isForMainFrame == true) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        },
      ))
      ..loadHtmlString(_botpressHtml, baseUrl: ApiConfig.baseUrl);
  }

  /// Polling sederhana — setiap 2 detik cek conversation ID aktif
  /// dari localStorage Botpress di WebView, lalu sinkronkan ke sidebar.
  void _startSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _syncConvoId(),
    );
  }

  Future<void> _syncConvoId() async {
    try {
      final raw = await _webController
          .runJavaScriptReturningResult('getConvoId()');
      final cid = raw.toString().replaceAll('"', '').replaceAll("'", '');
      if (cid.isEmpty || cid == 'null') return;
      if (!mounted) return;

      setState(() {
        _activeConvoId = cid;
      });
    } catch (_) {
      // WebView belum siap atau halaman sedang reload, abaikan.
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _webController.loadHtmlString(_botpressHtml, baseUrl: ApiConfig.baseUrl);
  }

  // ──────────────────────────────────────────────
  // Session / History management
  // ──────────────────────────────────────────────

  Future<void> _loadSessions() async {
    final sessions = await ChatbotService.instance.loadSessions();
    if (!mounted) return;
    setState(() => _sessions = sessions);
  }

  void _createNewSession() {
    _webController.runJavaScript('newConvo()');
    setState(() {
      _activeConvoId = null;
    });
  }

  void _selectSession(String sessionId) {
    if (sessionId == _activeConvoId) return;
    _webController.runJavaScript('switchConvo("$sessionId")');
    setState(() {
      _activeConvoId = sessionId;
    });
  }

  void _renameSession(String sessionId, String newName) async {
    setState(() {
      try {
        final session = _sessions.firstWhere((s) => s.id == sessionId);
        session.name = newName;
      } catch (_) {}
    });

    try {
      final synced = await ChatbotService.instance.upsertSession(sessionId, newName);
      if (mounted) {
        setState(() {
          final index = _sessions.indexWhere((s) => s.id == sessionId);
          if (index != -1) {
            _sessions[index] = ChatSession(
              id: sessionId,
              serverId: synced.serverId,
              name: newName,
              messages: _sessions[index].messages,
              createdAt: _sessions[index].createdAt,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to rename session on server: $e');
    }
  }

  void _handleMessageSent(String cid, String text) async {
    if (!mounted) return;
    
    final newName = text.length > 35 ? '${text.substring(0, 35)}…' : text;
    
    // Check if it already exists
    final index = _sessions.indexWhere((s) => s.id == cid);
    if (index != -1) {
      final session = _sessions[index];
      if (session.name == 'Percakapan Baru') {
        _renameSession(cid, newName);
      }
    } else {
      // It's a brand new session that hasn't been synced to Flutter's list yet.
      // Let's add it locally and upsert it with the real message context title!
      final newSession = ChatSession(
        id: cid,
        name: newName,
        messages: [],
        createdAt: DateTime.now(),
      );
      setState(() {
        _sessions.insert(0, newSession);
        _activeConvoId = cid;
      });
      
      try {
        final synced = await ChatbotService.instance.upsertSession(cid, newName);
        if (mounted) {
          setState(() {
            final idx = _sessions.indexWhere((s) => s.id == cid);
            if (idx != -1) {
              _sessions[idx] = ChatSession(
                id: cid,
                serverId: synced.serverId,
                name: newName,
                messages: _sessions[idx].messages,
                createdAt: _sessions[idx].createdAt,
              );
            }
          });
        }
      } catch (e) {
        debugPrint('Failed to sync new session to server: $e');
      }
    }
  }

  void _deleteSession(String sessionId) async {
    int? serverId;
    try {
      final session = _sessions.firstWhere((s) => s.id == sessionId);
      serverId = session.serverId;
    } catch (_) {}

    setState(() {
      _sessions.removeWhere((s) => s.id == sessionId);
      if (_activeConvoId == sessionId) _activeConvoId = null;
    });

    if (serverId != null) {
      try {
        await ChatbotService.instance.deleteSession(serverId);
      } catch (e) {
        debugPrint('Failed to delete session on server: $e');
      }
    }

    if (_activeConvoId == null) _createNewSession();
  }

  void _deleteAllSessions() async {
    setState(() {
      _sessions.clear();
      _activeConvoId = null;
    });

    try {
      await ChatbotService.instance.deleteAllSessions();
    } catch (e) {
      debugPrint('Failed to delete all sessions on server: $e');
    }

    _webController.runJavaScript('clearAllConvo()');
    setState(() => _isLoading = true);
  }

  // ──────────────────────────────────────────────
  // UI
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: _buildAppBar(),
      drawer: ChatbotSidebar(
        sessions: _sessions,
        currentSessionId: _activeConvoId,
        onNewChat: _createNewSession,
        onSelectSession: _selectSession,
        onRenameSession: _renameSession,
        onDeleteSession: _deleteSession,
        onDeleteAll: _deleteAllSessions,
      ),
      body: Stack(
        children: [
          // ── Botpress WebView ──
          WebViewWidget(controller: _webController),

          // ── Loading overlay ──
          if (_isLoading)
            Container(
              color: const Color(0xFFF5F0E8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          color: Color(0xFFEA8000),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Menghubungkan ke DTC AI…',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Error overlay ──
          if (_hasError)
            Container(
              color: const Color(0xFFF5F0E8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.cloud_off,
                          size: 32, color: Colors.red.shade300),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal memuat DTC AI',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Periksa koneksi internet Anda',
                      style: TextStyle(fontSize: 13, color: Colors.black45),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Coba lagi',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA8000),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: _navIndex),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Row(
        children: [
          const Text(
            'DTC AI',
            style: TextStyle(
              color: Color(0xFF0F1419),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          if (!_hasError && !_isLoading)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          if (_isLoading)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Memuat…',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          onSelected: (value) {
            if (value == 'new') _createNewSession();
            if (value == 'reload') _retry();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
                value: 'new', child: Text('Percakapan baru')),
            const PopupMenuItem(
                value: 'reload', child: Text('Muat ulang')),
          ],
        ),
      ],
    );
  }
}
