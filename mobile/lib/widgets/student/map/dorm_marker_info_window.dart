import 'package:flutter/material.dart';

/// Custom info window widget for dorm markers on the map.
/// 
/// Displays dorm information when a marker is tapped.
/// Not directly used as Google Maps InfoWindow, but as a custom overlay.
/// 
/// Shows:
/// - Dorm name
/// - Price per month
/// - Address (truncated)
/// - "View Details" button
class DormMarkerInfoWindow extends StatelessWidget {
  final Map<String, dynamic> dorm;
  final VoidCallback onTap;

  const DormMarkerInfoWindow({
    super.key,
    required this.dorm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = dorm['name'] ?? 'Unknown Dorm';
    final price = dorm['price_per_month'] ?? dorm['price'] ?? '0';
    final address = dorm['address'] ?? 'No address';

    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dorm Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5CF6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                
                // Price
                Row(
                  children: [
                    const Icon(
                      Icons.payments,
                      size: 16,
                      color: Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '₱$price/month',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // View Details Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
