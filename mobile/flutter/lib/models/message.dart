// lib/models/message.dart

class Message {
  final int id;
  final int serviceId;
  final int senderId;
  final int recipientId;
  final String message;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.serviceId,
    required this.senderId,
    required this.recipientId,
    required this.message,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      serviceId: json['service_id'],
      senderId: json['sender_id'],
      recipientId: json['recipient_id'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
