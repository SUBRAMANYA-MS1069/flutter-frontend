import 'package:flutter/material.dart';
import 'dart:async';

import '../../theme/app_theme.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final bool autofocus;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? borderColor;
  final double? borderWidth;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool showClearButton;
  final int debounceTime;

  const CustomSearchBar({
    Key? key,
    required this.hintText,
    required this.onSearch,
    this.autofocus = false,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.margin,
    this.padding,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.hintColor,
    this.borderColor,
    this.borderWidth,
    this.textStyle,
    this.hintStyle,
    this.showClearButton = true,
    this.debounceTime = 500,
  }) : super(key: key);

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  Timer? _debounce;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _controller.removeListener(_onTextChanged);
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClear = _controller.text.isNotEmpty;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceTime), () {
      widget.onSearch(_controller.text);
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 50,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? AppTheme.borderRadius),
        border: Border.all(
          color: widget.borderColor ?? Theme.of(context).dividerColor,
          width: widget.borderWidth ?? 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        style: widget.textStyle ?? TextStyle(
          color: widget.textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: widget.hintStyle ?? TextStyle(
            color: widget.hintColor ?? Theme.of(context).hintColor,
          ),
          prefixIcon: widget.prefixIcon ?? const Icon(Icons.search),
          suffixIcon: _showClear && widget.showClearButton
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : widget.suffixIcon,
          border: InputBorder.none,
          contentPadding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: widget.onSearch,
      ),
    );
  }
}