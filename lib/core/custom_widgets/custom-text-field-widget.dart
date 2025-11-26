import 'dart:ui' as ui;

import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_button.dart';
import 'package:hawiah_driver/core/custom_widgets/svg_prefix_icon.dart';
import 'package:hawiah_driver/core/extension/context_extension.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/country_code_methods.dart';

enum FormFieldBorder { underLine, outLine, none }

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isPassword;
  final String? hintText;
  final int? maxLines;
  final String? initialValue;
  final void Function()? onTap;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double radius;
  final Color? fillColor;
  final Color? focusColor;
  final Color? unFocusColor;
  final Color? passwordColor;
  final String? title;
  final String? otherSideTitle;
  final ui.TextDirection? textDirection;
  final Country? country;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(Country)? onCountrySelect;
  final FormFieldBorder formFieldBorder;
  final TextStyle? titleStyle;
  final TextStyle? textStyle;
  final TextStyle? phonePickStyle;
  final TextStyle? hintStyle;
  final int? maxLength;
  final AutovalidateMode? autovalidateMode;
  final Widget? label;
  final String? labelText;
  final String? prefixIconSvg;
  final Color? prefixIconSvgColor;
  final String? suffixIconSvg;
  final Color? suffixIconSvgColor;
  final double? width;
  final TextAlign textAlign;
  final FocusNode? focusNode;
  final bool hasShadow;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const CustomTextField({
    super.key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.isPassword = false,
    this.hintText,
    this.maxLines = 1,
    this.onTap,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.radius = 12,
    this.fillColor,
    this.focusColor = Colors.transparent,
    this.unFocusColor,
    this.title,
    this.textDirection,
    this.otherSideTitle,
    this.country,
    this.passwordColor,
    this.formFieldBorder = FormFieldBorder.outLine,
    this.inputFormatters,
    this.onCountrySelect,
    this.titleStyle,
    this.textStyle,
    this.hintStyle,
    this.maxLength,
    this.autovalidateMode,
    this.phonePickStyle,
    this.label,
    this.labelText,
    this.prefixIconSvg,
    this.suffixIconSvg,
    this.width,
    this.textAlign = TextAlign.start,
    this.prefixIconSvgColor,
    this.suffixIconSvgColor,
    this.focusNode,
    this.hasShadow = false,
    this.onSubmitted,
    this.textInputAction,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = _isFocused
        ? (widget.focusColor ?? AppColor.textFormFillColor)
        : (widget.fillColor ?? AppColor.textFormFillColor);

    return Container(
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: widget.hasShadow
            ? [
                BoxShadow(
                  offset: const Offset(0, 3),
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null || widget.otherSideTitle != null) _buildTitleRow(),
          Directionality(
            textDirection: widget.textDirection ??
                (context.isRTL() ? ui.TextDirection.rtl : ui.TextDirection.ltr),
            child: TextFormField(
              onFieldSubmitted: widget.onSubmitted,
              controller: widget.controller,
              focusNode: _focusNode,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              validator: widget.validator,
              readOnly: widget.readOnly,
              keyboardType: widget.keyboardType,
              obscureText: widget.isPassword ? _obscureText : false,
              autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
              maxLines: widget.maxLines,
              style: widget.textStyle ?? AppTextStyle.textFormStyle,
              cursorColor: AppColor.mainAppColor,
              inputFormatters: widget.inputFormatters,
              maxLength: widget.maxLength,
              textAlign: widget.textAlign,
              decoration: _buildDecoration(context, fillColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (widget.title != null)
            Expanded(
              child: Text(
                widget.title!,
                style: widget.titleStyle ?? AppTextStyle.formTitleStyle,
              ),
            ),
          if (widget.otherSideTitle != null)
            Text(
              widget.otherSideTitle!,
              style: widget.titleStyle ?? AppTextStyle.formTitleStyle,
            ),
        ],
      ),
    );
  }

  InputDecoration _buildDecoration(BuildContext context, Color fillColor) {
    return InputDecoration(
      label: widget.label,
      labelText: widget.labelText,
      labelStyle: AppTextStyle.labelStyle,
      hintText: widget.hintText,
      hintStyle: widget.hintStyle ?? AppTextStyle.hintStyle,
      fillColor: fillColor,
      filled: true,
      border: _border(color: widget.unFocusColor ?? AppColor.textFormBorderColor),
      focusedBorder: _border(color: AppColor.mainAppColor),
      enabledBorder: _border(color: widget.unFocusColor ?? AppColor.textFormBorderColor),
      errorBorder: _border(color: Colors.red.shade700),
      focusedErrorBorder: _border(color: Colors.red.shade700),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      prefixIcon: _buildPrefix(context),
      suffixIcon: _buildSuffix(context),
    );
  }

  InputBorder _border({required Color color}) {
    switch (widget.formFieldBorder) {
      case FormFieldBorder.outLine:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radius),
          borderSide: BorderSide(color: color, width: 1.5),
        );
      case FormFieldBorder.underLine:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: color),
        );
      case FormFieldBorder.none:
        return InputBorder.none;
    }
  }

  Widget? _buildPrefix(BuildContext context) {
    if (widget.country != null && context.locale == const Locale('en')) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.prefixIconSvg != null)
            _buildSvgIcon(widget.prefixIconSvg!, isPrefix: true)
          else
            widget.prefixIcon ?? const SizedBox(),
          _buildCountryButton(),
        ],
      );
    }
    if (widget.prefixIconSvg != null) {
      return _buildSvgIcon(widget.prefixIconSvg!, isPrefix: true);
    }
    return widget.prefixIcon;
  }

  Widget? _buildSuffix(BuildContext context) {
    if (widget.country != null && context.locale == const Locale('ar')) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCountryButton(),
          if (widget.suffixIconSvg != null)
            _buildSvgIcon(widget.suffixIconSvg!, isPrefix: false)
          else
            widget.suffixIcon ?? const SizedBox(),
        ],
      );
    }
    if (widget.isPassword) {
      return InkWell(
        onTap: () => setState(() => _obscureText = !_obscureText),
        child: Icon(
          _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          size: 20,
          color: widget.passwordColor ?? AppColor.hintColor,
        ),
      );
    }
    if (widget.suffixIconSvg != null) {
      return _buildSvgIcon(widget.suffixIconSvg!, isPrefix: false);
    }
    return widget.suffixIcon;
  }

  Widget _buildSvgIcon(String path, {required bool isPrefix}) {
    return Container(
      width: 45,
      height: 47,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.horizontal(
          start: isPrefix ? Radius.circular(widget.radius) : Radius.zero,
          end: isPrefix ? Radius.zero : Radius.circular(widget.radius),
        ),
      ),
      child: SvgPrefixIcon(
        imagePath: path,
        color: isPrefix ? widget.prefixIconSvgColor : widget.suffixIconSvgColor,
      ),
    );
  }

  Widget _buildCountryButton() {
    return SizedBox(
      width: 100,
      child: Center(
        child: CustomButton(
          width: 80,
          height: 32,
          radius: 4,
          color: AppColor.textFormBorderColor,
          onPressed: widget.onCountrySelect != null ? _select : null,
          child: Text(
            '${widget.country?.flagEmoji} +${widget.country?.phoneCode}',
            style: widget.phonePickStyle ??
                AppTextStyle.text14_400.copyWith(color: AppColor.textSecondaryColor),
            textDirection: ui.TextDirection.ltr,
          ),
        ),
      ),
    );
  }

  void _select() {
    CountryCodeMethods.pickCountry(
      onSelect: (v) => widget.onCountrySelect?.call(v),
      context: context,
    );
  }
}
