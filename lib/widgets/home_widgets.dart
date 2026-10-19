import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/models.dart';
import '../core/theme.dart';
import 'common.dart';

// ───────────────────────── Week strip ─────────────────────────

class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.days, required this.selected, required this.onSelect});

  final List<DateTime> days;
  final int selected;
  final ValueChanged<int> onSelect;

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < days.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
              child: Pressable(
                onTap: () => onSelect(i),
                scale: 0.95,
                semanticLabel: '${_names[i]} ${days[i].day}${i == selected ? ', selected' : ''}',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  height: 66,
                  decoration: BoxDecoration(
                    color: i == selected
                        ? AppColors.deep
                        : AppColors.mint.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _letters[i],
                        style: appText(
                          11,
                          weight: FontWeight.w700,
                          color: i == selected ? Colors.white.withValues(alpha: 0.8) : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${days[i].day}',
                        style: appText(
                          18,
                          weight: FontWeight.w800,
                          color: i == selected ? Colors.white : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == selected
                              ? AppColors.mint
                              : AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ───────────────────────── Consultation ─────────────────────────

class ConsultationCard extends StatelessWidget {
  const ConsultationCard({
    super.key,
    required this.onOpen,
    required this.onDetails,
    required this.onDirections,
  });

  final VoidCallback onOpen;
  final VoidCallback onDetails;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onOpen,
      scale: 0.99,
      semanticLabel: 'Upcoming consultation with Dr. Sarah Mitchell, tomorrow at 10:30 AM. Open appointment details.',
      child: _card(),
    );
  }

  Widget _card() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFBFE6D2), Color(0xFF7CC4A0)],
                        ),
                      ),
                      child: Text('SM', style: appText(19, weight: FontWeight.w800, color: AppColors.deep)),
                    ),
                    Positioned(
                      left: -4,
                      bottom: -2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F7BE0),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.medical_services_outlined, size: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'UPCOMING CONSULTATION',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: appText(10.5, weight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Pill('In 24h', bg: AppColors.blueSoft, fg: AppColors.blue, fontSize: 10.5),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Dr. Sarah Mitchell', style: appText(20, weight: FontWeight.w800, letterSpacing: -0.3)),
                    const SizedBox(height: 2),
                    Text(
                      'Cardiologist • St. Jude Health Center',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: appText(12.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill('Tomorrow, 10:30 AM', bg: AppColors.mintSoft, fg: AppColors.ink, icon: Icons.schedule_rounded, fontSize: 12),
              Pill('Fasting required', bg: AppColors.dangerSoft, fg: AppColors.danger, icon: Icons.info_outline_rounded, fontSize: 12),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CardButton(
                  label: 'View Details',
                  icon: Icons.visibility_outlined,
                  onTap: onDetails,
                  filled: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CardButton(
                  label: 'Directions',
                  icon: Icons.near_me_outlined,
                  onTap: onDirections,
                  filled: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({required this.label, required this.icon, required this.onTap, required this.filled});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : AppColors.ink;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: filled ? AppColors.deep : AppColors.mintSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(label, style: appText(14, weight: FontWeight.w700, color: fg)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Quick actions ─────────────────────────

class QuickAction extends StatelessWidget {
  const QuickAction({super.key, required this.icon, required this.label, required this.onTap, this.filled = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : AppColors.ink;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: filled ? AppColors.deep : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: filled ? null : Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: filled ? Colors.white : AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: appText(13.5, weight: FontWeight.w700, color: fg)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Vitals ─────────────────────────

class VitalCard extends StatelessWidget {
  const VitalCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.caption,
    this.badge,
    this.unit,
    this.captionColor = AppColors.muted,
    this.captionWeight = FontWeight.w500,
    this.footer,
    this.onTap,
    this.semanticLabel,
  });

  final VoidCallback? onTap;
  final String? semanticLabel;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String? unit;
  final String caption;
  final Color captionColor;
  final FontWeight captionWeight;
  final Widget? badge;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final card = _card();
    if (onTap == null) return card;
    return Pressable(onTap: onTap, scale: 0.98, semanticLabel: semanticLabel, child: card);
  }

  Widget _card() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              if (badge != null) badge!,
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: appText(32, weight: FontWeight.w800, letterSpacing: -1)),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Text(unit!, style: appText(13, color: AppColors.muted)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: appText(12.5, weight: captionWeight, color: captionColor),
          ),
          const Spacer(),
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );
  }
}

class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      width: double.infinity,
      child: CustomPaint(painter: _SparkPainter(List<int>.of(values))),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values);

  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(math.min).toDouble();
    final maxV = values.reduce(math.max).toDouble();
    final range = (maxV - minV) < 1 ? 1.0 : (maxV - minV);
    const pad = 4.0;

    final pts = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          i / (values.length - 1) * size.width,
          pad + (1 - (values[i] - minV) / range) * (size.height - pad * 2),
        ),
    ];

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final cx = (a.dx + b.dx) / 2;
      path.cubicTo(cx, a.dy, cx, b.dy, b.dx, b.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final last = pts.last;
    canvas.drawCircle(last, 4.5, Paint()..color = Colors.white);
    canvas.drawCircle(last, 3, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => true;
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.color = AppColors.primary, this.height = 6});

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: clamp01(value)),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(height),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height)),
            ),
          ),
        ),
      ),
    );
  }
}

class SegmentedBar extends StatelessWidget {
  const SegmentedBar({super.key});

  Widget _seg(int flex, Color c) => Expanded(
        flex: flex,
        child: Container(
          height: 6,
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _seg(5, AppColors.deep),
        const SizedBox(width: 3),
        _seg(3, AppColors.accent),
        const SizedBox(width: 3),
        _seg(2, const Color(0xFFCADDF3)),
      ],
    );
  }
}

// ───────────────────────── Routine ─────────────────────────

String formatLitres(double v) {
  var s = v.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
  if (s.endsWith('.')) s += '0';
  return s;
}

class CheckDot extends StatelessWidget {
  const CheckDot({super.key, required this.done, this.child});

  final bool done;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.primary : Colors.transparent,
        border: Border.all(color: done ? AppColors.primary : const Color(0xFF9DB0A6), width: 2),
      ),
      child: AnimatedScale(
        scale: done ? 1 : 0.5,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: done ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: const Icon(Icons.check_rounded, size: 17, color: Colors.white),
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.water,
    required this.waterGoal,
    required this.onToggle,
    required this.onOpen,
    required this.onAddWater,
    this.onTrailing,
  });

  final RoutineTask task;
  final double water;
  final double waterGoal;

  /// Checkbox tap.
  final VoidCallback onToggle;

  /// Tap on the text area.
  final VoidCallback onOpen;

  /// Tap on the trailing icon (reminder / edit). Null = decorative only.
  final VoidCallback? onTrailing;
  final VoidCallback onAddWater;

  @override
  Widget build(BuildContext context) {
    return task.kind == TaskKind.hydration ? _hydration() : _check();
  }

  Widget _check() {
    final done = task.done;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      radius: 22,
      child: Row(
        children: [
          Pressable(
            onTap: onToggle,
            scale: 0.9,
            semanticLabel: '${task.title}, ${done ? 'completed' : 'not completed'}. Double tap to toggle.',
            child: SizedBox(
              width: 48,
              height: 52,
              child: Center(child: CheckDot(done: done)),
            ),
          ),
          Expanded(
            child: Pressable(
              onTap: onOpen,
              scale: 0.985,
              semanticLabel: '${task.title}. ${task.subtitle}',
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            style: appText(
                              15,
                              weight: FontWeight.w700,
                              color: done ? AppColors.muted : AppColors.ink,
                              decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                            child: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        if (task.tag != null) ...[
                          const SizedBox(width: 8),
                          Pill(task.tag!, bg: AppColors.mintSoft, fg: AppColors.primary, fontSize: 10.5),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      task.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: appText(12.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Pressable(
            onTap: onTrailing,
            semanticLabel: task.kind == TaskKind.glucose ? 'Edit glucose entry' : 'Set reminder',
            child: SizedBox(
              width: 48,
              height: 52,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? Colors.transparent : AppColors.mintSoft,
                  ),
                  child: Icon(
                    task.icon,
                    size: 20,
                    color: done ? const Color(0xFFB4C4BB) : AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hydration() {
    final reached = water >= waterGoal;
    final pct = (water / waterGoal * 100).round();
    return AppCard(
      padding: const EdgeInsets.all(14),
      radius: 22,
      child: Column(
        children: [
          Row(
            children: [
              reached
                  ? const CheckDot(done: true)
                  : Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
                      child: const Icon(Icons.autorenew_rounded, size: 16, color: AppColors.primary),
                    ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: appText(15, weight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '${formatLitres(water)}L / ${formatLitres(waterGoal)}L',
                          style: appText(13, weight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      reached ? 'Goal reached • Great job' : '$pct% completed • Next glass recommended',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: appText(12.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Pressable(
                onTap: onAddWater,
                semanticLabel: 'Add a glass of water, 250 millilitres',
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mintSoft,
                    border: Border.all(color: AppColors.mint),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 22,
                    color: reached ? const Color(0xFFB4C4BB) : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(value: water / waterGoal, color: AppColors.accent),
        ],
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      semanticLabel: 'Eucalyptus Wellness Insight. Open personalised insights.',
      child: _card(),
    );
  }

  Widget _card() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCDEEDC), Color(0xFFE2F5EA)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.deep, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.eco_rounded, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Eucalyptus Wellness Insight', style: appText(14, weight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                  'Consistent evening rest reduced your systolic baseline by 4 points this week.',
                  style: appText(12.5, color: const Color(0xFF3B4D44), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Bottom nav ─────────────────────────

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.monitor_heart_outlined, Icons.monitor_heart_rounded, 'Metrics'),
    (Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Visits'),
    (Icons.folder_open_outlined, Icons.folder_open_rounded, 'Records'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x120E4A37), blurRadius: 24, offset: Offset(0, -6))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: Pressable(
                    onTap: () => onChanged(i),
                    scale: 0.95,
                    semanticLabel: '${_items[i].$3}${i == index ? ', selected' : ''}',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i == index ? AppColors.mint : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            i == index ? _items[i].$2 : _items[i].$1,
                            size: 22,
                            color: i == index ? AppColors.deep : AppColors.muted,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _items[i].$3,
                            style: appText(
                              11,
                              weight: i == index ? FontWeight.w800 : FontWeight.w600,
                              color: i == index ? AppColors.deep : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
