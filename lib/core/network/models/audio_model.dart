// lib/core/network/models/audio_model.dart

import 'audio_format_model.dart';

class AudioModel {
  final int? id;
  final String? name;
  final String? description;
  final String? duration;
  final int? type;
  final String? typeLabel;
  final String? src;
  final String? file;
  final String? reference;
  final AudioFormatModel? format;

  const AudioModel({
    this.id,
    this.name,
    this.description,
    this.duration,
    this.type,
    this.typeLabel,
    this.src,
    this.file,
    this.reference,
    this.format,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      duration: json['duration'] as String?,
      type: json['type'] as int?,
      typeLabel: json['type_label'] as String?,
      src: json['src'] as String?,
      file: json['file'] as String?,
      reference: json['reference'] as String?,
      format: json['format'] != null
          ? AudioFormatModel.fromJson(json['format'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'duration': duration,
      'type': type,
      'type_label': typeLabel,
      'src': src,
      'file': file,
      'reference': reference,
      // Handle nested serialization safely
      'format': format?.toJson(),
    };
  }
}

class PagedAudioModel {
  final int count;
  final List<AudioModel> items;

  const PagedAudioModel({required this.count, required this.items});

  factory PagedAudioModel.fromJson(Map<String, dynamic> json) {
    return PagedAudioModel(
      count: json['count'] as int? ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => AudioModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
