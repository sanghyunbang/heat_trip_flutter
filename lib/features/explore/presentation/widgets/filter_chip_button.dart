import 'package:flutter/material.dart';

class FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const FilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
        ),
      ),
    );
  }
}
