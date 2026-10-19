import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

class AppField extends StatefulWidget {
  const AppField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.action,
    this.onSubmitted,
    this.onChanged,
    this.errorText,
    this.suffix,
    this.focusNode,
    this.maxLines = 1,
    this.inputFormatters,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? action;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final Widget? suffix;
  final FocusNode? focusNode;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() {
    if (_focused != _focus.hasFocus) setState(() => _focused = _focus.hasFocus);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final multi = widget.maxLines > 1;
    final borderColor = hasError
        ? AppColors.danger
        : _focused
            ? AppColors.primary
            : AppColors.line;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(widget.label, style: appText(12.5, weight: FontWeight.w700)),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 56),
          padding: EdgeInsets.only(
            left: 16,
            right: widget.suffix != null ? 6 : 16,
            top: multi ? 14 : 0,
            bottom: multi ? 14 : 0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: (_focused || hasError) ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x0C0E4A37), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            crossAxisAlignment: multi ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: _focused ? AppColors.primary : AppColors.muted),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: widget.obscure,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.action,
                  onSubmitted: widget.onSubmitted,
                  onChanged: widget.onChanged,
                  maxLines: widget.maxLines,
                  inputFormatters: widget.inputFormatters,
                  autofocus: widget.autofocus,
                  cursorColor: AppColors.primary,
                  style: appText(15, weight: FontWeight.w600),
                  decoration: InputDecoration.collapsed(
                    hintText: widget.hint,
                    hintStyle: appText(
                      15,
                      color: AppColors.muted.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              if (widget.suffix != null) widget.suffix!,
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    widget.errorText!,
                    style: appText(12, weight: FontWeight.w600, color: AppColors.danger),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
