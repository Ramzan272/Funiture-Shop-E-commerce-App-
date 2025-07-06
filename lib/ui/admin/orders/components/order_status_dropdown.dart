import 'package:flutter/material.dart';
import '../../../components/constants.dart';

class OrderStatusDropdown extends StatelessWidget {
  final String currentStatus;
  final Function(String) onStatusChanged;

  const OrderStatusDropdown({
    Key? key,
    required this.currentStatus,
    required this.onStatusChanged,
  }) : super(key: key);

  static const List<String> statusOptions = [
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: currentStatus,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
        items: statusOptions.map((String status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(
              status.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newStatus) {
          if (newStatus != null && newStatus != currentStatus) {
            _showConfirmationDialog(context, newStatus);
          }
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String newStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Order Status'),
          content: Text(
            'Are you sure you want to change the status from "${currentStatus.toUpperCase()}" to "${newStatus.toUpperCase()}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onStatusChanged(newStatus);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
