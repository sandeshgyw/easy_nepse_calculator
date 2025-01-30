import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final bool loading;
  final Color? color;
  final Color? borderColor;
  final EdgeInsets? margin, padding;
  final Function()? onPress;
  final BorderRadius? borderRadius;
  final String text;
  final IconData? leftIcon, rightIcon;
  final FocusNode? focusNode;
  final double? height, width;
  final TextStyle? textStyle;
  final Color? iconColor;
  const CustomButton({
    Key? key,
    this.color,
    required this.text,
    this.margin,
    this.padding,
    this.onPress,
    this.leftIcon,
    this.loading = false,
    this.borderRadius,
    this.height,
    this.width,
    this.rightIcon,
    this.borderColor,
    this.textStyle,
    this.iconColor,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: width ?? MediaQuery.of(context).size.width * 0.8,
        margin: margin,
        decoration: BoxDecoration(
            color: color ?? Theme.of(context).colorScheme.primaryContainer,
            borderRadius: borderRadius ?? BorderRadius.circular(50),
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : Border.all(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  )),
        child: TextButton(
          focusNode: focusNode,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(50),
            ),
          ),
          onPressed: onPress,
          child: Container(
            padding: padding ?? const EdgeInsets.all(15),
            child: loading
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (leftIcon != null)
                        Icon(
                          leftIcon,
                          size: 18,
                          color: iconColor ??
                              Theme.of(context).colorScheme.inversePrimary,
                        ),
                      if (leftIcon != null) const SizedBox(width: 10),
                      Text(
                        text,
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                      ),
                      if (rightIcon != null) const SizedBox(width: 10),
                      if (rightIcon != null)
                        Icon(
                          rightIcon,
                          size: 18,
                          color: iconColor ?? Theme.of(context).iconTheme.color,
                        ),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
