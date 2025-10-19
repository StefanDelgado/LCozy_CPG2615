import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'package:flutter/services.dart';

/// Dialog for adding or editing a room
class AddRoomDialog extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> roomData) onAdd;
  final Map<String, dynamic>? initialData;
  final bool isEdit;

  const AddRoomDialog({
    super.key,
    required this.onAdd,
    this.initialData,
    this.isEdit = false,
  });

  @override
  State<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedRoomType;
  bool _isSubmitting = false;

  final List<String> roomTypes = ['Single', 'Double', 'Twin', 'Suite'];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _selectedRoomType = widget.initialData!['room_type'];
      _capacityController.text = widget.initialData!['capacity']?.toString() ?? '';
      _priceController.text = widget.initialData!['price']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedRoomType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a room type')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.onAdd({
        'room_type': _selectedRoomType!,
        'capacity': int.parse(_capacityController.text.trim()),
        'price': double.parse(_priceController.text.trim()),
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Error handled by parent
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Edit Room' : 'Add New Room'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedRoomType,
                decoration: const InputDecoration(
                  labelText: 'Room Type',
                  prefixIcon: Icon(Icons.bed),
                  border: OutlineInputBorder(),
                ),
                items: roomTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) => setState(() => _selectedRoomType = value),
                validator: (value) => value == null ? 'Please select a room type' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                  helperText: 'Number of occupants',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Capacity is required';
                  }
                  final capacity = int.tryParse(value!);
                  if (capacity == null || capacity <= 0) {
                    return 'Please enter a valid capacity';
                  }
                  return null;
                },
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: const OutlineInputBorder(),
                  helperText: 'Monthly rent in PHP',
                  prefixText: '₱ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Price is required';
                  }
                  final price = double.tryParse(value!);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
                enabled: !_isSubmitting,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.isEdit ? 'Save Changes' : 'Add Room'),
        ),
      ],
    );
  }
}
