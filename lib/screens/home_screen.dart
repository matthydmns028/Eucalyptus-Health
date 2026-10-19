import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/day_data.dart';
import '../core/models.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import '../widgets/home_widgets.dart';
import '../widgets/sheets.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.patient});

  final Patient patient;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Everything the dashboard shows for the selected day.
class _View {
  const _View({
    required this.hr,
    required this.hrSeries,
    required this.sys,
    required this.dia,
    required this.glucose,
    required this.glucoseCtx,
    required this.sleepMin,
    required this.deepMin,
    required this.sleepScore,
    required this.spo2,
    required this.water,
    required this.tasks,
    required this.pct,
  });

  final int? hr;
  final List<int> hrSeries;
  final int? sys;
  final int? dia;
  final int? glucose;
  final String glucoseCtx;
  final int? sleepMin;
  final int? deepMin;
  final int? sleepScore;
  final int? spo2;
  final double water;
  final List<RoutineTask> tasks;
  final int pct;
}

class _HomeScreenState extends State<HomeScreen> {
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const double _waterGoal = 2.5;

  final _scroll = ScrollController();
  final _rng = math.Random();

  int _tab = 0;
  bool _unread = true;
  bool _syncing = false;
  bool _biometric = true;
  late final List<DateTime> _week;
  late final int _todayIndex;
  late int _selectedDay;

  // live (today) state
  final List<int> _hr = [70, 68, 71, 69, 73, 70, 72];
  int _sys = 118;
  int _dia = 76;
  int _glucose = 95;
  String _glucoseCtx = 'Fasting';
  int _spo2 = 98;
  double _water = 1.5;
  int _nextTaskId = 5;
  final List<NoteEntry> _notes = [];
  late final List<RoutineTask> _tasks = _baseTasks();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    _week = List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day + i));
    _todayIndex = now.weekday - 1;
    _selectedDay = _todayIndex;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  List<RoutineTask> _baseTasks() => [
        RoutineTask(
          id: '1',
          title: 'Morning Medication',
          subtitle: 'Lisinopril 10mg • Taken with breakfast',
          tag: '8:00 AM',
          icon: Icons.medication_outlined,
          kind: TaskKind.medication,
          dose: 'Lisinopril 10mg',
          at: const TimeOfDay(hour: 8, minute: 0),
          done: true,
        ),
        RoutineTask(
          id: '2',
          title: 'Blood Glucose Log',
          subtitle: 'Logged 95 mg/dL • In target range',
          tag: 'Fasting',
          icon: Icons.bloodtype_outlined,
          kind: TaskKind.glucose,
          done: true,
        ),
        RoutineTask(
          id: '3',
          title: 'Hydration Target',
          subtitle: '',
          icon: Icons.water_drop_outlined,
          kind: TaskKind.hydration,
        ),
        RoutineTask(
          id: '4',
          title: 'Evening Medication',
          subtitle: 'Atorvastatin 20mg • Take after dinner',
          tag: '9:00 PM',
          icon: Icons.notifications_active_outlined,
          kind: TaskKind.medication,
          dose: 'Atorvastatin 20mg',
          at: const TimeOfDay(hour: 21, minute: 0),
        ),
      ];

  // ───────── derived state ─────────

  bool get _isToday => _selectedDay == _todayIndex;
  bool get _isFuture => _selectedDay > _todayIndex;

  int get _heartRate => _hr.last;
  int get _hrDelta => _hr.length < 2 ? 0 : _hr.last - _hr[_hr.length - 2];

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _fmtDate(DateTime d) => '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';

  String _nowLabel() => TimeOfDay.fromDateTime(DateTime.now()).format(context);

  (int, int) _glucoseTarget(String ctx) => switch (ctx) {
        'Before meal' => (70, 130),
        'After meal' => (70, 140),
        'Bedtime' => (90, 150),
        _ => (70, 99),
      };

  (String, Color) _bpCategory(int s, int d) {
    if (s < 120 && d < 80) return ('Optimal Range', AppColors.primary);
    if (s < 130 && d < 80) return ('Elevated', AppColors.amber);
    return ('High', AppColors.danger);
  }

  int _pctFor(List<RoutineTask> tasks, double water) {
    if (tasks.isEmpty) return 0;
    final sum = tasks.fold<double>(0, (acc, t) {
      if (t.kind == TaskKind.hydration) return acc + math.min(water / _waterGoal, 1.0);
      return acc + (t.done ? 1 : 0);
    });
    return (sum / tasks.length * 100).round();
  }

  bool _isDone(RoutineTask t, double water) => t.kind == TaskKind.hydration ? water >= _waterGoal : t.done;

  List<RoutineTask> _tasksFor(DaySnapshot? s) {
    final t = _baseTasks();
    t[0]
      ..done = s?.medDone ?? false
      ..subtitle = s == null
          ? 'Lisinopril 10mg • Scheduled'
          : (s.medDone ? 'Lisinopril 10mg • Taken' : 'Lisinopril 10mg • Missed');
    t[1]
      ..done = s?.glucoseDone ?? false
      ..subtitle = s == null
          ? 'Scheduled'
          : (s.glucoseDone ? 'Logged ${s.glucose} mg/dL • In target range' : 'Not logged');
    t[3]
      ..done = s?.eveningDone ?? false
      ..subtitle = s == null
          ? 'Atorvastatin 20mg • Scheduled'
          : (s.eveningDone ? 'Atorvastatin 20mg • Taken' : 'Atorvastatin 20mg • Missed');
    return t;
  }

  _View _view() {
    if (_isToday) {
      return _View(
        hr: _heartRate,
        hrSeries: List<int>.of(_hr),
        sys: _sys,
        dia: _dia,
        glucose: _glucose,
        glucoseCtx: _glucoseCtx,
        sleepMin: 465,
        deepMin: 130,
        sleepScore: 92,
        spo2: _spo2,
        water: _water,
        tasks: _tasks,
        pct: _pctFor(_tasks, _water),
      );
    }
    if (_isFuture) {
      final t = _tasksFor(null);
      return _View(
        hr: null,
        hrSeries: const [],
        sys: null,
        dia: null,
        glucose: null,
        glucoseCtx: 'Fasting',
        sleepMin: null,
        deepMin: null,
        sleepScore: null,
        spo2: null,
        water: 0,
        tasks: t,
        pct: 0,
      );
    }
    final s = snapshotFor(_week[_selectedDay]);
    final t = _tasksFor(s);
    return _View(
      hr: s.hr,
      hrSeries: s.hrSeries,
      sys: s.sys,
      dia: s.dia,
      glucose: s.glucose,
      glucoseCtx: 'Fasting',
      sleepMin: s.sleepMin,
      deepMin: s.deepMin,
      sleepScore: s.sleepScore,
      spo2: 97,
      water: s.water,
      tasks: t,
      pct: _pctFor(t, s.water),
    );
  }

  List<SummaryRow> _rows(_View v) {
    final (lo, hi) = _glucoseTarget(v.glucoseCtx);
    final (bpLabel, _) = _bpCategory(v.sys!, v.dia!);
    return [
      SummaryRow('Resting heart rate', '${v.hr} bpm', '60–100 bpm', v.hr! >= 60 && v.hr! <= 100),
      SummaryRow('Blood pressure', '${v.sys}/${v.dia} mmHg', 'Below 120/80', bpLabel == 'Optimal Range'),
      SummaryRow('Blood glucose (${v.glucoseCtx.toLowerCase()})', '${v.glucose} mg/dL', '$lo–$hi mg/dL', v.glucose! >= lo && v.glucose! <= hi),
      SummaryRow('Oxygen saturation', '${v.spo2}%', '95–100%', v.spo2! >= 95),
      SummaryRow('Sleep', fmtMinutes(v.sleepMin!), '7–9 hours', v.sleepMin! >= 420),
    ];
  }

  // ───────── actions ─────────

  bool _requireToday() {
    if (_isToday) return true;
    showAppSnack(context, 'Past and future days are read-only. Tap Today to make changes.');
    return false;
  }

  void _jumpToToday() => setState(() => _selectedDay = _todayIndex);

  void _logoTap() {
    if (_tab == 0 && _scroll.hasClients) {
      _scroll.animateTo(0, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    }
  }

  Future<void> _refresh() async {
    if (_syncing) return;
    HapticFeedback.lightImpact();
    setState(() => _syncing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _syncing = false;
      _hr.add(math.min(math.max(_heartRate + _rng.nextInt(5) - 2, 58), 92));
      if (_hr.length > 8) _hr.removeAt(0);
    });
    showAppSnack(context, 'Vitals synced');
  }

  void _toggle(RoutineTask t) {
    if (!_requireToday()) return;
    HapticFeedback.selectionClick();
    setState(() {
      t.done = !t.done;
      if (t.kind == TaskKind.medication && t.dose != null) {
        t.subtitle = t.done ? '${t.dose} • Taken at ${_nowLabel()}' : '${t.dose} • Due ${t.tag ?? 'today'}';
      } else if (t.kind == TaskKind.glucose) {
        t.subtitle = t.done ? _glucoseSubtitle() : 'Not logged yet';
      }
    });
  }

  String _glucoseSubtitle() {
    final (lo, hi) = _glucoseTarget(_glucoseCtx);
    final status = _glucose < lo ? 'Below target' : (_glucose > hi ? 'Above target' : 'In target range');
    return 'Logged $_glucose mg/dL • $status';
  }

  void _syncGlucoseTask() {
    for (final t in _tasks) {
      if (t.kind == TaskKind.glucose) {
        t.done = true;
        t.tag = _glucoseCtx;
        t.subtitle = _glucoseSubtitle();
      }
    }
  }

  void _addWater() {
    if (!_requireToday()) return;
    if (_water >= _waterGoal) {
      showAppSnack(context, "You've reached today's hydration goal");
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _water = math.min(_water + 0.25, _waterGoal));
  }

  Future<void> _reminder(RoutineTask t) async {
    if (!_requireToday()) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: t.at ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Reminder time',
    );
    if (picked == null || !mounted) return;
    final label = picked.format(context);
    setState(() {
      t.at = picked;
      t.tag = label;
      if (!t.done && t.dose != null) t.subtitle = '${t.dose} • Due $label';
    });
    showAppSnack(context, 'Reminder set for $label');
  }

  Future<void> _editGlucose() async {
    if (!_requireToday()) return;
    final e = await showAppSheet<GlucoseEntry>(
      context,
      builder: (_) => GlucoseSheet(value: _glucose, glucoseContext: _glucoseCtx),
    );
    if (e == null || !mounted) return;
    setState(() {
      _glucose = e.value;
      _glucoseCtx = e.context;
      _syncGlucoseTask();
    });
    showAppSnack(context, 'Glucose entry updated');
  }

  Future<void> _logVital() async {
    final e = await showAppSheet<VitalEntry>(context, builder: (_) => const QuickVitalSheet());
    if (e == null || !mounted) return;
    var msg = '';
    setState(() {
      _selectedDay = _todayIndex;
      switch (e.type) {
        case VitalType.heartRate:
          _hr.add(e.a);
          if (_hr.length > 8) _hr.removeAt(0);
          msg = 'Heart rate logged: ${e.a} bpm';
        case VitalType.bloodPressure:
          _sys = e.a;
          _dia = e.b ?? _dia;
          msg = 'Blood pressure logged: $_sys/$_dia mmHg';
        case VitalType.spo2:
          _spo2 = e.a;
          msg = 'SpO2 logged: ${e.a}%';
        case VitalType.glucose:
          _glucose = e.a;
          _syncGlucoseTask();
          msg = 'Blood sugar logged: ${e.a} mg/dL';
      }
    });
    showAppSnack(context, msg);
  }

  Future<void> _addNote() async {
    final n = await showAppSheet<NoteEntry>(context, builder: (_) => const NoteSheet());
    if (n == null || !mounted) return;
    setState(() => _notes.add(n));
    showAppSnack(context, 'Note saved to your journal');
  }

  Future<void> _scan() async {
    final ok = await showScannerSheet(context);
    if (ok == true && mounted) {
      showAppSnack(context, 'Lab report added to your Records vault (demo)');
    }
  }

  Future<void> _addTask() async {
    final r = await showAppSheet<NewRoutine>(context, builder: (_) => const AddRoutineSheet());
    if (r == null || !mounted) return;
    final tag = r.time?.format(context);
    setState(() {
      _selectedDay = _todayIndex;
      _tasks.add(RoutineTask(
        id: '${_nextTaskId++}',
        title: r.name,
        subtitle: r.medication ? '${r.name} • Due ${tag ?? 'today'}' : 'Daily habit',
        icon: r.medication ? Icons.medication_outlined : Icons.task_alt_outlined,
        kind: r.medication ? TaskKind.medication : TaskKind.habit,
        dose: r.medication ? r.name : null,
        tag: tag,
        at: r.time,
      ));
    });
  }

  void _openSummary(_View v) {
    if (_isFuture) {
      showAppSnack(context, 'No readings recorded for this day yet');
      return;
    }
    showVitalsSummary(context, rows: _rows(v), dateLabel: _isToday ? 'Today, ${_fmtDate(_week[_selectedDay])}' : _fmtDate(_week[_selectedDay]));
  }

  void _openAppointment() {
    showAppointmentDetail(
      context,
      onDirections: () => showDirectionsSheet(context),
      onDossier: () => showDossier(context, notes: _notes),
    );
  }

  void _openNotifications() {
    setState(() => _unread = false);
    showNotificationsSheet(context);
  }

  Future<void> _openProfile() async {
    final out = await showAppSheet<bool>(
      context,
      builder: (_) => ProfileSheet(
        patient: widget.patient,
        biometric: _biometric,
        onBiometric: (v) => _biometric = v,
      ),
    );
    if (out == true && mounted) {
      Navigator.of(context).pushReplacement(softRoute(const LoginScreen()));
    }
  }

  void _metricInfo(IconData icon, String title, String desc) =>
      showComingSoon(context, icon: icon, title: title, description: desc);

  // ───────── build ─────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        bottomNavigationBar: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AppBottomNav(index: _tab, onChanged: (i) => setState(() => _tab = i)),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFDDF2E6), Color(0xFFF1F9F5), Color(0xFFF6FBF8)],
              stops: [0, 0.35, 1],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: IndexedStack(
                  index: _tab,
                  children: [
                    _homePage(),
                    const _TabPlaceholder(icon: Icons.monitor_heart_rounded, title: 'Metrics', subtitle: 'Health Metrics & Condition Charts'),
                    const _TabPlaceholder(icon: Icons.calendar_month_rounded, title: 'Visits', subtitle: 'Doctor Visits & Appointments'),
                    const _TabPlaceholder(icon: Icons.folder_open_rounded, title: 'Records', subtitle: 'Medical Records & Health Vault'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pad(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: child);

  Widget _homePage() {
    final v = _view();
    final selected = _week[_selectedDay];
    final subtitle = _isToday
        ? "You're ${v.pct}% through today's health goals"
        : _isFuture
            ? 'Scheduled for ${_fmtDate(selected)}'
            : '${v.pct}% of goals completed on ${_fmtDate(selected)}';
    return Column(
      children: [
        _header(),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.only(top: 8, bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Reveal(
                  index: 0,
                  child: _pad(Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: _statusPill(v)),
                      const SizedBox(width: 12),
                      if (!_isToday) ...[
                        Pressable(
                          onTap: _jumpToToday,
                          semanticLabel: 'Back to today',
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 44),
                            child: const Center(
                              widthFactor: 1,
                              child: Pill('Today', bg: AppColors.deep, fg: Colors.white, icon: Icons.undo_rounded, fontSize: 11.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(_fmtDate(selected), style: appText(13, weight: FontWeight.w600, color: AppColors.muted)),
                    ],
                  )),
                ),
                const SizedBox(height: 10),
                Reveal(
                  index: 1,
                  child: _pad(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$_greeting, ${widget.patient.firstName} 👋',
                          style: appText(30, weight: FontWeight.w800, letterSpacing: -0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle, style: appText(14.5, color: AppColors.muted)),
                    ],
                  )),
                ),
                const SizedBox(height: 18),
                Reveal(
                  index: 2,
                  child: _pad(WeekStrip(
                    days: _week,
                    selected: _selectedDay,
                    onSelect: (i) => setState(() => _selectedDay = i),
                  )),
                ),
                const SizedBox(height: 18),
                Reveal(
                  index: 3,
                  child: _pad(ConsultationCard(
                    onOpen: _openAppointment,
                    onDetails: () => showDossier(context, notes: _notes),
                    onDirections: () => showDirectionsSheet(context),
                  )),
                ),
                const SizedBox(height: 16),
                Reveal(index: 4, child: _quickActions()),
                const SizedBox(height: 26),
                Reveal(index: 5, child: _vitalsSection(v)),
                const SizedBox(height: 26),
                Reveal(index: 6, child: _routineSection(v)),
                const SizedBox(height: 20),
                Reveal(index: 7, child: _pad(InsightCard(onTap: () => showInsightsSheet(context)))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Pressable(
                onTap: _logoTap,
                onDoubleTap: _refresh,
                scale: 0.98,
                semanticLabel: 'Eucalyptus Health home. Tap to scroll to top, double tap to refresh vitals.',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(13)),
                      child: const Icon(Icons.eco_rounded, size: 22, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EUCALYPTUS HEALTH',
                          style: appText(10.5, weight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.8),
                        ),
                        Text('Home', style: appText(20, weight: FontWeight.w800, letterSpacing: -0.3)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Pressable(
            onTap: _openNotifications,
            semanticLabel: _unread ? 'Notifications, unread' : 'Notifications',
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_none_rounded, size: 22, color: AppColors.ink),
                  ),
                  Positioned(
                    top: 8,
                    right: 9,
                    child: AnimatedScale(
                      scale: _unread ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5484D),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),
          Pressable(
            onTap: _openProfile,
            semanticLabel: 'Profile and account settings',
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(child: InitialsAvatar(widget.patient.initials, size: 42)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(_View v) {
    final Widget pill;
    if (_isFuture) {
      pill = const Pill('No readings yet', key: ValueKey('future'), bg: AppColors.mintSoft, fg: AppColors.muted, dot: true, fontSize: 12);
    } else {
      final bad = _rows(v).where((r) => !r.ok).toList();
      if (bad.isEmpty) {
        pill = Pill(
          _isToday ? 'Vitals Stable • All clear' : 'All clear that day',
          key: const ValueKey('ok'),
          bg: AppColors.mint,
          fg: AppColors.primary,
          dot: true,
          fontSize: 12,
        );
      } else {
        final text = bad.length == 1 ? '${bad.first.label} needs attention' : '${bad.length} readings need attention';
        pill = Pill(text, key: ValueKey('warn${bad.length}'), bg: AppColors.amberSoft, fg: AppColors.amber, dot: true, fontSize: 12);
      }
    }
    return Pressable(
      onTap: () => _openSummary(v),
      semanticLabel: 'Open vitals summary',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: pill),
        ),
      ),
    );
  }

  Widget _quickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          QuickAction(icon: Icons.add_circle_outline_rounded, label: 'Log Vital', filled: true, onTap: _logVital),
          const SizedBox(width: 10),
          QuickAction(icon: Icons.edit_note_rounded, label: 'Add Note', onTap: _addNote),
          const SizedBox(width: 10),
          QuickAction(icon: Icons.document_scanner_outlined, label: 'Scan Report', onTap: _scan),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {Widget? chip, Widget? trailing}) {
    return Row(
      children: [
        Flexible(child: Text(title, style: appText(21, weight: FontWeight.w800, letterSpacing: -0.4))),
        if (chip != null) ...[const SizedBox(width: 10), chip],
        if (trailing != null) ...[const Spacer(), trailing],
      ],
    );
  }

  Widget _vitalsSection(_View v) {
    final noData = v.hr == null;
    final bp = noData ? null : _bpCategory(v.sys!, v.dia!);
    final (lo, hi) = _glucoseTarget(v.glucoseCtx);

    final Widget chip = _syncing
        ? const Pill('Syncing…', key: ValueKey('sync'), bg: AppColors.mint, fg: AppColors.primary, icon: Icons.sync_rounded, fontSize: 10.5)
        : _isToday
            ? const Pill('Live Sync', key: ValueKey('live'), bg: AppColors.mint, fg: AppColors.primary, fontSize: 10.5)
            : Pill(_isFuture ? 'Scheduled' : 'History', key: const ValueKey('hist'), bg: AppColors.mintSoft, fg: AppColors.muted, fontSize: 10.5);

    return _pad(Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(
          _isToday ? 'Vitals Today' : 'Vitals · ${_weekdays[_selectedDay]}',
          chip: AnimatedSwitcher(duration: const Duration(milliseconds: 180), child: chip),
          trailing: Pressable(
            onTap: () => setState(() => _tab = 1),
            semanticLabel: 'View trends in Metrics',
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Trends', style: appText(13.5, weight: FontWeight.w700, color: AppColors.primary)),
                  const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: VitalCard(
                  onTap: () => _metricInfo(Icons.favorite_border_rounded, 'Heart rate deep dive', 'ECG history and resting vs. active heart rate trends.'),
                  semanticLabel: 'Heart rate ${v.hr ?? 'no data'}. Open details.',
                  icon: Icons.favorite_border_rounded,
                  iconColor: AppColors.danger,
                  iconBg: AppColors.dangerSoft,
                  badge: (_isToday && !noData)
                      ? Pill(
                          '${_hrDelta >= 0 ? '+' : ''}$_hrDelta bpm',
                          bg: AppColors.mint,
                          fg: AppColors.primary,
                          fontSize: 10.5,
                        )
                      : null,
                  value: v.hr?.toString() ?? '—',
                  unit: noData ? null : 'bpm',
                  caption: noData ? 'No data yet' : 'Resting Heart Rate',
                  footer: v.hrSeries.length >= 2 ? Sparkline(values: v.hrSeries) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VitalCard(
                  onTap: () => _metricInfo(Icons.speed_rounded, 'Blood pressure analytics', 'Hypertension tracking with systolic and diastolic trends over time.'),
                  semanticLabel: 'Blood pressure ${noData ? 'no data' : '${v.sys} over ${v.dia}'}. Open details.',
                  icon: Icons.speed_rounded,
                  iconColor: AppColors.primary,
                  iconBg: AppColors.mint,
                  badge: Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: bp == null ? AppColors.line : bp.$2,
                      shape: BoxShape.circle,
                    ),
                  ),
                  value: noData ? '—' : '${v.sys}/${v.dia}',
                  unit: noData ? null : 'mmHg',
                  caption: bp?.$1 ?? 'No data yet',
                  captionColor: bp?.$2 ?? AppColors.muted,
                  captionWeight: FontWeight.w700,
                  footer: noData
                      ? null
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sys ${v.sys}', style: appText(11.5, color: AppColors.muted)),
                            Text('Dia ${v.dia}', style: appText(11.5, color: AppColors.muted)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: VitalCard(
                  onTap: () => _metricInfo(Icons.water_drop_outlined, 'Glucose & glycemic log', 'Fasting blood sugar and glycemic history, grouped by when you measured.'),
                  semanticLabel: 'Blood glucose ${v.glucose ?? 'no data'}. Open details.',
                  icon: Icons.water_drop_outlined,
                  iconColor: AppColors.blue,
                  iconBg: AppColors.blueSoft,
                  badge: noData ? null : Pill(v.glucoseCtx, bg: AppColors.blueSoft, fg: AppColors.blue, fontSize: 10.5),
                  value: v.glucose?.toString() ?? '—',
                  unit: noData ? null : 'mg/dL',
                  caption: noData ? 'No data yet' : 'Target ($lo–$hi)',
                  footer: noData ? null : ProgressBar(value: clamp01(v.glucose! / 150)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VitalCard(
                  onTap: () => _metricInfo(Icons.bedtime_outlined, 'Sleep analysis', 'Sleep stages and circadian rhythm over the past weeks.'),
                  semanticLabel: 'Sleep ${v.sleepMin == null ? 'no data' : fmtMinutes(v.sleepMin!)}. Open details.',
                  icon: Icons.bedtime_outlined,
                  iconColor: const Color(0xFF4B5B8F),
                  iconBg: const Color(0xFFE8ECF8),
                  badge: v.sleepScore == null ? null : Pill('${v.sleepScore}% score', bg: AppColors.mint, fg: AppColors.primary, fontSize: 10.5),
                  value: v.sleepMin == null ? '—' : fmtMinutes(v.sleepMin!),
                  caption: v.deepMin == null ? 'No data yet' : 'Deep Sleep: ${fmtMinutes(v.deepMin!)}',
                  footer: v.sleepMin == null ? null : const SegmentedBar(),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _routineSection(_View v) {
    final done = v.tasks.where((t) => _isDone(t, v.water)).length;
    return _pad(Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(
          'Daily Care Routine',
          chip: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Pill(
              '$done of ${v.tasks.length} done',
              key: ValueKey('$_selectedDay-$done/${v.tasks.length}'),
              bg: AppColors.mint,
              fg: AppColors.primary,
              fontSize: 10.5,
            ),
          ),
          trailing: Pressable(
            onTap: _addTask,
            semanticLabel: 'Add medication or habit',
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.add_rounded, size: 26, color: AppColors.muted),
            ),
          ),
        ),
        const SizedBox(height: 6),
        for (final t in v.tasks) ...[
          TaskTile(
            key: ValueKey('${t.id}-$_selectedDay'),
            task: t,
            water: v.water,
            waterGoal: _waterGoal,
            onToggle: () => _toggle(t),
            onOpen: () => t.kind == TaskKind.glucose ? _editGlucose() : _toggle(t),
            onTrailing: switch (t.kind) {
              TaskKind.medication => () => _reminder(t),
              TaskKind.glucose => _editGlucose,
              _ => null,
            },
            onAddWater: _addWater,
          ),
          const SizedBox(height: 12),
        ],
      ],
    ));
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(24)),
            child: Icon(icon, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(title, style: appText(22, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, style: appText(14, color: AppColors.muted)),
          const SizedBox(height: 2),
          Text('Coming in the next build', style: appText(12.5, color: AppColors.muted)),
        ],
      ),
    );
  }
}
