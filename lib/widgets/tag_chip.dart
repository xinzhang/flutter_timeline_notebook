import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback? onTap;
  final bool isSelected;

  const TagChip({
    Key? key,
    required this.tag,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text('#$tag'),
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
    );
  }
}
