class Booking {
  final int id;
  final String studentName;
  final String studentEmail;
  final String requestedAt;
  final String status;
  final String dormName;
  final String roomType;
  final String duration;
  final String startDate;
  final String price;
  final String message;

  Booking({
    required this.id,
    required this.studentName,
    required this.studentEmail,
    required this.requestedAt,
    required this.status,
    required this.dormName,
    required this.roomType,
    required this.duration,
    required this.startDate,
    required this.price,
    required this.message,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      studentName: json['student_name'] ?? 'No name',
      studentEmail: json['student_email'] ?? 'No email',
      requestedAt: json['requested_at'] ?? 'Unknown',
      status: json['status'] ?? 'pending',
      dormName: json['dorm'] ?? 'Unknown dorm',
      roomType: json['room_type'] ?? 'Unknown type',
      duration: json['duration'] ?? 'Not specified',
      startDate: json['start_date'] ?? 'Not set',
      price: json['price'] ?? '₱0.00',
      message: json['message'] ?? 'No message',
    );
  }
}