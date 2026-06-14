import 'package:flutter/material.dart';
import '../models/chat_session.dart';

class ChatbotSidebar extends StatefulWidget {
  final List<ChatSession> sessions;
  final String? currentSessionId;
  final VoidCallback onNewChat;
  final void Function(String sessionId) onSelectSession;
  final void Function(String sessionId, String newName) onRenameSession;
  final void Function(String sessionId) onDeleteSession;
  final VoidCallback onDeleteAll;

  const ChatbotSidebar({
    Key? key,
    required this.sessions,
    required this.currentSessionId,
    required this.onNewChat,
    required this.onSelectSession,
    required this.onRenameSession,
    required this.onDeleteSession,
    required this.onDeleteAll,
  }) : super(key: key);

  @override
  State<ChatbotSidebar> createState() => _ChatbotSidebarState();
}

class _ChatbotSidebarState extends State<ChatbotSidebar> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatSession> get _filteredSessions {
    if (_searchQuery.isEmpty) return widget.sessions;
    return widget.sessions
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _showRenameDialog(ChatSession session) {
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                widget.onRenameSession(session.id, newName);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan', style: TextStyle(color: Color(0xFFEA8000))),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Riwayat'),
        content: const Text('Semua percakapan akan dihapus secara permanen. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteAll();
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
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildActionButtons(),
            _buildSearchField(),
            _buildSessionListLabel(),
            Expanded(child: _buildSessionList()),
            _buildDeleteAllButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Image.asset('Assets/images/DTC-AI Logo generate.jpg', width: 28, height: 28, fit: BoxFit.contain),
          const SizedBox(width: 10),
          const Text(
            'DTC AI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F1419),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          widget.onNewChat();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.edit_note, color: Color(0xFFEA8000), size: 20),
              SizedBox(width: 10),
              Text('Percakapan baru', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Cari percakapan',
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          filled: true,
          fillColor: const Color(0xFFF7F8FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionListLabel() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Riwayat',
          style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildSessionList() {
    final sessions = _filteredSessions;
    if (sessions.isEmpty) {
      return const Center(
        child: Text('Belum ada percakapan', style: TextStyle(color: Colors.grey, fontSize: 13)),
      );
    }
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (ctx, i) => _buildSessionItem(sessions[i]),
    );
  }

  Widget _buildSessionItem(ChatSession session) {
    final isActive = session.id == widget.currentSessionId;
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        widget.onSelectSession(session.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF0EDE6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                session.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: const Color(0xFF0F1419),
                ),
              ),
            ),
            if (isActive)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'rename') {
                    _showRenameDialog(session);
                  } else if (value == 'delete') {
                    widget.onDeleteSession(session.id);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'rename', child: Text('Rename')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Hapus sesi ini', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAllButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: InkWell(
        onTap: _showDeleteAllDialog,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text('Hapus riwayat', style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
