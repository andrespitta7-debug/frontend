import 'package:flutter/material.dart';
import '../sysquest_theme.dart';

/// Campo de texto 16-bit retro que sustituye el diseño Material por una caja arcade:
/// - Fondo: [SysQuestColors.dungeonVoid]
/// - Borde de 3px: [SysQuestColors.stoneHighlight], cambia a [SysQuestColors.manaCyan] con foco.
/// - Cursor pixel art: ancho de 8px en [SysQuestColors.gold].
/// - Tipografía: [SysQuestTypography.body].
/// - Oculta bordes estándar de Material Design.
/// - Compatible con [Form] y validaciones nativas.
class RetroTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final int maxLines;

  const RetroTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.focusNode,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
  });

  @override
  State<RetroTextField> createState() => _RetroTextFieldState();
}

class _RetroTextFieldState extends State<RetroTextField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
  late FocusNode _focusNode;
  bool _isInternalFocusNode = false;
  bool _hasFocus = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    }
    _hasFocus = _focusNode.hasFocus;
    _focusNode.addListener(_onFocusChange);

    widget.controller?.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    _fieldKey.currentState?.didChange(widget.controller?.text);
    if (widget.validator != null && _errorText != null) {
      _validate(widget.controller?.text);
    }
  }

  void _onFocusChange() {
    if (mounted && _hasFocus != _focusNode.hasFocus) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
      if (!_focusNode.hasFocus && widget.validator != null) {
        _validate(widget.controller?.text);
      }
    }
  }

  void _validate(String? value) {
    if (widget.validator == null) return;
    final error = widget.validator!(value);
    if (mounted && error != _errorText) {
      setState(() {
        _errorText = error;
      });
    }
  }

  @override
  void didUpdateWidget(covariant RetroTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChange);
      widget.controller?.addListener(_onControllerChange);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      if (_isInternalFocusNode) {
        _focusNode.removeListener(_onFocusChange);
        _focusNode.dispose();
      }
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
        _isInternalFocusNode = false;
      } else {
        _focusNode = FocusNode();
        _isInternalFocusNode = true;
      }
      _focusNode.addListener(_onFocusChange);
      _hasFocus = _focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChange);
    _focusNode.removeListener(_onFocusChange);
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _fieldKey,
      validator: widget.validator,
      initialValue: widget.controller?.text ?? '',
      builder: (FormFieldState<String> field) {
        final effectiveError = field.errorText ?? _errorText;
        final hasError = effectiveError != null && effectiveError.isNotEmpty;

        Color borderColor;
        if (hasError) {
          borderColor = SysQuestColors.lifeRed;
        } else if (_hasFocus) {
          borderColor = SysQuestColors.manaCyan;
        } else {
          borderColor = SysQuestColors.stoneHighlight;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.labelText != null) ...[
              Text(
                widget.labelText!,
                style: SysQuestTypography.caption.copyWith(
                  color: hasError
                      ? SysQuestColors.lifeRed
                      : (_hasFocus
                          ? SysQuestColors.manaCyan
                          : SysQuestColors.parchmentText
                              .withValues(alpha: 0.85)),
                ),
              ),
              const SizedBox(height: 6),
            ],
            Container(
              decoration: BoxDecoration(
                color: SysQuestColors.dungeonVoid,
                border: Border.all(
                  color: borderColor,
                  width: 3,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Row(
                children: [
                  if (widget.prefixIcon != null) ...[
                    IconTheme(
                      data: IconThemeData(
                        color: hasError
                            ? SysQuestColors.lifeRed
                            : (_hasFocus
                                ? SysQuestColors.manaCyan
                                : SysQuestColors.stoneHighlight),
                        size: 18,
                      ),
                      child: widget.prefixIcon!,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      textCapitalization: widget.textCapitalization,
                      onSubmitted: (val) {
                        field.didChange(val);
                        _validate(val);
                        widget.onSubmitted?.call(val);
                      },
                      onChanged: (val) {
                        field.didChange(val);
                        if (hasError) _validate(val);
                        widget.onChanged?.call(val);
                      },
                      autofillHints: widget.autofillHints,
                      maxLines: widget.maxLines,
                      cursorWidth: 8,
                      cursorColor: SysQuestColors.gold,
                      style: SysQuestTypography.body.copyWith(
                        color: widget.enabled
                            ? SysQuestColors.parchmentText
                            : SysQuestColors.disabledGray,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: SysQuestTypography.body.copyWith(
                          color: SysQuestColors.stoneHighlight,
                          fontSize: 10,
                        ),
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  if (widget.suffixIcon != null) ...[
                    const SizedBox(width: 6),
                    IconTheme(
                      data: IconThemeData(
                        color: hasError
                            ? SysQuestColors.lifeRed
                            : (_hasFocus
                                ? SysQuestColors.manaCyan
                                : SysQuestColors.stoneHighlight),
                        size: 18,
                      ),
                      child: widget.suffixIcon!,
                    ),
                  ],
                ],
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 5),
              Text(
                effectiveError,
                style: SysQuestTypography.caption.copyWith(
                  color: SysQuestColors.lifeRed,
                  fontSize: 8,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
