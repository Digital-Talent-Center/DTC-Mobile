import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';

enum ActivityType { task, event }

enum ActivityStatus { pending, inProgress, completed, overdue }

class Activity {
  ActivityType type;
  ActivityStatus status;
  String name;
  String description;
  String date;
  String? deadline; // untuk task
  String? time; // untuk event
  String? location; // untuk event

  Activity({
    required this.type,
    required this.status,
    required this.name,
    required this.description,
    required this.date,
    this.deadline,
    this.time,
    this.location,
  });
}

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  int _selectedTab = 0; // 0 = All, 1 = Events, 2 = Tasks
  final int _selectedNavIndex = 0;

  final List<Activity> _activities = [
    Activity(
      type: ActivityType.task,
      status: ActivityStatus.pending,
      name: 'Task Name',
      description: 'Task Description',
      date: 'Minggu, 31 Mei 2026',
      deadline: 'Senin, 1 Juni 2026',
    ),
    Activity(
      type: ActivityType.task,
      status: ActivityStatus.inProgress,
      name: 'Task Name',
      description: 'Task Description',
      date: 'Minggu, 31 Mei 2026',
      deadline: 'Senin, 1 Juni 2026',
    ),
    Activity(
      type: ActivityType.task,
      status: ActivityStatus.completed,
      name: 'Task Name',
      description: 'Task Description',
      date: 'Minggu, 31 Mei 2026',
      deadline: 'Senin, 1 Juni 2026',
    ),
    Activity(
      type: ActivityType.event,
      status: ActivityStatus.pending,
      name: 'Event Name',
      description: 'Event Description',
      date: 'Minggu, 31 Mei 2026',
      time: '00:00 - 02:00',
      location: 'TULT',
    ),
    Activity(
      type: ActivityType.event,
      status: ActivityStatus.overdue,
      name: 'Event Name',
      description: 'Event Description',
      date: 'Minggu, 31 Mei 2026',
      time: '00:00 - 02:00',
      location: 'TULT',
    ),
  ];

  List<Activity> get _filteredActivities {
    switch (_selectedTab) {
      case 1:
        return _activities.where((a) => a.type == ActivityType.event).toList();
      case 2:
        return _activities.where((a) => a.type == ActivityType.task).toList();
      default:
        return _activities;
    }
  }

  void _addActivity(Activity activity) {
    setState(() => _activities.add(activity));
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddActivitySheet(onSubmit: _addActivity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activities = _filteredActivities;

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
          Expanded(
            child: activities.isEmpty
                ? const Center(
                    child: Text(
                      'No activities',
                      style: TextStyle(color: Colors.black45),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: activities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _ActivityCard(
                        activity: activities[index],
                        onAction: () => setState(() {}),
                      );
                    },
                  ),
          ),
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
  final VoidCallback onAction;

  const _ActivityCard({required this.activity, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final isTask = activity.type == ActivityType.task;

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
          // Badges
          Row(
            children: [
              _typeBadge(isTask),
              const SizedBox(width: 8),
              _statusBadge(activity.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            activity.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            activity.description,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 14),
          // Date
          _infoRow(Icons.calendar_today_outlined, activity.date, Colors.black45,
              Colors.black54),
          // Task: deadline | Event: time + location
          if (isTask && activity.deadline != null) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.access_time, 'Deadline: ${activity.deadline}',
                const Color(0xFFEA8000), const Color(0xFFEA8000)),
          ],
          if (!isTask) ...[
            if (activity.time != null) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.access_time, activity.time!, Colors.black45,
                  Colors.black54),
            ],
            if (activity.location != null) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.location_on_outlined, activity.location!,
                  Colors.black45, Colors.black54),
            ],
          ],
          // Action button
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
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: textColor),
          ),
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

  Widget _statusBadge(ActivityStatus status) {
    late Color bg;
    late Color fg;
    late String label;

    switch (status) {
      case ActivityStatus.pending:
        bg = const Color(0xFFBFD4FF);
        fg = Colors.black87;
        label = 'Pending';
        break;
      case ActivityStatus.inProgress:
        bg = const Color(0xFFF5B800);
        fg = Colors.black87;
        label = 'In Progress';
        break;
      case ActivityStatus.completed:
        bg = const Color(0xFF2E9E3B);
        fg = Colors.white;
        label = 'Completed';
        break;
      case ActivityStatus.overdue:
        bg = const Color(0xFFE09A9A);
        fg = const Color(0xFF7A1F1F);
        label = 'Overdue';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _actionButton() {
    // Tentukan tombol berdasarkan tipe + status
    String? label;
    Color? color;
    VoidCallback? onPressed;

    if (activity.type == ActivityType.task) {
      if (activity.status == ActivityStatus.pending) {
        label = 'Start';
        color = const Color(0xFFEA8000);
        onPressed = () {
          activity.status = ActivityStatus.inProgress;
          onAction();
        };
      } else if (activity.status == ActivityStatus.inProgress) {
        label = 'Complete';
        color = const Color(0xFF2E9E3B);
        onPressed = () {
          activity.status = ActivityStatus.completed;
          onAction();
        };
      }
    } else {
      if (activity.status == ActivityStatus.pending) {
        label = 'Cancel';
        color = const Color(0xFFC62828);
        onPressed = () {
          activity.status = ActivityStatus.overdue;
          onAction();
        };
      }
    }

    if (label == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class _AddActivitySheet extends StatefulWidget {
  final ValueChanged<Activity> onSubmit;

  const _AddActivitySheet({required this.onSubmit});

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  ActivityType _type = ActivityType.task;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    _deadlineCtrl.dispose();
    _timeCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama activity wajib diisi')),
      );
      return;
    }

    final isTask = _type == ActivityType.task;
    widget.onSubmit(
      Activity(
        type: _type,
        status: ActivityStatus.pending,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _dateCtrl.text.trim().isEmpty ? '-' : _dateCtrl.text.trim(),
        deadline: isTask ? _deadlineCtrl.text.trim() : null,
        time: isTask ? null : _timeCtrl.text.trim(),
        location: isTask ? null : _locationCtrl.text.trim(),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isTask = _type == ActivityType.task;
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
              const Text(
                'Add Activity',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              // Type selector
              Row(
                children: [
                  _typeOption('Task', ActivityType.task),
                  const SizedBox(width: 10),
                  _typeOption('Event', ActivityType.event),
                ],
              ),
              const SizedBox(height: 16),
              _field('Name', _nameCtrl),
              _field('Description', _descCtrl),
              _field('Date (cth: Minggu, 31 Mei 2026)', _dateCtrl),
              if (isTask)
                _field('Deadline (cth: Senin, 1 Juni 2026)', _deadlineCtrl)
              else ...[
                _field('Time (cth: 00:00 - 02:00)', _timeCtrl),
                _field('Location (cth: TULT)', _locationCtrl),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA8000),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Activity',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeOption(String label, ActivityType type) {
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEA8000)),
          ),
        ),
      ),
    );
  }
}
