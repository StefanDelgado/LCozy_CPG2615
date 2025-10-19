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
  
  // Deposit fields
  bool _depositRequired = false;
  int _depositMonths = 1;
  
  // Multiple images
  List<String> _selectedImages = []; // Will store base64 or file paths

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
      final dormData = {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'description': _descriptionController.text.trim(),
        'features': _featuresController.text.trim(),
        'latitude': _selectedLocation!.latitude.toString(),
        'longitude': _selectedLocation!.longitude.toString(),
        'deposit_required': _depositRequired ? '1' : '0',
        'deposit_months': _depositMonths.toString(),
      };
      
      // Add images if any (to be implemented in service layer)
      if (_selectedImages.isNotEmpty) {
        dormData['images'] = _selectedImages.join('|');
      }
      
      await widget.onAdd(dormData);

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
                
                // Deposit Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE9D5FF), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_wallet, 
                            color: Color(0xFF9333EA), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Deposit Requirements',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Require Deposit', 
                          style: TextStyle(fontSize: 14)),
                        subtitle: Text(
                          _depositRequired 
                            ? 'Tenants must pay deposit' 
                            : 'No deposit required',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        value: _depositRequired,
                        activeColor: const Color(0xFF9333EA),
                        onChanged: _isSubmitting ? null : (value) {
                          setState(() => _depositRequired = value);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_depositRequired) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Number of Months:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF9333EA)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _depositMonths,
                                    isExpanded: true,
                                    items: List.generate(12, (index) => index + 1)
                                        .map((month) => DropdownMenuItem(
                                              value: month,
                                              child: Text('$month ${month == 1 ? "month" : "months"}'),
                                            ))
                                        .toList(),
                                    onChanged: _isSubmitting ? null : (value) {
                                      if (value != null) {
                                        setState(() => _depositMonths = value);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF9333EA), Color(0xFFC084FC)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '₱${(_depositMonths * 5000).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Estimated: ₱5,000 per month',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ],
                  ),
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
