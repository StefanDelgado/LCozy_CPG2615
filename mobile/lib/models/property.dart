class Property {
  final int dormId;
  final String image;
  final String location;
  final String title;
  final String description;
  final String ownerEmail;
  final String ownerName;
  final int availableRooms;
  final String minPrice;
  final String type;
  final List<String> features;

  Property({
    required this.dormId,
    required this.image,
    required this.location,
    required this.title,
    required this.description,
    required this.ownerEmail,
    required this.ownerName,
    required this.availableRooms,
    required this.minPrice,
    required this.type,
    required this.features,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      dormId: json['dorm_id'],
      image: json['image'] ?? '',
      location: json['location'] ?? '',
      title: json['title'] ?? '',
      description: json['desc'] ?? '',
      ownerEmail: json['owner_email'] ?? '',
      ownerName: json['owner_name'] ?? '',
      availableRooms: json['available_rooms'] ?? 0,
      minPrice: json['min_price'] ?? '₱0.00',
      type: json['type'] ?? 'Other',
      features: (json['features'] as String?)?.split(',').map((e) => e.trim()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'dorm_id': dormId,
    'image': image,
    'location': location,
    'title': title,
    'desc': description,
    'owner_email': ownerEmail,
    'owner_name': ownerName,
    'available_rooms': availableRooms,
    'min_price': minPrice,
    'type': type,
    'features': features.join(', '),
  };
}