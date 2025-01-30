import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String labelText;
  final VoidCallback onDelete;
  const CustomChip({
    super.key,
    required this.labelText,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.1)
          : Theme.of(context).colorScheme.primary.withOpacity(0.1),
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          style: BorderStyle.none,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(
            20,
          ),
        ),
      ),
      label: Text(
        labelText,
      ),
      deleteIcon: Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
      onDeleted: onDelete,
    );
  }
}
