import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../services/api_client.dart';
import '../widgets/bottom_navbar.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  int _selectedTab = 0; // 0 = All, 1 = Events, 2 = Tasks
  final int _selectedNavIndex = 0;

  bool _loading = true;
  String? _error;
  List<Activity> _activities = [];

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
      final data = await ActivityService.instance.list();
      if (!mounted) return;
      setState(() {
        _activities = data;
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
        _error = 'Gagal memuat aktivitas. Periksa koneksi server.';
        _loading = false;
      });
    }
  }

  List<Activity> get _filteredActivities {
    switch (_selectedTab) {
      case 1:
        return _activities.where((a) => a.isEvent).toList();
      case 2:
        return _activities.where((a) => a.isTask).toList();
      default:
        return _activities;
    }
  }

  Future<void> _changeStatus(Activity a, String status) async {
    try {
      await ActivityService.instance.updateStatus(a.id, status);
      await _load();
    } on ApiException catch (e) {
      _snack(e.firstError);
    } catch (_) {
      _snack('Gagal memperbarui status.');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddActivitySheet(
        onCreated: () {
          Navigator.pop(context);
          _load();
        },
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
        title: const Text(
          'Activities',
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
          _buildTabBar(),
          const SizedBox(height: 16),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        backgroundColor: const Color(0xFFEA8000),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedNavIndex,
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFEA8000)));
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
    final activities = _filteredActivities;
    if (activities.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFFEA8000),
        onRefresh: _load,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text('Belum ada aktivitas.',
                  style: TextStyle(color: Colors.black45)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: const Color(0xFFEA8000),
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        itemCount: activities.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return _ActivityCard(
            activity: activities[index],
            onStatus: _changeStatus,
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8ECDB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'All',
            selected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _TabButton(
            label: 'Events',
            selected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
          _TabButton(
            label: 'Tasks',
            selected: _selectedTab == 2,
            onTap: () => setState(() => _selectedTab = 2),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: selected ? const Color(0xFFEA8000) : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final Future<void> Function(Activity, String) onStatus;

  const _ActivityCard({required this.activity, required this.onStatus});

  @override
  Widget build(BuildContext context) {
    final isTask = activity.isTask;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _typeBadge(isTask),
              const SizedBox(width: 8),
              _statusBadge(activity.displayStatus),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            activity.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.black87,
            ),
          ),
          if (activity.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              activity.description,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 14),
          _infoRow(Icons.calendar_today_outlined, activity.dateLabel,
              Colors.black45, Colors.black54),
          if (isTask && activity.deadline != null) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.access_time, 'Deadline: ${activity.deadlineLabel}',
                const Color(0xFFEA8000), const Color(0xFFEA8000)),
          ],
          if (!isTask) ...[
            if (activity.timeLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.access_time, activity.timeLabel, Colors.black45,
                  Colors.black54),
            ],
            if (activity.location != null) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.location_on_outlined, activity.location!,
                  Colors.black45, Colors.black54),
            ],
          ],
          _actionButton(),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color iconColor, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 13, color: textColor)),
        ),
      ],
    );
  }

  Widget _typeBadge(bool isTask) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isTask ? const Color(0xFFBFD4FF) : const Color(0xFFF5B800),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isTask ? 'Task' : 'Event',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    late Color bg;
    late Color fg;
    late String label;

    switch (status) {
      case 'in_progress':
        bg = const Color(0xFFF5B800);
        fg = Colors.black87;
        label = 'In Progress';
        break;
      case 'completed':
        bg = const Color(0xFF2E9E3B);
        fg = Colors.white;
        label = 'Completed';
        break;
      case 'cancelled':
        bg = const Color(0xFFB0B0B0);
        fg = Colors.white;
        label = 'Cancelled';
        break;
      case 'overdue':
        bg = const Color(0xFFE09A9A);
        fg = const Color(0xFF7A1F1F);
        label = 'Overdue';
        break;
      case 'pending':
      default:
        bg = const Color(0xFFBFD4FF);
        fg = Colors.black87;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _actionButton() {
    // Tombol berdasarkan tipe + status MENTAH (bukan displayStatus),
    // overdue tidak punya aksi.
    String? label;
    Color? color;
    String? targetStatus;

    final raw = activity.status.toLowerCase();

    if (activity.isTask) {
      if (raw == 'pending') {
        label = 'Start';
        color = const Color(0xFFEA8000);
        targetStatus = 'in_progress';
      } else if (raw == 'in_progress') {
        label = 'Complete';
        color = const Color(0xFF2E9E3B);
        targetStatus = 'completed';
      }
    } else {
      if (raw == 'pending') {
        label = 'Cancel';
        color = const Color(0xFFC62828);
        targetStatus = 'cancelled'; // FIX: sebelumnya keliru jadi 'overdue'
      }
    }

    if (label == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () => onStatus(activity, targetStatus!),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
          child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }
}

class _AddActivitySheet extends StatefulWidget {
  final VoidCallback onCreated;

  const _AddActivitySheet({required this.onCreated});

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  String _type = 'task'; // 'task' | 'event'
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  DateTime? _date; // event: tanggal acara | task: deadline
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    final isTask = _type == 'task';
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Nama activity wajib diisi');
      return;
    }
    if (_date == null) {
      _snack(isTask ? 'Deadline wajib diisi' : 'Tanggal acara wajib diisi');
      return;
    }

    setState(() => _saving = true);
    try {
      await ActivityService.instance.create(
        type: _type,
        title: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        // Untuk task, activity_date = deadline (mengikuti perilaku web).
        activityDate: _fmtDate(_date!),
        deadline: isTask ? _fmtDate(_date!) : null,
        startTime: !isTask && _startTime != null ? _fmtTime(_startTime!) : null,
        endTime: !isTask && _endTime != null ? _fmtTime(_endTime!) : null,
        location: !isTask ? _locationCtrl.text.trim() : null,
      );
      if (!mounted) return;
      widget.onCreated();
    } on ApiException catch (e) {
      _snack(e.firstError);
    } catch (_) {
      _snack('Gagal menyimpan aktivitas. Periksa koneksi server.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTask = _type == 'task';
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Add Activity',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _typeOption('Task', 'task'),
                  const SizedBox(width: 10),
                  _typeOption('Event', 'event'),
                ],
              ),
              const SizedBox(height: 16),
              _field('Name', _nameCtrl),
              _field('Description', _descCtrl),
              _pickerTile(
                isTask ? 'Deadline' : 'Tanggal',
                _date != null ? _fmtDate(_date!) : 'Pilih tanggal',
                Icons.calendar_today_outlined,
                _pickDate,
              ),
              if (!isTask) ...[
                Row(
                  children: [
                    Expanded(
                      child: _pickerTile(
                        'Start',
                        _startTime != null ? _fmtTime(_startTime!) : '--:--',
                        Icons.access_time,
                        () => _pickTime(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _pickerTile(
                        'End',
                        _endTime != null ? _fmtTime(_endTime!) : '--:--',
                        Icons.access_time,
                        () => _pickTime(isStart: false),
                      ),
                    ),
                  ],
                ),
                _field('Location (cth: TULT)', _locationCtrl),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA8000),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : const Text('Save Activity',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeOption(String label, String type) {
    final selected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEA8000) : const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEA8000)),
          ),
        ),
      ),
    );
  }

  Widget _pickerTile(
      String label, String value, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black26),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.black45),
              const SizedBox(width: 10),
              Text('$label: ',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black54)),
              Expanded(
                child: Text(value,
                    style: const TextStyle(color: Colors.black87)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
