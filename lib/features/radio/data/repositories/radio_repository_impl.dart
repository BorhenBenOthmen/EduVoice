import 'dart:convert';
import '../../../../core/network/auth_client.dart';
import '../../../../core/auth/token_manager.dart';
import '../../domain/repositories/i_radio_repository.dart';
import '../../domain/entities/radio_emission.dart';
import '../models/radio_model.dart';

class RadioRepositoryImpl implements IRadioRepository {
  final AuthClient client;
  final TokenManager tokenManager;

  RadioRepositoryImpl(this.client, this.tokenManager);

  @override
  Future<List<RadioEmission>> getRadioEmissions({String? query}) async {
    // Hardcoded account_id for now as in other modules
    const int accountId = 1;

    final uri = query != null && query.isNotEmpty
        ? Uri.parse(
            'https://radio.backend.ecocloud.tn/radio/episode/search/$accountId/?name=$query&limit=20&offset=0',
          )
        : Uri.parse(
            'https://radio.backend.ecocloud.tn/radio/episode/list/$accountId/?limit=20&offset=0',
          );

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List items = decoded['items'] ?? [];
      return items.map((json) => RadioModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load radio emissions');
    }
  }
}
