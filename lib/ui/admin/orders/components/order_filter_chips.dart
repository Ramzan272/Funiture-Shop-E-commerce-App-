import 'package:flutter/material.dart';
import '../../../components/constants.dart';

class OrderFilterChips extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const OrderFilterChips({
    Key? key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter == 'All' ? filter : filter.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : kPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  onFilterChanged(filter);
                }
              },
              selectedColor: kPrimaryColor,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? kPrimaryColor : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }
}
