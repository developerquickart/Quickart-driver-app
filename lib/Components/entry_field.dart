import 'package:flutter/material.dart';

class EntryField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? image;
  final String? initialValue;
  final bool? readOnly;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int? maxLines;
  final String? hint;
  final IconData? suffixIcon;
  final Function? onTap;
  final TextCapitalization? textCapitalization;
  final Function? onSuffixPressed;
  final double? horizontalPadding;
  final double? verticalPadding;
  final FontWeight? labelFontWeight;
  final double? labelFontSize;
  final Color? underlineColor;
  final Color? labelColor;
  final TextStyle? hintStyle;

  EntryField({
    this.controller,
    this.label,
    this.image,
    this.initialValue,
    this.readOnly,
    this.keyboardType,
    this.maxLength,
    this.hint,
    this.suffixIcon,
    this.maxLines,
    this.onTap,
    this.textCapitalization,
    this.onSuffixPressed,
    this.horizontalPadding,
    this.verticalPadding,
    this.labelFontWeight,
    this.labelFontSize,
    this.labelColor,
    this.underlineColor,
    this.hintStyle,
  });

  @override
  _EntryFieldState createState() => _EntryFieldState();
}

class _EntryFieldState extends State<EntryField> {
  bool showShadow = false;
  bool showBorder = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: widget.horizontalPadding ?? 20.0,
          vertical: widget.verticalPadding ?? 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(widget.label ?? '',
              style: TextStyle(
                  color: Colors.amber,
                  fontWeight: widget.labelFontWeight ?? FontWeight.w500,
                  fontSize: widget.labelFontSize ?? 21.7)),
          TextField(
            textCapitalization:
                widget.textCapitalization ?? TextCapitalization.sentences,
            cursorColor: Theme.of(context).primaryColor,
            autofocus: false,
            onEditingComplete: () {
              setState(() {
                showShadow = false;
              });
            },
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap!();
              }
              setState(() {
                showShadow = true;
                showBorder = true;
              });
            },
            controller: widget.controller,
            readOnly: widget.readOnly ?? false,
            keyboardType: widget.keyboardType,
            minLines: 1,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines ?? 1,
            decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black ?? Colors.grey),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    widget.suffixIcon,
                    size: 40.0,
                    color: Colors.amber,
                  ),
                  onPressed: widget.onSuffixPressed!(),
                ),
                hintText: widget.hint,
                counterText: '',
                hintStyle: TextStyle(fontSize: 18)),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
