// lib/core/network/models/audio_format_model.dart

class AudioFormatModel {
  final int? id;
  final String? name;
  final String? extension;
  final String? bitRates;
  final String? flowRates;
  final String? frequency;
  final int? channel;
  final String? channelLabel;

  const AudioFormatModel({
    this.id,
    this.name,
    this.extension,
    this.bitRates,
    this.flowRates,
    this.frequency,
    this.channel,
    this.channelLabel,
  });

  factory AudioFormatModel.fromJson(Map<String, dynamic> json) {
    return AudioFormatModel(
      // The backend spec allows ID to be null (integer | null)
      id: json['id'] as int?,
      name: json['name'] as String?,
      extension: json['extension'] as String?,
      bitRates: json['bit_rates'] as String?,
      flowRates: json['flow_rates'] as String?,
      frequency: json['frequency'] as String?,
      channel: json['channel'] as int?,
      channelLabel: json['channel_label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'extension': extension,
      'bit_rates': bitRates,
      'flow_rates': flowRates,
      'frequency': frequency,
      'channel': channel,
      'channel_label': channelLabel,
    };
  }

  // TODO: [Omni-Architect Placeholder] - If we need to implement domain-level equality (e.g., Equatable package), we will add it here later to compare formats efficiently without rebuilding UI.
}

class PagedFormatModel {
  final int count;
  final List<AudioFormatModel> items;

  const PagedFormatModel({
    required this.count,
    required this.items,
  });

  factory PagedFormatModel.fromJson(Map<String, dynamic> json) {
    return PagedFormatModel(
      count: json['count'] as int? ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => AudioFormatModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}