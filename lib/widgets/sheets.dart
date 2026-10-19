import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/models.dart';
import '../core/theme.dart';
import 'app_field.dart';
import 'common.dart';
import 'home_widgets.dart';

// ───────────────────────── shared bits ─────────────────────────

class SheetHeader extends StatelessWidget {
  const SheetHeader(this.title, [this.subtitle]);

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: appText(22, weight: FontWeight.w800, letterSpacing: -0.4)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: appText(14, color: AppColors.muted, height: 1.4)),
          ],
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow(this.icon, this.label, this.value, {super.key});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.mintSoft, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: appText(12, weight: FontWeight.w700, color: AppColors.muted)),
                const SizedBox(height: 2),
                Text(value, style: appText(14.5, weight: FontWeight.w600, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.mintSoft,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 20, color: AppColors.ink), const SizedBox(width: 8)],
            Text(label, style: appText(15, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// Row with a link and a copy button. Shows "Copied" in place (a snackbar
/// would be hidden behind the sheet).
class CopyRow extends StatefulWidget {
  const CopyRow({super.key, required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  State<CopyRow> createState() => _CopyRowState();
}

class _CopyRowState extends State<CopyRow> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) return;
    setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.mintSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(widget.icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label, style: appText(12, weight: FontWeight.w700, color: AppColors.muted)),
                Text(widget.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: appText(13, weight: FontWeight.w600)),
              ],
            ),
          ),
          Pressable(
            onTap: _copy,
            semanticLabel: 'Copy ${widget.label}',
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              child: Text(
                _copied ? 'Copied ✓' : 'Copy',
                style: appText(13, weight: FontWeight.w800, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── generic ─────────────────────────

Future<void> showComingSoon(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String description,
}) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(18)),
          child: Icon(icon, size: 26, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(title, style: appText(22, weight: FontWeight.w800, letterSpacing: -0.4)),
        const SizedBox(height: 8),
        Text(description, style: appText(14, color: AppColors.muted, height: 1.45)),
        const SizedBox(height: 14),
        const Pill('Arrives with a later screen', bg: AppColors.mintSoft, fg: AppColors.primary, fontSize: 11.5),
        const SizedBox(height: 22),
        PrimaryButton(label: 'Got it', onPressed: () => Navigator.of(ctx).pop()),
      ],
    ),
  );
}

// ───────────────────────── login ─────────────────────────

Future<bool?> showSsoSheet(BuildContext context, {required String provider, required String name, required String email}) {
  return showAppSheet<bool>(
    context,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHeader('Continue with $provider', 'Choose the account linked to your Eucalyptus Health profile. (Demo account chooser)'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              InitialsAvatar(name.split(' ').map((w) => w[0]).join(), size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: appText(15, weight: FontWeight.w700)),
                    Text(email, style: appText(12.5, color: AppColors.muted), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Continue as ${name.split(' ').first}', onPressed: () => Navigator.of(ctx).pop(true)),
        const SizedBox(height: 10),
        SecondaryButton(label: 'Cancel', onPressed: () => Navigator.of(ctx).pop(false)),
      ],
    ),
  );
}

// ───────────────────────── home: header ─────────────────────────

Future<void> showNotificationsSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetHeader('Notifications & Alerts'),
        const InfoRow(Icons.medication_outlined, 'Medication reminder', 'Atorvastatin 20mg is due at 9:00 PM.'),
        const InfoRow(Icons.chat_bubble_outline_rounded, 'Message from Dr. Mitchell', 'Please confirm you will be fasting before tomorrow\'s visit.'),
        const InfoRow(Icons.science_outlined, 'Lab result released', 'Your Comprehensive Metabolic Panel is ready to view.'),
        const SizedBox(height: 4),
        PrimaryButton(label: 'Done', onPressed: () => Navigator.of(ctx).pop()),
      ],
    ),
  );
}

class ProfileSheet extends StatefulWidget {
  const ProfileSheet({super.key, required this.patient, required this.biometric, required this.onBiometric});

  final Patient patient;
  final bool biometric;
  final ValueChanged<bool> onBiometric;

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  late bool _bio = widget.biometric;

  Widget _row(IconData icon, String label, String desc, String soonTitle, String soonDesc) {
    return Pressable(
      onTap: () => showComingSoon(context, icon: icon, title: soonTitle, description: soonDesc),
      scale: 0.985,
      semanticLabel: label,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: AppColors.mintSoft, shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: appText(14.5, weight: FontWeight.w700)),
                  Text(desc, style: appText(12.5, color: AppColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            InitialsAvatar(p.initials, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.fullName, style: appText(20, weight: FontWeight.w800, letterSpacing: -0.3)),
                  const SizedBox(height: 2),
                  Text('${p.email} · ${p.patientId}', style: appText(12.5, color: AppColors.muted), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _row(Icons.person_outline_rounded, 'Personal information', 'Name, date of birth, contact', 'Personal information', 'Edit your name, date of birth and contact details.'),
        _row(Icons.contact_phone_outlined, 'Emergency contacts', 'People we call in an emergency', 'Emergency contacts', 'Manage the people your care team can reach in an emergency.'),
        _row(Icons.shield_outlined, 'Insurance details', 'Plan, member ID, copay', 'Insurance details', 'View and update your insurance plan and member ID.'),
        Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: AppColors.mintSoft, shape: BoxShape.circle),
                child: const Icon(Icons.face_rounded, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Biometric unlock', style: appText(14.5, weight: FontWeight.w700)),
                    Text('Face ID / fingerprint sign-in', style: appText(12.5, color: AppColors.muted)),
                  ],
                ),
              ),
              Semantics(
                label: 'Biometric unlock',
                child: Switch(
                  value: _bio,
                  onChanged: (v) {
                    setState(() => _bio = v);
                    widget.onBiometric(v);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Pressable(
          onTap: () => Navigator.of(context).pop(true),
          semanticLabel: 'Sign out',
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout_rounded, size: 20, color: AppColors.danger),
                const SizedBox(width: 8),
                Text('Sign out', style: appText(15, weight: FontWeight.w700, color: AppColors.danger)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── home: summary / consultation ─────────────────────────

Future<void> showVitalsSummary(BuildContext context, {required List<SummaryRow> rows, required String dateLabel}) {
  final attention = rows.where((r) => !r.ok).length;
  return showAppSheet<void>(
    context,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHeader('Vitals summary', dateLabel),
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: r.ok ? AppColors.accent : const Color(0xFFE5A100),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.label, style: appText(14.5, weight: FontWeight.w700)),
                      Text('Healthy range: ${r.range}', style: appText(12, color: AppColors.muted)),
                    ],
                  ),
                ),
                Text(r.value, style: appText(14.5, weight: FontWeight.w800)),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: attention == 0 ? AppColors.mintSoft : AppColors.amberSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Doctor review note', style: appText(12, weight: FontWeight.w800, color: attention == 0 ? AppColors.primary : AppColors.amber)),
              const SizedBox(height: 4),
              Text(
                attention == 0
                    ? 'All readings are within your target ranges. Keep up the current routine — Dr. Mitchell will review trends at your visit.'
                    : '$attention reading${attention == 1 ? '' : 's'} outside the usual range. Re-check after resting for 5 minutes and share the result with Dr. Mitchell.',
                style: appText(13, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Done', onPressed: () => Navigator.of(ctx).pop()),
      ],
    ),
  );
}

Future<void> showAppointmentDetail(
  BuildContext context, {
  required VoidCallback onDirections,
  required VoidCallback onDossier,
}) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetHeader('Dr. Sarah Mitchell', 'Cardiology follow-up'),
        const InfoRow(Icons.schedule_rounded, 'When', 'Tomorrow, 10:30 AM'),
        const InfoRow(Icons.local_hospital_outlined, 'Where', 'St. Jude Health Center\n1200 Medical Plaza Dr, Suite 400'),
        const InfoRow(Icons.checklist_rounded, 'Preparation', 'No food for 8 hours (water is fine) · Bring your medication list · Wear a short-sleeved top'),
        const InfoRow(Icons.person_outline_rounded, 'About the physician', 'Board-certified cardiologist with 15 years of experience in hypertension and preventive heart care.'),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Dossier',
                icon: Icons.folder_open_rounded,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onDossier();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                label: 'Directions',
                icon: Icons.near_me_outlined,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onDirections();
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> showDossier(BuildContext context, {required List<NoteEntry> notes}) {
  String when(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
  }

  return showAppSheet<void>(
    context,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetHeader('Consultation dossier', 'Everything Dr. Mitchell will see before your visit.'),
        Text('Pre-visit questionnaire', style: appText(14.5, weight: FontWeight.w800)),
        const SizedBox(height: 8),
        const ProgressBar(value: 0.6, color: AppColors.accent),
        const SizedBox(height: 6),
        Text('3 of 5 sections complete', style: appText(12.5, color: AppColors.muted)),
        const SizedBox(height: 18),
        Text('Symptoms you logged', style: appText(14.5, weight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (notes.isEmpty)
          Text('Nothing yet. Use Add Note on the home screen to log symptoms.', style: appText(13, color: AppColors.muted, height: 1.4))
        else
          for (final n in notes.reversed.take(4))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Pill('Pain ${n.pain}/10', bg: n.pain >= 7 ? AppColors.dangerSoft : AppColors.mintSoft, fg: n.pain >= 7 ? AppColors.danger : AppColors.primary, fontSize: 10.5),
                  const SizedBox(width: 10),
                  Expanded(child: Text('${n.text}  ·  ${when(n.time)}', style: appText(13, height: 1.35))),
                ],
              ),
            ),
        const SizedBox(height: 14),
        const CopyRow(label: 'Telehealth link', value: 'https://visit.eucalyptus.health/r/mitchell-1030', icon: Icons.videocam_outlined),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Done', onPressed: () => Navigator.of(ctx).pop()),
      ],
    ),
  );
}

Future<void> showDirectionsSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetHeader('Directions', 'St. Jude Health Center'),
        const InfoRow(Icons.place_outlined, 'Address', '1200 Medical Plaza Dr, Suite 400'),
        const CopyRow(
          label: 'Maps link',
          value: 'https://maps.google.com/?q=St.+Jude+Health+Center',
          icon: Icons.map_outlined,
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Done', onPressed: () => Navigator.of(ctx).pop()),
      ],
    ),
  );
}

Future<void> showInsightsSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetHeader('Wellness insights', 'Personalised for your care plan.'),
        const InfoRow(Icons.bedtime_outlined, 'Keep your evening routine', 'Consistent evening rest lowered your systolic baseline by 4 points this week.'),
        const InfoRow(Icons.water_drop_outlined, 'Hydrate steadily', 'Spread water through the day rather than all at once; aim for 2.5L.'),
        const InfoRow(Icons.directions_walk_rounded, 'Walk after dinner', 'A 15-minute walk helps keep evening glucose in range.'),
        const Pill('Endorsed by Dr. Sarah Mitchell', bg: AppColors.mint, fg: AppColors.primary, icon: Icons.verified_rounded, fontSize: 11.5),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Done', onPressed: () => Navigator.of(ctx).pop()),
      ],
    ),
  );
}

Future<bool?> showScannerSheet(BuildContext context) {
  return showAppSheet<bool>(
    context,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetHeader('Scan report', 'Point the camera at a paper lab report. We read it with OCR and file it in your vault.'),
        Container(
          height: 170,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.deep,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 120,
            height: 130,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.document_scanner_outlined, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text('Camera access isn\'t used in this demo — tap below to simulate a scan.', style: appText(12.5, color: AppColors.muted, height: 1.4)),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Simulate scan', icon: Icons.camera_alt_outlined, onPressed: () => Navigator.of(ctx).pop(true)),
      ],
    ),
  );
}

// ───────────────────────── home: input sheets ─────────────────────────

class QuickVitalSheet extends StatefulWidget {
  const QuickVitalSheet({super.key});

  @override
  State<QuickVitalSheet> createState() => _QuickVitalSheetState();
}

class _QuickVitalSheetState extends State<QuickVitalSheet> {
  VitalType _type = VitalType.heartRate;
  final _a = TextEditingController();
  final _b = TextEditingController();
  String? _errA;
  String? _errB;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  void _pick(VitalType t) {
    setState(() {
      _type = t;
      _a.clear();
      _b.clear();
      _errA = null;
      _errB = null;
    });
  }

  String? _range(String text, int lo, int hi) {
    final n = int.tryParse(text.trim());
    if (n == null) return 'Enter a number';
    if (n < lo || n > hi) return 'Use $lo–$hi';
    return null;
  }

  void _save() {
    String? ea;
    String? eb;
    int? a;
    int? b;
    switch (_type) {
      case VitalType.heartRate:
        ea = _range(_a.text, 30, 220);
      case VitalType.bloodPressure:
        ea = _range(_a.text, 70, 250);
        eb = _range(_b.text, 40, 150);
      case VitalType.spo2:
        ea = _range(_a.text, 70, 100);
      case VitalType.glucose:
        ea = _range(_a.text, 30, 600);
    }
    a = int.tryParse(_a.text.trim());
    b = int.tryParse(_b.text.trim());
    if (ea != null || eb != null) {
      setState(() {
        _errA = ea;
        _errB = eb;
      });
      return;
    }
    Navigator.of(context).pop(VitalEntry(_type, a!, b));
  }

  @override
  Widget build(BuildContext context) {
    const names = {
      VitalType.heartRate: 'Heart rate',
      VitalType.bloodPressure: 'Blood pressure',
      VitalType.spo2: 'SpO2',
      VitalType.glucose: 'Blood sugar',
    };
    final label = switch (_type) {
      VitalType.heartRate => 'Resting heart rate (bpm)',
      VitalType.bloodPressure => 'Systolic (mmHg)',
      VitalType.spo2 => 'Oxygen saturation (%)',
      VitalType.glucose => 'Blood sugar (mg/dL)',
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHeader('Log a vital', 'Pick what you measured.'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in VitalType.values) ChoicePill(label: names[t]!, selected: _type == t, onTap: () => _pick(t)),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppField(
                label: label,
                controller: _a,
                hint: _type == VitalType.bloodPressure ? '118' : null,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                errorText: _errA,
                autofocus: true,
                onChanged: (_) {
                  if (_errA != null) setState(() => _errA = null);
                },
                onSubmitted: _type == VitalType.bloodPressure ? null : (_) => _save(),
              ),
            ),
            if (_type == VitalType.bloodPressure) ...[
              const SizedBox(width: 12),
              Expanded(
                child: AppField(
                  label: 'Diastolic (mmHg)',
                  controller: _b,
                  hint: '76',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                  errorText: _errB,
                  onChanged: (_) {
                    if (_errB != null) setState(() => _errB = null);
                  },
                  onSubmitted: (_) => _save(),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Save reading', onPressed: _save),
      ],
    );
  }
}

class NoteSheet extends StatefulWidget {
  const NoteSheet({super.key});

  @override
  State<NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<NoteSheet> {
  final _ctrl = TextEditingController();
  double _pain = 1;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) {
      setState(() => _error = 'Describe how you feel first');
      return;
    }
    Navigator.of(context).pop(NoteEntry(t, _pain.round(), DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHeader('Symptom & journal', 'Share symptoms or questions with your care team.'),
        AppField(
          label: 'What are you noticing?',
          controller: _ctrl,
          hint: 'e.g. Light dizziness after standing up',
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          errorText: _error,
          autofocus: true,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Pain scale', style: appText(12.5, weight: FontWeight.w700)),
            const Spacer(),
            Text('${_pain.round()}/10', style: appText(14, weight: FontWeight.w800, color: AppColors.primary)),
          ],
        ),
        Semantics(
          label: 'Pain scale',
          value: '${_pain.round()} out of 10',
          child: Slider(
            value: _pain,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => setState(() => _pain = v),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mild', style: appText(11.5, color: AppColors.muted)),
            Text('Severe', style: appText(11.5, color: AppColors.muted)),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const Icon(Icons.photo_camera_outlined, size: 20, color: AppColors.muted),
              const SizedBox(width: 12),
              Expanded(child: Text('Attach photo', style: appText(14, weight: FontWeight.w600, color: AppColors.muted))),
              const Pill('Not in demo', bg: Colors.white, fg: AppColors.muted, fontSize: 10.5),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Save note', onPressed: _save),
      ],
    );
  }
}

class AddRoutineSheet extends StatefulWidget {
  const AddRoutineSheet({super.key});

  @override
  State<AddRoutineSheet> createState() => _AddRoutineSheetState();
}

class _AddRoutineSheetState extends State<AddRoutineSheet> {
  final _name = TextEditingController();
  bool _medication = true;
  TimeOfDay? _time;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Reminder time',
    );
    if (t != null && mounted) setState(() => _time = t);
  }

  void _save() {
    final n = _name.text.trim();
    if (n.isEmpty) {
      setState(() => _error = 'Give it a name');
      return;
    }
    Navigator.of(context).pop(NewRoutine(medication: _medication, name: n, time: _time));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHeader('Add to your routine', 'A medication or a daily habit.'),
        Row(
          children: [
            ChoicePill(label: 'Medication', selected: _medication, onTap: () => setState(() => _medication = true)),
            const SizedBox(width: 8),
            ChoicePill(label: 'Habit', selected: !_medication, onTap: () => setState(() => _medication = false)),
          ],
        ),
        const SizedBox(height: 18),
        AppField(
          label: _medication ? 'Medication & dose' : 'Habit',
          controller: _name,
          hint: _medication ? 'e.g. Metformin 500mg' : 'e.g. 10-minute walk',
          icon: _medication ? Icons.medication_outlined : Icons.task_alt_outlined,
          errorText: _error,
          autofocus: true,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 14),
        Pressable(
          onTap: _pickTime,
          semanticLabel: 'Choose a reminder time',
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.mintSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  _time == null ? 'Set a time (optional)' : _time!.format(context),
                  style: appText(14.5, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Add to routine', onPressed: _save),
      ],
    );
  }
}

class GlucoseSheet extends StatefulWidget {
  const GlucoseSheet({super.key, required this.value, required this.glucoseContext});

  final int value;
  final String glucoseContext;

  @override
  State<GlucoseSheet> createState() => _GlucoseSheetState();
}

class _GlucoseSheetState extends State<GlucoseSheet> {
  static const _contexts = ['Fasting', 'Before meal', 'After meal', 'Bedtime'];
  late final TextEditingController _v = TextEditingController(text: '${widget.value}');
  late String _ctx = widget.glucoseContext;
  String? _error;

  @override
  void dispose() {
    _v.dispose();
    super.dispose();
  }

  void _save() {
    final n = int.tryParse(_v.text.trim());
    if (n == null || n < 30 || n > 600) {
      setState(() => _error = 'Use 30–600');
      return;
    }
    Navigator.of(context).pop(GlucoseEntry(n, _ctx));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHeader('Blood glucose entry', 'Add when you measured it so your doctor can read it correctly.'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in _contexts) ChoicePill(label: c, selected: _ctx == c, onTap: () => setState(() => _ctx = c)),
          ],
        ),
        const SizedBox(height: 18),
        AppField(
          label: 'Reading (mg/dL)',
          controller: _v,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
          errorText: _error,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Save entry', onPressed: _save),
      ],
    );
  }
}
