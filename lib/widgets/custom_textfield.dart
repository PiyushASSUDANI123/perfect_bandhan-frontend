import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final int maxLines;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode autovalidateMode;
  final String? helperText;
  final double bottomMargin;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.isPassword = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.onChanged,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.helperText,
    this.bottomMargin = 16.0,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String? _handleValidation(String? value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      if (_errorText != error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _errorText = error;
            });
          }
        });
      }
      return error != null ? '' : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Apple-style Minimal Floating Label with Error Message
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.labelText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    widget.labelText,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _errorText != null 
                          ? Colors.redAccent 
                          : (_isFocused ? AppTheme.accentGold : AppTheme.textCarbon),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              if (_errorText != null)
                Flexible(
                  child: Text(
                    _errorText!,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        // Glassmorphic Input Container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isFocused 
                ? AppTheme.glassColor.withValues(alpha: 0.15) 
                : AppTheme.glassColor,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: _errorText != null 
                  ? Colors.redAccent 
                  : (_isFocused ? AppTheme.accentGold : AppTheme.glassBorderColor),
              width: _errorText != null ? 1.0 : 0.5,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.isPassword ? _obscureText : false,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            validator: _handleValidation,
            onChanged: widget.onChanged,
            autovalidateMode: widget.autovalidateMode,
            inputFormatters: widget.inputFormatters,
            style: GoogleFonts.montserrat(
              color: AppTheme.textCarbon,
              fontSize: 14,
            ),
            cursorColor: AppTheme.accentGold,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.montserrat(
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                fontSize: 13,
              ),
              prefixIcon: Icon(
                widget.prefixIcon,
                color: _errorText != null 
                    ? Colors.redAccent 
                    : (_isFocused ? AppTheme.accentGold : AppTheme.textMuted),
                size: 18,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: _errorText != null 
                            ? Colors.redAccent 
                            : (_isFocused ? AppTheme.accentGold : AppTheme.textMuted),
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              errorStyle: const TextStyle(height: 0, fontSize: 0, color: Colors.transparent),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
            ),
          ),
        ),
        if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4.0, top: 4.0),
            child: Text(
              widget.helperText!,
              style: GoogleFonts.montserrat(
                color: AppTheme.textMuted,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        SizedBox(height: widget.bottomMargin),
      ],
    );
  }
}
