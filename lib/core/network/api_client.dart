import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient {
  // ⚠️ CRITICAL: Replace YOUR_PC_IP with your computer's actual IPv4 address.
  // Open terminal, type 'ipconfig', find IPv4 Address (e.g., 192.168.1.15)
  // Ensure your Django server is running via: python manage.py runserver 0.0.0.0:8000
  final String baseUrl = "http://YOUR_PC_IP:8000/api"; 

  Future<String> sendVoiceCommand(String command) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/voice-command/'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'command': command}),
      ).timeout(const Duration(seconds: 10)); // Don't let the app hang forever

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming Django returns: {"reply": "Voici votre cours sur l'architecture SOA..."}
        return data['reply'] ?? "Commande traitée."; 
      } else {
        debugPrint("Server Error: ${response.statusCode} - ${response.body}");
        return "Erreur du serveur. Le code est ${response.statusCode}.";
      }
    } catch (e) {
      debugPrint("Network Error: $e");
      return "Impossible de joindre le serveur Edu Voice. Vérifiez votre connexion.";
    }
  }

  Future<String> sendVoiceCommandAudio(File audioFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/voice-command-audio/'),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Fallback to "Commande traitée" if 'reply' key is missing
        return data['reply'] ?? "Commande traitée."; 
      } else {
        debugPrint("Server Error: ${response.statusCode} - ${response.body}");
        return "Erreur du serveur lors du traitement vocal. Code: ${response.statusCode}.";
      }
    } catch (e) {
      debugPrint("Network Error: $e");
      return "Impossible de joindre le serveur Edu Voice. Vérifiez votre connexion.";
    }
  }
}