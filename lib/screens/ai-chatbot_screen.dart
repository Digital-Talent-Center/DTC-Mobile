import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/chatbot_service.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/chatbot_sidebar.dart';

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({Key? key}) : super(key: key);

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  static const int _navIndex = 2;

  List<ChatSession> _sessions = [];
  String? _currentSessionId;
  bool _isLoadingResponse = false;
  bool _isSearching = false;
  String _searchKeyword = '';

  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final sessions = await ChatbotService.instance.loadSessions();
    if (!mounted) return;
    if (sessions.isNotEmpty) {
      setState(() {
        _sessions = sessions;
        _currentSessionId = sessions.first.id;
      });
    } else {
      setState(() => _sessions = []);
      _createNewSession();
    }
  }

  void _createNewSession() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final sessionNumber = _sessions.length + 1;
    final greeting = ChatMessage(
      id: '${id}_0',
      content:
          'Halo! Saya DTC AI. Ada yang bisa saya bantu terkait kompetisi atau pengembangan startup hari ini?',
      isFromUser: false,
      timestamp: DateTime.now(),
    );
    final newSession = ChatSession(
      id: id,
      name: 'Percakapan $sessionNumber',
      messages: [greeting],
      createdAt: DateTime.now(),
    );
    setState(() {
      _sessions.insert(0, newSession);
      _currentSessionId = id;
    });
    _saveSessions();
  }

  Future<void> _saveSessions() async {
    await ChatbotService.instance.saveSessions(_sessions);
  }

  ChatSession? get _currentSession {
    if (_currentSessionId == null) return null;
    try {
      return _sessions.firstWhere((s) => s.id == _currentSessionId);
    } catch (_) {
      return null;
    }
  }

  List<ChatMessage> get _displayedMessages {
    final messages = _currentSession?.messages ?? [];
    if (_searchKeyword.isEmpty) return messages;
    return messages
        .where((m) => m.content.toLowerCase().contains(_searchKeyword.toLowerCase()))
        .toList();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoadingResponse) return;

    final session = _currentSession;
    if (session == null) return;

    final userMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_u',
      content: text,
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      session.messages.add(userMsg);
      _isLoadingResponse = true;
    });
    _inputController.clear();
    _scrollToBottom();

    final response = await ChatbotService.instance.sendMessage(text);

    final aiMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_a',
      content: response,
      isFromUser: false,
      timestamp: DateTime.now(),
    );

    if (!mounted) return;
    setState(() {
      session.messages.add(aiMsg);
      _isLoadingResponse = false;
    });
    await _saveSessions();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _selectSession(String sessionId) {
    setState(() {
      _currentSessionId = sessionId;
      _isSearching = false;
      _searchKeyword = '';
      _searchController.clear();
    });
    _scrollToBottom();
  }

  void _renameSession(String sessionId, String newName) {
    setState(() {
      final session = _sessions.firstWhere((s) => s.id == sessionId);
      session.name = newName;
    });
    _saveSessions();
  }

  void _deleteSession(String sessionId) {
    setState(() {
      _sessions.removeWhere((s) => s.id == sessionId);
      if (_currentSessionId == sessionId) {
        if (_sessions.isNotEmpty) {
          _currentSessionId = _sessions.first.id;
        } else {
          _currentSessionId = null;
        }
      }
    });
    _saveSessions();
    if (_currentSessionId == null) {
      _createNewSession();
    }
  }

  void _deleteAllSessions() {
    setState(() {
      _sessions.clear();
      _currentSessionId = null;
    });
    _saveSessions();
    _createNewSession();
  }

  void _renameCurrentSession() {
    final session = _currentSession;
    if (session == null) return;
    final controller = TextEditingController(text: session.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Percakapan'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama percakapan'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) _renameSession(session.id, newName);
              Navigator.pop(ctx);
            },
            child: const Text('Simpan', style: TextStyle(color: Color(0xFFEA8000))),
          ),
        ],
      ),
    );
  }

  void _deleteCurrentSession() {
    final session = _currentSession;
    if (session == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Percakapan'),
        content: Text('Hapus "${session.name}"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              _deleteSession(session.id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: _buildAppBar(),
      drawer: ChatbotSidebar(
        sessions: _sessions,
        currentSessionId: _currentSessionId,
        onNewChat: _createNewSession,
        onSelectSession: _selectSession,
        onRenameSession: _renameSession,
        onDeleteSession: _deleteSession,
        onDeleteAll: _deleteAllSessions,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: _navIndex),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchKeyword = '';
              _searchController.clear();
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (val) => setState(() => _searchKeyword = val),
          decoration: const InputDecoration(
            hintText: 'Cari dalam percakapan...',
            border: InputBorder.none,
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text(
        'DTC AI',
        style: TextStyle(
          color: Color(0xFF0F1419),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black87),
          onPressed: () => setState(() => _isSearching = true),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          onSelected: (value) {
            if (value == 'rename') _renameCurrentSession();
            if (value == 'delete') _deleteCurrentSession();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'rename', child: Text('Rename percakapan')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Hapus percakapan', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    final messages = _displayedMessages;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: messages.length + (_isLoadingResponse ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == messages.length) return _buildLoadingIndicator();
        return _buildMessageBubble(messages[i]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isFromUser;
    final timeStr =
        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white,
                  backgroundImage: const AssetImage('Assets/images/DTC-AI Logo generate.jpg'),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFFEA8000) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _searchKeyword.isNotEmpty
                      ? _buildHighlightedText(message.content, isUser)
                      : Text(
                          message.content,
                          style: TextStyle(
                            color: isUser ? Colors.white : const Color(0xFF0F1419),
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              if (isUser) const SizedBox(width: 6),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: isUser ? 0 : 34,
              right: isUser ? 6 : 0,
            ),
            child: Text(timeStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedText(String text, bool isUser) {
    final keyword = _searchKeyword.toLowerCase();
    final lower = text.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    int idx = lower.indexOf(keyword);
    while (idx != -1) {
      if (idx > start) spans.add(TextSpan(text: text.substring(start, idx)));
      spans.add(TextSpan(
        text: text.substring(idx, idx + keyword.length),
        style: const TextStyle(backgroundColor: Color(0xFFFFEB3B), color: Colors.black),
      ));
      start = idx + keyword.length;
      idx = lower.indexOf(keyword, start);
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: isUser ? Colors.white : const Color(0xFF0F1419),
          fontSize: 14,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 40),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const _TypingDots(),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                enabled: !_isLoadingResponse,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Tanya DTC AI...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoadingResponse ? null : _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isLoadingResponse ? Colors.grey.shade300 : const Color(0xFFEA8000),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                color: _isLoadingResponse ? Colors.grey : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final value = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (value - i * 0.2).clamp(0.0, 1.0);
            final opacity = (phase < 0.5 ? phase * 2 : (1 - phase) * 2).clamp(0.3, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFFEA8000).withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
