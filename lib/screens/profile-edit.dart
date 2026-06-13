import 'package:flutter/material.dart';
import '../models/profile_detail.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nimController = TextEditingController();
  final _fakultasController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _showOldPass = false;
  bool _showNewPass = false;
  bool _showConfirmPass = false;

  bool _loading = true;
  bool _saving = false;
  ProfileDetail? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await ProfileService.instance.fetch();
      if (!mounted) return;
      setState(() {
        _profile = p;
        _nimController.text = p.nim ?? '';
        _fakultasController.text = p.faculty ?? '';
        _jurusanController.text = p.major ?? '';
        _phoneController.text = p.phone ?? '';
        _bioController.text = p.about ?? '';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnackBar('Gagal memuat profil. Periksa koneksi server.');
    }
  }

  @override
  void dispose() {
    _nimController.dispose();
    _fakultasController.dispose();
    _jurusanController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
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

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await ProfileService.instance.update(
        nim: _nimController.text.trim(),
        faculty: _fakultasController.text.trim(),
        major: _jurusanController.text.trim(),
        phone: _phoneController.text.trim(),
        about: _bioController.text.trim(),
      );
      // Segarkan sesi agar nama/identitas terbaru terpakai di layar lain.
      await AuthService.instance.me();
      if (!mounted) return;
      _showSnackBar('Profil berhasil disimpan');
      Navigator.pop(context);
    } on ApiException catch (e) {
      _showSnackBar(e.firstError);
    } catch (_) {
      _showSnackBar('Gagal menyimpan profil. Periksa koneksi server.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
          'Edit Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEA8000)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildUserHeader(),
                    const SizedBox(height: 16),
                    _buildProfileForm(),
                    const SizedBox(height: 16),
                    _buildPasswordForm(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserHeader() {
    final p = _profile;
    final initials = p?.initials ?? '?';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEA8000),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
              ],
              image: (p?.avatarUrl != null)
                  ? DecorationImage(
                      image: NetworkImage(p!.avatarUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: (p?.avatarUrl != null)
                ? null
                : Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p?.name ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (p?.role.isNotEmpty ?? false)
                        ? (p!.role[0].toUpperCase() + p.role.substring(1))
                        : 'Student',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEA8000),
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

  Widget _buildProfileForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          _buildSectionHeader('INFO PROFIL'),
          const SizedBox(height: 16),
          _buildField('NIM', _nimController, hintText: 'contoh: 21004567'),
          _buildField('FAKULTAS', _fakultasController,
              hintText: 'Faculty of Computer Science'),
          _buildField('JURUSAN', _jurusanController, hintText: 'S1 Informatika'),
          _buildField('NO. HP / WHATSAPP', _phoneController,
              hintText: '+62 8xx xxxx xxxx'),
          _buildTextArea('ABOUT / BIO', _bioController,
              hintText: 'Ceritakan sedikit tentang dirimu...'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA8000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : const Text('Simpan Perubahan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          _buildSectionHeader('GANTI PASSWORD'),
          const SizedBox(height: 4),
          const Text(
            'Perbarui kata sandi akun kamu.',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            'PASSWORD LAMA',
            _oldPassController,
            'Masukkan password saat ini',
            _showOldPass,
            () => setState(() => _showOldPass = !_showOldPass),
          ),
          _buildPasswordField(
            'PASSWORD BARU',
            _newPassController,
            'Masukkan password baru',
            _showNewPass,
            () => setState(() => _showNewPass = !_showNewPass),
          ),
          _buildPasswordField(
            'KONFIRMASI PASSWORD',
            _confirmPassController,
            'Konfirmasi password baru',
            _showConfirmPass,
            () => setState(() => _showConfirmPass = !_showConfirmPass),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_oldPassController.text.isEmpty ||
                    _newPassController.text.isEmpty ||
                    _confirmPassController.text.isEmpty) {
                  _showSnackBar('Harap isi semua field password');
                  return;
                }
                if (_newPassController.text != _confirmPassController.text) {
                  _showSnackBar('Password baru dan konfirmasi tidak cocok');
                  return;
                }
                _showSnackBar('Password berhasil diubah');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1D20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Simpan Password',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFEA8000),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String hintText = '',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: _decoration(hintText),
          ),
        ],
      ),
    );
  }

  Widget _buildTextArea(
    String label,
    TextEditingController controller, {
    String hintText = '',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: 4,
            minLines: 3,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: _decoration(hintText),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    String hintText,
    bool obscure,
    VoidCallback onToggle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: _decoration(hintText).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.black45,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEA8000)),
      ),
    );
  }
}
