// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/service.dart';
import '../models/message.dart';

class ApiService {
  static Future<List<Service>> fetchServices() async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}${Constants.servicesEndpoint}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Service.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }

  static Future<List<Message>> fetchMessages(int serviceId) async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}${Constants.chatEndpoint}/$serviceId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  static Future<bool> sendMessage(int serviceId, int senderId, int recipientId, String message) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}${Constants.chatEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'service_id': serviceId,
        'sender_id': senderId,
        'recipient_id': recipientId,
        'message': message,
      }),
    );
    return response.statusCode == 201;
  }

  // Otros métodos para registro, login y creación de servicio pueden añadirse aquí
}
