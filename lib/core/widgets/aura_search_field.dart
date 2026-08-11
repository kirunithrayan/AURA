import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';
import 'aura_icon_button.dart';

/// Search-field variants.
///
/// [input] is the editable field that owns a cursor and keyboard.
/// [launcher] is a read-only entry affordance: the whole field is one tappable
/// node that navigates into Search.
enum AuraSearchFieldVariant { input, launcher }

/// The AURA search field.
///
/// Consolidates the two legacy search inputs. There is no mode selector, no
/// filter affordance, and no sort affordance.
class AuraSearchField extends StatefulWidget {
  const AuraSearchField({
    super.key,
    this.variant = AuraSearchFieldVariant.input,
    this.controller,
    this.focusNode,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onClear,
    this.autofocus = false,
    this.enabled = true,
  });

  final AuraSearchFieldVariant variant;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool enabled;

  @override
  State<AuraSearchField> createState() => _AuraSearchFieldState();
}

class _AuraSearchFieldState extends State<AuraSearchField> {
  TextEditingController? _fallbackController;
  bool _showClear = false;

  TextEditingController get _controller =>
      widget.controller ?? (_fallbackController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _showClear = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _fallbackController?.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final bool showClear = _controller.text.isNotEmpty;
    if (_showClear != showClear) {
      setState(() => _showClear = showClear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;
    final bool isLauncher = widget.variant == AuraSearchFieldVariant.launcher;

    final Widget leading = Icon(
      Icons.search,
      size: AuraIconTokens.sizeSm,
      color: colors.contentTertiary,
    );

    final Widget body = isLauncher
        ? Text(
            widget.hintText,
            style: AuraTypography.body.copyWith(color: colors.contentTertiary),
          )
        : TextField(
            controller: _controller,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            textInputAction: TextInputAction.search,
            style: AuraTypography.body.copyWith(color: colors.contentPrimary),
            cursorColor: colors.actionPrimary,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle:
                  AuraTypography.body.copyWith(color: colors.contentTertiary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          );

    final Widget field = Container(
      constraints: const BoxConstraints(minHeight: AuraLayout.touchTargetMin),
      padding: const EdgeInsets.symmetric(
        horizontal: AuraSpacing.componentPadding,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        border: Border.all(
          color: colors.borderDefault,
          width: AuraBorders.hairline,
        ),
      ),
      child: Row(
        children: <Widget>[
          ExcludeSemantics(child: leading),
          const SizedBox(width: AuraSpacing.componentGap),
          Expanded(child: body),
          if (!isLauncher && _showClear)
            AuraIconButton(
              icon: Icons.clear,
              tooltip: 'Clear search',
              size: AuraIconTokens.sizeSm,
              onPressed: () {
                _controller.clear();
                widget.onClear?.call();
              },
            ),
        ],
      ),
    );

    if (!isLauncher) {
      return field;
    }
    // The launcher is a single tappable node, not a text field.
    return Semantics(
      button: true,
      label: widget.hintText,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        child: ExcludeSemantics(child: field),
      ),
    );
  }
}
