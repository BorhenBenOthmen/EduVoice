import '../../domain/entities/radio_emission.dart';

abstract class IRadioRepository {
  Future<List<RadioEmission>> getRadioEmissions({String? query});
}
