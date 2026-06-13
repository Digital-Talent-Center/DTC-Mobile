import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../config/api_config.dart';
import '../models/post.dart';
import '../services/api_client.dart';
import '../services/post_service.dart';
import '../services/session.dart';
import '../widgets/bottom_navbar.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _postController = TextEditingController();
  final Map<int, TextEditingController> _commentCtrls = {};

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 1;
  static const int _perPage = 10;

  List<Post> _posts = [];
  String? _selectedTag; // 'Event' | 'Article'
  String? _pickedMediaPath; // foto/video terpilih untuk diunggah
  bool _pickedIsVideo = false;
  bool _posting = false;
  final Map<int, bool> _expanded = {};

  static const Map<String, String> _reportReasons = {
    'inappropriate_content': 'Konten Tidak Pantas',
    'spam': 'Spam / Iklan Mengganggu',
    'harassment': 'Pelecehan / Perundungan',
    'false_information': 'Informasi Palsu / Hoaks',
    'copyright_violation': 'Pelanggaran Hak Cipta',
    'other': 'Lainnya',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _postController.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postController.dispose();
    for (final c in _commentCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEA8000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _page = 1;
      _hasMore = true;
    });
    try {
      final data = await PostService.instance.list(page: 1, perPage: _perPage);
      if (!mounted) return;
      setState(() {
        _posts = data;
        _hasMore = data.length >= _perPage;
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
        _error = 'Gagal memuat timeline. Periksa koneksi server.';
        _loading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _hasMore &&
        !_loading) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final next = await PostService.instance
          .list(page: _page + 1, perPage: _perPage);
      if (!mounted) return;
      setState(() {
        _page += 1;
        _posts.addAll(next);
        _hasMore = next.length >= _perPage;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _pickMedia({required bool isVideo}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: isVideo ? FileType.video : FileType.image,
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      if (file.path == null) return;
      if (file.size > 20 * 1024 * 1024) {
        _snack('Ukuran file melebihi 20MB');
        return;
      }
      setState(() {
        _pickedMediaPath = file.path;
        _pickedIsVideo = isVideo;
        _selectedTag = null; // media & tag eksklusif (seperti web)
      });
    } catch (e) {
      _snack('Gagal memilih media: $e');
    }
  }

  void _clearMedia() {
    setState(() {
      _pickedMediaPath = null;
      _pickedIsVideo = false;
    });
  }

  Future<void> _submitPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;
    setState(() => _posting = true);
    try {
      String? imageUrl;
      if (_pickedMediaPath != null) {
        imageUrl = await PostService.instance.uploadMedia(_pickedMediaPath!);
      }
      final post = await PostService.instance.create(
        content: text,
        tag: _selectedTag,
        imageUrl: imageUrl,
      );
      if (!mounted) return;
      setState(() {
        _posts.insert(0, post);
        _postController.clear();
        _selectedTag = null;
        _pickedMediaPath = null;
        _pickedIsVideo = false;
        _posting = false;
      });
    } on ApiException catch (e) {
      _snack(e.firstError);
      setState(() => _posting = false);
    } catch (_) {
      _snack('Gagal membuat post.');
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _toggleLike(Post post) async {
    // Optimistik
    final prevLiked = post.likedByMe;
    final prevCount = post.likesCount;
    setState(() {
      post.likedByMe = !prevLiked;
      post.likesCount += prevLiked ? -1 : 1;
    });
    try {
      final r = await PostService.instance.toggleLike(post.id);
      if (!mounted) return;
      setState(() {
        post.likedByMe = r.isLiked;
        post.likesCount = r.likesCount;
      });
    } catch (_) {
      setState(() {
        post.likedByMe = prevLiked;
        post.likesCount = prevCount;
      });
      _snack('Gagal menyukai post.');
    }
  }

  Future<void> _addComment(Post post) async {
    final ctrl = _commentCtrls[post.id];
    final text = ctrl?.text.trim() ?? '';
    if (text.isEmpty) return;
    try {
      final comment = await PostService.instance.addComment(post.id, text);
      if (!mounted) return;
      setState(() {
        post.comments = [...post.comments, comment];
        post.commentsCount += 1;
        ctrl?.clear();
      });
    } on ApiException catch (e) {
      _snack(e.firstError);
    } catch (_) {
      _snack('Gagal menambah komentar.');
    }
  }

  Future<void> _deletePost(Post post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Post'),
        content: const Text('Yakin ingin menghapus postingan ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await PostService.instance.deletePost(post.id);
      if (!mounted) return;
      setState(() => _posts.removeWhere((p) => p.id == post.id));
      _snack('Postingan dihapus.');
    } on ApiException catch (e) {
      _snack(e.firstError);
    } catch (_) {
      _snack('Gagal menghapus postingan.');
    }
  }

  void _sharePost(Post post) async {
    await Clipboard.setData(
        ClipboardData(text: '${ApiConfig.baseUrl}/timeline?post=${post.id}'));
    _snack('Link disalin ke clipboard');
  }

  void _showPostMenu(Post post) {
    final isOwn = post.userId == (Session.instance.user?.id ?? -1);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (isOwn)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Post',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _deletePost(post);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.flag_outlined,
                    color: Color(0xFFEA8000)),
                title: const Text('Laporkan Post'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportDialog(post);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(Post post) {
    String reason = 'inappropriate_content';
    final descCtrl = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.flag_outlined, color: Color(0xFFEA8000), size: 20),
              SizedBox(width: 8),
              Text('Laporkan Postingan', style: TextStyle(fontSize: 17)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ALASAN PELAPORAN',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: reason,
                    isExpanded: true,
                    items: _reportReasons.entries
                        .map((e) => DropdownMenuItem(
                            value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setLocal(() => reason = v!),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('DESKRIPSI (OPSIONAL)',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45)),
              const SizedBox(height: 6),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Detail tambahan...',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: submitting ? null : () => Navigator.pop(ctx),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      setLocal(() => submitting = true);
                      try {
                        await PostService.instance.report(
                          postId: post.id,
                          reason: reason,
                          description: descCtrl.text.trim(),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        _snack('Laporan dikirim, akan ditinjau admin.');
                      } on ApiException catch (e) {
                        setLocal(() => submitting = false);
                        _snack(e.firstError);
                      } catch (_) {
                        setLocal(() => submitting = false);
                        _snack('Gagal mengirim laporan.');
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA8000),
                foregroundColor: Colors.white,
              ),
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: Colors.white))
                  : const Text('Kirim Laporan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF6F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFEA8000)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Timeline',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: _buildBody(),
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
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
            Text(_error!, style: const TextStyle(color: Colors.black54)),
            TextButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: const Color(0xFFEA8000),
      onRefresh: _load,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _posts.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) return _buildCreatePostCard();
          final postIndex = index - 1;
          if (postIndex < _posts.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildPostCard(_posts[postIndex]),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: _loadingMore
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Color(0xFFEA8000)))
                  : (!_hasMore && _posts.isNotEmpty)
                      ? const Text('Semua postingan telah ditampilkan',
                          style: TextStyle(fontSize: 13, color: Colors.black38))
                      : (_posts.isEmpty
                          ? const Text('Belum ada postingan. Jadilah yang pertama!',
                              style: TextStyle(color: Colors.black45))
                          : const SizedBox.shrink()),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreatePostCard() {
    final me = Session.instance.user;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              _avatarCircle(me?.initials ?? '?', '', const Color(0xFFEA8000), 40),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _postController,
                  minLines: 1,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Start a post...',
                    hintStyle:
                        const TextStyle(color: Colors.black45, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF7F0E8),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          if (_pickedMediaPath != null) _buildMediaPreview(),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  children: [
                    _composerBtn(Icons.image_outlined, 'Photo',
                        () => _pickMedia(isVideo: false),
                        selected: _pickedMediaPath != null && !_pickedIsVideo),
                    _composerBtn(Icons.videocam_outlined, 'Video',
                        () => _pickMedia(isVideo: true),
                        selected: _pickedMediaPath != null && _pickedIsVideo),
                    _composerBtn(Icons.event_outlined, 'Event', () {
                      setState(() {
                        _selectedTag = _selectedTag == 'Event' ? null : 'Event';
                        if (_selectedTag != null) _clearMedia();
                      });
                    }, selected: _selectedTag == 'Event'),
                    _composerBtn(Icons.article_outlined, 'Article', () {
                      setState(() {
                        _selectedTag =
                            _selectedTag == 'Article' ? null : 'Article';
                        if (_selectedTag != null) _clearMedia();
                      });
                    }, selected: _selectedTag == 'Article'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: (_postController.text.trim().isEmpty || _posting)
                    ? null
                    : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA8000),
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: _posting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Post',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _composerBtn(IconData icon, String label, VoidCallback onTap,
      {bool selected = false}) {
    final color = selected ? const Color(0xFFEA8000) : Colors.black54;
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(fontSize: 13, color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        backgroundColor: selected ? const Color(0xFFFFF3E0) : null,
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _pickedIsVideo
                ? Container(
                    height: 160,
                    width: double.infinity,
                    color: const Color(0xFF1A2B3C),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam, color: Colors.white70, size: 36),
                          SizedBox(height: 6),
                          Text('Video terpilih',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                : Image.file(
                    File(_pickedMediaPath!),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: _clearMedia,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    final isExpanded = _expanded[post.id] == true;
    final isLong = post.content.length > 160;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 4, 0),
            child: Row(
              children: [
                _avatarCircle(post.initials, post.userAvatarUrl,
                    const Color(0xFFBDBDBD), 42),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(post.userName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87)),
                          ),
                          if (post.tag != null) ...[
                            const SizedBox(width: 6),
                            _tagBadge(post.tag!),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(post.timeAgo,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz,
                      color: Colors.black45, size: 20),
                  onPressed: () => _showPostMenu(post),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.content,
                  maxLines: isExpanded ? null : 3,
                  overflow:
                      isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black87, height: 1.45),
                ),
                if (!isExpanded && isLong)
                  GestureDetector(
                    onTap: () => setState(() => _expanded[post.id] = true),
                    child: const Text('more',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFEA8000),
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: post.isVideo
                  ? _FeedVideo(url: post.imageUrl!)
                  : Image.network(
                      post.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Text(
              '${post.likesCount} LIKES • ${post.commentsCount} COMMENTS',
              style: const TextStyle(fontSize: 11, color: Colors.black38),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _feedAction(
                  post.likedByMe ? Icons.thumb_up : Icons.thumb_up_outlined,
                  'Like',
                  post.likedByMe ? const Color(0xFFEA8000) : Colors.black54,
                  () => _toggleLike(post),
                ),
                _feedAction(Icons.chat_bubble_outline, 'Comment', Colors.black54,
                    () => setState(() => post.showComments = !post.showComments)),
                _feedAction(Icons.share_outlined, 'Share', Colors.black54,
                    () => _sharePost(post)),
              ],
            ),
          ),
          if (post.showComments) _buildComments(post),
        ],
      ),
    );
  }

  Widget _buildComments(Post post) {
    final ctrl = _commentCtrls.putIfAbsent(post.id, () => TextEditingController());
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...post.comments.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _avatarCircle(c.initials, c.userAvatarUrl,
                        const Color(0xFFBDBDBD), 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F2EC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(c.userName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                const SizedBox(width: 6),
                                Text(c.timeAgo,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.black38)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(c.content,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    hintText: 'Tulis komentar...',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF7F0E8),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _addComment(post),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFFEA8000)),
                onPressed: () => _addComment(post),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tagBadge(String tag) {
    Color bg;
    Color fg;
    switch (tag.toLowerCase()) {
      case 'event':
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        break;
      case 'achievement':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      default:
        bg = const Color(0xFFFFF3CD);
        fg = const Color(0xFFB8860B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(tag,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  Widget _avatarCircle(String initials, String avatarUrl, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        image: avatarUrl.isNotEmpty
            ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
            : null,
      ),
      child: avatarUrl.isNotEmpty
          ? null
          : Center(
              child: Text(initials,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: size * 0.35)),
            ),
    );
  }

  Widget _feedAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(fontSize: 13, color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
    );
  }
}

/// Pemutar video sederhana untuk media post di feed.
/// Inisialisasi saat tampil, tap untuk play/pause, dengan progress bar.
class _FeedVideo extends StatefulWidget {
  final String url;
  const _FeedVideo({required this.url});

  @override
  State<_FeedVideo> createState() => _FeedVideoState();
}

class _FeedVideoState extends State<_FeedVideo> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    final c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = c;
    c.initialize().then((_) {
      if (mounted) setState(() => _initialized = true);
    }).catchError((_) {
      if (mounted) setState(() => _error = true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
      } else {
        c.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error) return const SizedBox.shrink();
    final c = _controller;
    if (!_initialized || c == null) {
      return Container(
        height: 200,
        color: const Color(0xFF1A2B3C),
        child: const Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
                strokeWidth: 2.4, color: Colors.white70),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: _togglePlay,
      child: AspectRatio(
        aspectRatio: c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(c),
            if (!c.value.isPlaying)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: Colors.black45, shape: BoxShape.circle),
                child:
                    const Icon(Icons.play_arrow, color: Colors.white, size: 32),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                c,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                    playedColor: Color(0xFFEA8000)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
