import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import 'app_field.dart';

/// Tap target with a subtle press-scale (0.97) so every control feels alive.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.scale = 0.97,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final double scale;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final reduce = MediaQuery.of(context).disableAnimations;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      excludeSemantics: widget.semanticLabel != null,
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _set(true) : null,
          onTapUp: enabled ? (_) => _set(false) : null,
          onTapCancel: enabled ? () => _set(false) : null,
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          child: AnimatedScale(
            scale: _down && !reduce ? widget.scale : 1,
            duration: Duration(milliseconds: _down ? 90 : 160),
            curve: Curves.easeOut,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Staggered entrance: fade + 14px rise, ease-out. Plays once.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    const base = 480;
    final delay = 55 * widget.index;
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: base + delay),
    );
    _t = CurvedAnimation(
      parent: _c,
      curve: Interval(delay / (base + delay), 1, curve: Curves.easeOutCubic),
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: clamp01(_t.value),
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - _t.value)),
          child: child,
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.radius = 24,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow ? kCardShadow : null,
      ),
      child: child,
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(
    this.text, {
    super.key,
    required this.bg,
    required this.fg,
    this.icon,
    this.dot = false,
    this.fontSize = 11,
  });

  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;
  final bool dot;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
          if (icon != null) Icon(icon, size: 14, color: fg),
          if (dot || icon != null) const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appText(fontSize, weight: FontWeight.w700, color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(this.initials, {super.key, this.size = 44});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, AppColors.primary],
        ),
      ),
      child: Text(
        initials,
        style: appText(size * 0.34, weight: FontWeight.w800, color: Colors.white),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.loadingLabel,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final String? loadingLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: loading ? null : onPressed,
      semanticLabel: loading ? (loadingLabel ?? 'Loading') : label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: loading ? AppColors.primary.withValues(alpha: 0.85) : AppColors.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x331F5E46), blurRadius: 18, offset: Offset(0, 8)),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: loading
              ? Row(
                  key: const ValueKey('loading'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      loadingLabel ?? 'Please wait…',
                      style: appText(16, weight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('idle'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: appText(16, weight: FontWeight.w700, color: Colors.white)),
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(icon, size: 20, color: Colors.white),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

Future<T?> showAppSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 480),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              builder(ctx),
            ],
          ),
        ),
      ),
    ),
  );
}

void showAppSnack(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        duration: const Duration(milliseconds: 2600),
      ),
    );
}

/// Single-field bottom sheet. Pops with the trimmed text on success.
class TextEntrySheet extends StatefulWidget {
  const TextEntrySheet({
    super.key,
    required this.title,
    required this.description,
    required this.label,
    required this.buttonLabel,
    this.hint,
    this.initial = '',
    this.keyboardType,
    this.maxLines = 1,
    this.icon,
    this.validator,
    this.inputFormatters,
  });

  final String title;
  final String description;
  final String label;
  final String buttonLabel;
  final String? hint;
  final String initial;
  final TextInputType? keyboardType;
  final int maxLines;
  final IconData? icon;
  final String? Function(String value)? validator;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<TextEntrySheet> createState() => _TextEntrySheetState();
}

class _TextEntrySheetState extends State<TextEntrySheet> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _ctrl.text.trim();
    final error = widget.validator?.call(value);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: appText(22, weight: FontWeight.w800, letterSpacing: -0.4)),
        const SizedBox(height: 6),
        Text(widget.description, style: appText(14, color: AppColors.muted, height: 1.4)),
        const SizedBox(height: 20),
        AppField(
          label: widget.label,
          controller: _ctrl,
          icon: widget.icon,
          hint: widget.hint,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          errorText: _error,
          autofocus: true,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: widget.maxLines == 1 ? (_) => _submit() : null,
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: widget.buttonLabel, onPressed: _submit),
      ],
    );
  }
}

/// Selectable pill used inside sheets (vital type, glucose context, etc.).
class ChoicePill extends StatelessWidget {
  const ChoicePill({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      semanticLabel: '$label${selected ? ', selected' : ''}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.deep : AppColors.mintSoft,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: appText(13.5, weight: FontWeight.w700, color: selected ? Colors.white : AppColors.ink),
        ),
      ),
    );
  }
}
