import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/bottom_navbar.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final String _firstName = 'Arrijal Julfa';
  final String _lastName = 'Arrasyid';

  String get _initials {
    final fi = _firstName.isNotEmpty ? _firstName[0] : '';
    final li = _lastName.isNotEmpty ? _lastName[0] : '';
    return '$fi$li'.toUpperCase();
  }

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _displayedCount = 5;
  static const int _loadBatchSize = 5;

  final Map<int, bool> _expanded = {};
  String? _selectedPostType;
  final TextEditingController _postController = TextEditingController();

  // Pool 15 dummy posts
  final List<Map<String, dynamic>> _allPosts = [
    {
      'name': 'Fahmi Irawan',
      'role': 'Data Sains',
      'timeAgo': '2h ago',
      'text':
          '[Road to GEMASTIK XVII: Progress Update] Our team just finalized the UI/UX prototype for the competition. Focus for next week: Backend integration and API documentation. Keep pushing!',
      'hasMedia': true,
      'likesCount': 24,
      'commentsCount': 3,
      'isLiked': false,
      'type': 'Event',
    },
    {
      'name': 'Siti Aminah',
      'role': 'Informatika',
      'timeAgo': '5h ago',
      'text':
          'Alhamdulillah, proposal PKM-KC kami lolos tahap pendanaan! Terima kasih atas dukungan teman-teman semua. Semangat buat tim PKM lainnya! #PKM2024 #InovasiMahasiswa',
      'hasMedia': false,
      'likesCount': 5,
      'commentsCount': 2,
      'isLiked': false,
      'type': 'Achievement',
    },
    {
      'name': 'Budi Santoso',
      'role': 'Sistem Informasi',
      'timeAgo': '1d ago',
      'text':
          'Baru saja menyelesaikan sertifikasi Google Cloud Professional! Proses belajarnya cukup menantang tapi worth it. Semangat untuk teman-teman yang sedang mempersiapkan sertifikasi juga!',
      'hasMedia': false,
      'likesCount': 41,
      'commentsCount': 8,
      'isLiked': false,
      'type': 'Achievement',
    },
    {
      'name': 'Rini Kartika',
      'role': 'Manajemen',
      'timeAgo': '1d ago',
      'text':
          'Workshop Leadership & Communication Skills DTC hari ini luar biasa! Banyak insight baru yang bisa langsung diaplikasikan. Terima kasih para pembicara yang sudah berbagi pengalaman. See you next event!',
      'hasMedia': true,
      'likesCount': 18,
      'commentsCount': 5,
      'isLiked': false,
      'type': 'Event',
    },
    {
      'name': 'Dimas Pratama',
      'role': 'Teknik Elektro',
      'timeAgo': '2d ago',
      'text':
          'Open source project kami — IoT Smart Campus Monitoring — akhirnya mencapai 100 GitHub stars! Terima kasih untuk semua kontributor. Masih banyak fitur yang akan kami kembangkan.',
      'hasMedia': false,
      'likesCount': 67,
      'commentsCount': 12,
      'isLiked': false,
      'type': null,
    },
    {
      'name': 'Nadia Putri',
      'role': 'Psikologi',
      'timeAgo': '2d ago',
      'text':
          'Mental health matters! Jangan lupa istirahat di tengah padatnya tugas dan kegiatan. Kalau butuh ngobrol, DM aku ya. Kita semua butuh support system yang kuat 💛',
      'hasMedia': false,
      'likesCount': 93,
      'commentsCount': 21,
      'isLiked': false,
      'type': null,
    },
    {
      'name': 'Hendra Wijaya',
      'role': 'Teknik Informatika',
      'timeAgo': '3d ago',
      'text':
          'Excited banget! Tim kami berhasil masuk finalis Hackathon Nasional 2024. Babak final minggu depan di Jakarta. Doakan ya! 🚀 #Hackathon2024 #TechForIndonesia',
      'hasMedia': true,
      'likesCount': 112,
      'commentsCount': 34,
      'isLiked': false,
      'type': 'Achievement',
    },
    {
      'name': 'Ayu Lestari',
      'role': 'Desain Komunikasi Visual',
      'timeAgo': '3d ago',
      'text':
          'Sharing portofolio terbaru — UI/UX redesign untuk aplikasi e-learning kampus. Proses riset user-nya sangat membantu dalam menghasilkan desain yang lebih intuitif. Feedback welcome!',
      'hasMedia': true,
      'likesCount': 56,
      'commentsCount': 14,
      'isLiked': false,
      'type': 'Article',
    },
    {
      'name': 'Rizky Maulana',
      'role': 'Akuntansi',
      'timeAgo': '4d ago',
      'text':
          'Tips lolos seleksi magang Big Four: 1) Persiapkan CV yang ATS-friendly, 2) Latihan case study sejak jauh-jauh hari, 3) Bangun relasi di LinkedIn, 4) Jangan menyerah di penolakan pertama. You got this!',
      'hasMedia': false,
      'likesCount': 204,
      'commentsCount': 47,
      'isLiked': false,
      'type': 'Article',
    },
    {
      'name': 'Mega Silviana',
      'role': 'Biologi',
      'timeAgo': '4d ago',
      'text':
          'Paper penelitian kami tentang biodiversitas mangrove di Teluk Banten akhirnya diterima di jurnal internasional terindeks Scopus! Terima kasih tim dan pembimbing atas kerja keras selama 2 tahun ini.',
      'hasMedia': false,
      'likesCount': 89,
      'commentsCount': 23,
      'isLiked': false,
      'type': 'Article',
    },
    {
      'name': 'Fauzan Akbar',
      'role': 'Hukum',
      'timeAgo': '5d ago',
      'text':
          'Moot Court Competition selesai! Tim kami berhasil meraih juara 2 tingkat nasional. Pengalaman berargumentasi di depan panel hakim berpengalaman sungguh tidak ternilai.',
      'hasMedia': true,
      'likesCount': 37,
      'commentsCount': 9,
      'isLiked': false,
      'type': 'Achievement',
    },
    {
      'name': 'Tiara Dewi',
      'role': 'Komunikasi',
      'timeAgo': '5d ago',
      'text':
          'Just wrapped up our campus documentary project! 6 bulan proses produksi, ratusan jam footage, dan akhirnya jadi sebuah karya yang kami banggakan. Nantikan screeningnya bulan depan!',
      'hasMedia': true,
      'likesCount': 76,
      'commentsCount': 18,
      'isLiked': false,
      'type': 'Event',
    },
    {
      'name': 'Arief Nugroho',
      'role': 'Fisika',
      'timeAgo': '6d ago',
      'text':
          'Riset simulasi komputasi kami untuk optimasi panel surya berhasil menunjukkan peningkatan efisiensi 12% dibanding baseline. Excited untuk tahap implementasi hardware selanjutnya!',
      'hasMedia': false,
      'likesCount': 44,
      'commentsCount': 11,
      'isLiked': false,
      'type': 'Article',
    },
    {
      'name': 'Cindy Rahayu',
      'role': 'Farmasi',
      'timeAgo': '1w ago',
      'text':
          'Praktek lapangan di RSUP selama sebulan memberikan banyak pengalaman berharga. Melihat langsung bagaimana apoteker berperan dalam pelayanan pasien membuat semakin yakin dengan pilihan jurusan ini.',
      'hasMedia': false,
      'likesCount': 61,
      'commentsCount': 15,
      'isLiked': false,
      'type': null,
    },
    {
      'name': 'Wahyu Saputra',
      'role': 'Teknik Sipil',
      'timeAgo': '1w ago',
      'text':
          'Desain jembatan gantung kami untuk desa terpencil di Kalimantan berhasil mendapat pendanaan dari program CSR perusahaan BUMN. Insya Allah konstruksi dimulai bulan depan. Semoga bermanfaat!',
      'hasMedia': true,
      'likesCount': 158,
      'commentsCount': 42,
      'isLiked': false,
      'type': 'Event',
    },
  ];

  List<Map<String, dynamic>> get _visiblePosts =>
      _allPosts.take(_displayedCount).toList();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _postController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 150 &&
        !_isLoadingMore &&
        _displayedCount < _allPosts.length) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _displayedCount =
            (_displayedCount + _loadBatchSize).clamp(0, _allPosts.length);
        _isLoadingMore = false;
      });
    }
  }

  void _submitPost() {
    final text = _postController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _allPosts.insert(0, {
        'name': '$_firstName $_lastName',
        'role': 'Human Capital',
        'timeAgo': 'Baru saja',
        'text': text,
        'hasMedia': false,
        'likesCount': 0,
        'commentsCount': 0,
        'isLiked': false,
        'type': _selectedPostType,
      });
      _displayedCount += 1;
      _postController.clear();
      _selectedPostType = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEA8000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _getInitialsFromName(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
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
        title: const Text(
          'Timeline',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _visiblePosts.length + 2, // +1 header, +1 footer
        itemBuilder: (context, index) {
          if (index == 0) return _buildCreatePostCard();
          final postIndex = index - 1;
          if (postIndex < _visiblePosts.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildPostCard(postIndex),
            );
          }
          // Footer
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: _isLoadingMore
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFFEA8000),
                      ),
                    )
                  : _displayedCount >= _allPosts.length
                      ? const Text(
                          'Semua postingan telah ditampilkan',
                          style: TextStyle(fontSize: 13, color: Colors.black38),
                        )
                      : const SizedBox.shrink(),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavbar(currentIndex: 1),
    );
  }

  Widget _buildCreatePostCard() {
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
              _buildAvatarCircle(_initials, const Color(0xFFEA8000), 40),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _postController,
                  minLines: 1,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Start a post...',
                    hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF7F0E8),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFEA8000), width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 0,
                  children: [
                    _buildPostActionButton(
                      Icons.image_outlined,
                      'Photo',
                      null,
                    ),
                    _buildPostActionButton(
                      Icons.videocam_outlined,
                      'Video',
                      null,
                    ),
                    _buildPostActionButton(
                      Icons.event_outlined,
                      'Event',
                      () => setState(() {
                        _selectedPostType =
                            _selectedPostType == 'Event' ? null : 'Event';
                      }),
                      selected: _selectedPostType == 'Event',
                    ),
                    _buildPostActionButton(
                      Icons.article_outlined,
                      'Write article',
                      () => setState(() {
                        _selectedPostType =
                            _selectedPostType == 'Article' ? null : 'Article';
                      }),
                      selected: _selectedPostType == 'Article',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _postController.text.trim().isNotEmpty ? _submitPost : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _postController.text.trim().isNotEmpty
                      ? const Color(0xFFEA8000)
                      : const Color(0xFFE0E0E0),
                  foregroundColor: _postController.text.trim().isNotEmpty
                      ? Colors.white
                      : Colors.black45,
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  disabledForegroundColor: Colors.black45,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Post',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostActionButton(
    IconData icon,
    String label,
    VoidCallback? onTap, {
    bool selected = false,
  }) {
    final color = selected ? const Color(0xFFEA8000) : Colors.black54;
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(fontSize: 13, color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        backgroundColor: selected ? const Color(0xFFFFF3E0) : null,
        shape: selected
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            : null,
      ),
    );
  }

  Widget _buildPostCard(int index) {
    final post = _visiblePosts[index];
    final isLiked = post['isLiked'] as bool;
    final isExpanded = _expanded[index] == true;

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
          // Header: avatar + nama + badge + more icon + role + waktu
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 4, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatarCircle(
                  _getInitialsFromName(post['name'] as String),
                  const Color(0xFFBDBDBD),
                  42,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          if (post['type'] != null) ...[
                            const SizedBox(width: 6),
                            _buildTypeBadge(post['type'] as String),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${post['role']} • ${post['timeAgo']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.black45, size: 20),
                  onPressed: () => _showMoreOptions(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Post text
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['text'] as String,
                  maxLines: isExpanded ? null : 3,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.45,
                  ),
                ),
                if (!isExpanded && _isTextLong(post['text'] as String))
                  GestureDetector(
                    onTap: () => setState(() => _expanded[index] = true),
                    child: const Text(
                      'more',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFEA8000),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Media placeholder
          if (post['hasMedia'] == true)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.zero,
                  topRight: Radius.zero,
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: const Color(0xFF1A2B3C),
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0D1B2A), Color(0xFF1B4F72)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, size: 40, color: Colors.white54),
                            const SizedBox(height: 8),
                            const Text(
                              'Media',
                              style: TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Likes & comments count
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Text(
              '${post['likesCount']} LIKES • ${post['commentsCount']} COMMENTS',
              style: const TextStyle(fontSize: 11, color: Colors.black38),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),

          // Action row
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFeedActionButton(
                  isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  'Like',
                  isLiked ? const Color(0xFFEA8000) : Colors.black54,
                  () {
                    setState(() {
                      _allPosts[index]['isLiked'] = !isLiked;
                      _allPosts[index]['likesCount'] =
                          (post['likesCount'] as int) + (isLiked ? -1 : 1);
                    });
                  },
                ),
                _buildFeedActionButton(
                  Icons.chat_bubble_outline,
                  'Comment',
                  Colors.black54,
                  () => _showSnackBar('Fitur komentar akan segera hadir'),
                ),
                _buildFeedActionButton(
                  Icons.share_outlined,
                  'Share',
                  Colors.black54,
                  () async {
                    await Clipboard.setData(
                      ClipboardData(text: 'https://dtc.web/post/$index'),
                    );
                    _showSnackBar('Link disalin ke clipboard');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color bg;
    Color fg;
    switch (type) {
      case 'Event':
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        break;
      case 'Achievement':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case 'Article':
      default:
        bg = const Color(0xFFFFF3CD);
        fg = const Color(0xFFB8860B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        type,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
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
            _buildSheetOption(Icons.bookmark_outline, 'Simpan Post', ctx),
            _buildSheetOption(Icons.flag_outlined, 'Laporkan', ctx),
            _buildSheetOption(Icons.visibility_off_outlined, 'Sembunyikan', ctx),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetOption(IconData icon, String label, BuildContext ctx) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: () {
        Navigator.pop(ctx);
        _showSnackBar('$label (dummy)');
      },
    );
  }

  Widget _buildAvatarCircle(String initials, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(fontSize: 13, color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
    );
  }

  bool _isTextLong(String text) => text.length > 120;
}
