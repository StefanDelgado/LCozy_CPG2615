import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../location_picker_widget.dart';

/// Dialog for editing an existing dormitory
class EditDormDialog extends StatefulWidget {
  final Map<String, dynamic> dorm;
  final Future<void> Function(String dormId, Map<String, String> dormData) onUpdate;

  const EditDormDialog({
    super.key,
    required this.dorm,
    required this.onUpdate,
  });

  @override
  State<EditDormDialog> createState() => _EditDormDialogState();
}

class _EditDormDialogState extends State<EditDormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _featuresController;
  bool _isSubmitting = false;
  LatLng? _selectedLocation;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data
    _nameController = TextEditingController(text: widget.dorm['name'] ?? '');
    _addressController = TextEditingController(text: widget.dorm['address'] ?? '');
    _descriptionController = TextEditingController(text: widget.dorm['description'] ?? widget.dorm['desc'] ?? '');
    _featuresController = TextEditingController(text: widget.dorm['features'] ?? widget.dorm['amenities'] ?? '');
    
    // Initialize location if available
    final lat = widget.dorm['latitude'];
    final lng = widget.dorm['longitude'];
    
    if (lat != null && lng != null) {
      try {
        final latitude = double.parse(lat.toString());
        final longitude = double.parse(lng.toString());
        if (latitude != 0.0 && longitude != 0.0) {
          _selectedLocation = LatLng(latitude, longitude);
        }
      } catch (e) {
        print('Error parsing location: $e');
        _selectedLocation = null;
      }
    }
    
    // Use address from dorm data
    _selectedAddress = widget.dorm['address'];
    
    // Show hint if location is missing
    if (_selectedLocation == null && _selectedAddress != null && _selectedAddress!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📍 Tip: Search the address in the map below to set location'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      });
    }
  }

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
        const SnackBar(
          content: Text('Please select a valid location on the map'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dormId = widget.dorm['dorm_id']?.toString() ?? widget.dorm['id']?.toString();
      
      if (dormId == null) {
        throw Exception('Invalid dorm ID');
      }

      await widget.onUpdate(dormId, {
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
      title: const Text('Edit Dormitory'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dorm Name
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
                
                // Address
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
                    _selectedAddress = value;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description
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
                
                // Features
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
                Row(
                  children: [
                    const Text(
                      'Dorm Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                    const Spacer(),
                    if (_selectedLocation != null)
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Location Set',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'No Location',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (_selectedLocation == null)
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Search the address below to set map location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Address: ${_selectedAddress ?? "No address"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (_selectedLocation != null)
                  Text(
                    'Coordinates: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                const SizedBox(height: 8),
                
                LocationPickerWidget(
                  initialLocation: _selectedLocation,
                  initialAddress: _selectedAddress,
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
            backgroundColor: Colors.orange,
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
              : const Text('Update Dorm'),
        ),
      ],
    );
  }
}
