import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {Key? key,
      @required this.hintText,
      this.obscureText,
      this.greyBackGround,
      this.textController,
      this.keyboardType,
      this.errorText,
      this.maxLength,
      this.onChanged,
      this.disableFocus = false,
      this.prefixText,
      this.autoFocus,
      this.initialValue,
      this.textCapitalization,
      this.validator,
      this.minLines,
      this.maxLines,
      this.suffixWidget,
      this.enabled = true,
      this.suffixText,
      this.onPrefixOutsideBoxPressed,
      this.onSaved,
      this.onFieldSubmitted,
      this.inputFormatters,
      this.labelText,
      this.helperText,
      this.prefixTextOutsideBox,
      this.scrollPadding = const EdgeInsets.all(8),
      this.prefixIcon,
      this.readOnly = false,
      this.onTap,
      this.width,
      this.labelBehaviour = FloatingLabelBehavior.auto,
      this.focusNode})
      : super(key: key);
  final FocusNode? focusNode;
  final int? maxLength, minLines, maxLines;
  final double? width;
  final TextInputType? keyboardType;
  final bool? obscureText, autoFocus, enabled, greyBackGround;
  final EdgeInsets scrollPadding;

  final TextEditingController? textController;
  final TextCapitalization? textCapitalization;
  final String? Function(String?)? validator,
      onChanged,
      onSaved,
      onFieldSubmitted;
  final Function()? onTap;
  final String? hintText,
      errorText,
      prefixText,
      prefixTextOutsideBox,
      initialValue,
      suffixText,
      helperText,
      labelText;
  final Widget? suffixWidget, prefixIcon;
  final VoidCallback? onPrefixOutsideBoxPressed;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly, disableFocus;
  final FloatingLabelBehavior labelBehaviour;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: Row(
        children: [
          if (prefixTextOutsideBox != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => onPrefixOutsideBoxPressed!(),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  prefixTextOutsideBox!,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          Expanded(
            child: TextFormField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              key: Key(hintText!),
              readOnly: readOnly,
              scrollPadding: scrollPadding,
              onTap: onTap,
              focusNode: focusNode,
              maxLength: maxLength,
              initialValue: initialValue,
              controller: textController,
              autofocus: autoFocus ?? false,
              obscureText: obscureText ?? false,
              textCapitalization: textCapitalization ?? TextCapitalization.none,
              onChanged: onChanged,
              maxLines: maxLines,
              keyboardType: keyboardType ?? TextInputType.text,
              validator: validator,
              minLines: minLines,
              enabled: enabled,
              onSaved: onSaved,
              onFieldSubmitted: onFieldSubmitted,
              inputFormatters: inputFormatters ?? [],
              decoration: InputDecoration(
                floatingLabelBehavior: labelBehaviour,
                prefixIcon: prefixIcon,
                prefixText: prefixText,
                fillColor: Theme.of(context).focusColor,
                filled: greyBackGround,
                helperText: helperText,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                errorText: errorText,
                hintText: hintText,

                errorStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14, // Adjust based on your design
                      color:
                          Theme.of(context).hintColor, // Use theme's hint color
                      overflow: TextOverflow
                          .ellipsis, // Ensures the hint fits within the field
                    ),

                focusedBorder: disableFocus
                    ? const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      )
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                // border: InputBorder.none,
                suffixText: suffixText,
                suffixIcon: suffixWidget,
                labelText: labelText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
