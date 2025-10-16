import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../location_picker_widget.dart';

/// Dialog for adding a new dormitory
class AddDormDialog extends StatefulWidget {
  final Future<void> Function(Map<String, String> dormData) onAdd;

  const AddDormDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddDormDialog> createState() => _AddDormDialogState();
}

class _AddDormDialogState extends State<AddDormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _featuresController = TextEditingController();
  bool _isSubmitting = false;
  LatLng? _selectedLocation;
  String? _selectedAddress;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Validate location
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.onAdd({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'description': _descriptionController.text.trim(),
        'features': _featuresController.text.trim(),
        'latitude': _selectedLocation!.latitude.toString(),
        'longitude': _selectedLocation!.longitude.toString(),
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
      title: const Text('Add New Dormitory'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Dorm Name',
                    prefixIcon: Icon(Icons.home),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Name is required' : null,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                    helperText: 'Or use map below to auto-fill',
                    helperMaxLines: 2,
                  ),
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Address is required' : null,
                  enabled: !_isSubmitting,
                  onChanged: (value) {
                    // Update selected address when manually typed
                    _selectedAddress = value;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Description is required' : null,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _featuresController,
                  decoration: const InputDecoration(
                    labelText: 'Features',
                    prefixIcon: Icon(Icons.star),
                    border: OutlineInputBorder(),
                    helperText: 'Comma separated (e.g., WiFi, Aircon, Parking)',
                    helperMaxLines: 2,
                  ),
                  maxLines: 2,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 24),
                
                // Location Picker Section
                const Text(
                  'Dorm Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(height: 8),
                LocationPickerWidget(
                  onLocationSelected: (location, address) {
                    setState(() {
                      _selectedLocation = location;
                      _selectedAddress = address;
                      
                      // Update address field if address is available
                      if (address != null && address.isNotEmpty) {
                        _addressController.text = address;
                      }
                    });
                  },
                  showAddressSearch: true,
                  initialAddress: _selectedAddress,
                ),
              ],
            ),
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
              : const Text('Add Dorm'),
        ),
      ],
    );
  }
}
