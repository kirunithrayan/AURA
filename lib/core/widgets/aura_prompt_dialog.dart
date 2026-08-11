import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';
import 'aura_button.dart';

/// A generic single-input modal.
///
/// Presented with `showDialog`, not `AuraSheet`: the Design System treats
/// dialogs and sheets as separate families.
///
/// Supports async submission with an in-flight state, synchronous validation,
/// and an error slot. A validator returning an empty string rejects the submit
/// without showing a message, which is what the existing empty-input no-op
/// behavior needs.
class AuraPromptDialog {
  const AuraPromptDialog._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String confirmLabel,
    required Future<T?> Function(String value) onSubmit,
    String? message,
    String? initialValue,
    String? hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String value)? validator,
    String cancelLabel = 'Cancel',
  }) =>
      showDialog<T>(
        context: context,
        builder: (BuildContext context) => _AuraPromptDialogBody<T>(
          title: title,
          confirmLabel: confirmLabel,
          onSubmit: onSubmit,
          message: message,
          initialValue: initialValue,
          hintText: hintText,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          cancelLabel: cancelLabel,
        ),
      );
}

class _AuraPromptDialogBody<T> extends StatefulWidget {
  const _AuraPromptDialogBody({
    required this.title,
    required this.confirmLabel,
    required this.onSubmit,
    required this.cancelLabel,
    this.message,
    this.initialValue,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final String title;
  final String confirmLabel;
  final Future<T?> Function(String value) onSubmit;
  final String cancelLabel;
  final String? message;
  final String? initialValue;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String value)? validator;

  @override
  State<_AuraPromptDialogBody<T>> createState() =>
      _AuraPromptDialogBodyState<T>();
}

class _AuraPromptDialogBodyState<T> extends State<_AuraPromptDialogBody<T>> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);
  late bool _obscured = widget.obscureText;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String value = _controller.text;
    final String? failure = widget.validator?.call(value);
    if (failure != null) {
      // An empty message rejects silently, preserving legacy no-op behavior.
      setState(() => _error = failure.isEmpty ? null : failure);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final T? result = await widget.onSubmit(value);
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;
    final String? message = widget.message;
    final String? error = _error;

    return AlertDialog(
      backgroundColor: colors.surfaceOverlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AuraRadius.lg),
      ),
      title: Text(
        widget.title,
        style: AuraTypography.titleMd.copyWith(color: colors.contentPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (message != null) ...<Widget>[
            Text(
              message,
              style:
                  AuraTypography.body.copyWith(color: colors.contentSecondary),
            ),
            const SizedBox(height: AuraSpacing.componentGap),
          ],
          TextField(
            controller: _controller,
            enabled: !_busy,
            obscureText: _obscured,
            keyboardType: widget.keyboardType,
            autofocus: true,
            style: AuraTypography.body.copyWith(color: colors.contentPrimary),
            cursorColor: colors.actionPrimary,
            onSubmitted: (_) => _busy ? null : _submit(),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle:
                  AuraTypography.body.copyWith(color: colors.contentTertiary),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscured ? Icons.visibility : Icons.visibility_off,
                        size: AuraIconTokens.sizeSm,
                      ),
                      tooltip: _obscured ? 'Show' : 'Hide',
                      onPressed: () => setState(() => _obscured = !_obscured),
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuraRadius.sm),
                borderSide: BorderSide(
                  color: colors.borderDefault,
                  width: AuraBorders.hairline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuraRadius.sm),
                borderSide: BorderSide(
                  color: colors.focusRing,
                  width: AuraBorders.focus,
                ),
              ),
            ),
          ),
          if (error != null) ...<Widget>[
            const SizedBox(height: AuraSpacing.gapTight),
            Text(
              error,
              style:
                  AuraTypography.caption.copyWith(color: colors.statusError),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        AuraButton(
          label: widget.cancelLabel,
          variant: AuraButtonVariant.text,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
        AuraButton(
          label: widget.confirmLabel,
          variant: AuraButtonVariant.primary,
          onPressed: _busy ? null : _submit,
        ),
      ],
    );
  }
}
