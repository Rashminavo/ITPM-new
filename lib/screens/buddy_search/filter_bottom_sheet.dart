import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? selectedFaculty;
  final String? selectedHostel;
  final String? selectedAvailability;
  final Function(String?, String?, String?) onApply;

  const FilterBottomSheet({
    super.key,
    this.selectedFaculty,
    this.selectedHostel,
    this.selectedAvailability,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _faculty;
  String? _hostel;
  String? _availability;

  @override
  void initState() {
    super.initState();
    _faculty = widget.selectedFaculty;
    _hostel = widget.selectedHostel;
    _availability = widget.selectedAvailability;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _faculty = null;
                    _hostel = null;
                    _availability = null;
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDropdown('Faculty', AppStrings.faculties, _faculty, (v) => setState(() => _faculty = v)),
          const SizedBox(height: 12),
          _buildDropdown('Hostel', AppStrings.hostels, _hostel, (v) => setState(() => _hostel = v)),
          const SizedBox(height: 12),
          _buildDropdown('Availability', AppStrings.availabilitySlots, _availability, (v) => setState(() => _availability = v)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_faculty, _hostel, _availability);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem(value: null, child: Text('Any')),
        ...items.map((item) => DropdownMenuItem(value: item, child: Text(item))),
      ],
      onChanged: onChanged,
    );
  }
}