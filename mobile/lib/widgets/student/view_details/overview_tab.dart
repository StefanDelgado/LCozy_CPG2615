import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../utils/helpers.dart';

class OverviewTab extends StatelessWidget {
  final Map<String, dynamic> dormDetails;
  final List<String> features;

  const OverviewTab({
    Key? key,
    required this.dormDetails,
    required this.features,
  }) : super(key: key);

  double _parseDouble(dynamic value, double defaultValue) {
    return Helpers.parseDouble(value, defaultValue);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About This Dorm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            Helpers.safeText(dormDetails['description'], 'No description available.'),
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          if (features.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Features & Amenities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            )),
          ],
          const SizedBox(height: 24),
          const Text(
            'Location',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          kIsWeb
              ? Container(
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Map not available on web',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _parseDouble(dormDetails['latitude'], 10.6765),
                          _parseDouble(dormDetails['longitude'], 122.9509),
                        ),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('dorm'),
                          position: LatLng(
                            _parseDouble(dormDetails['latitude'], 10.6765),
                            _parseDouble(dormDetails['longitude'], 122.9509),
                          ),
                          infoWindow: InfoWindow(
                            title: dormDetails['name']?.toString() ?? '',
                          ),
                        ),
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
