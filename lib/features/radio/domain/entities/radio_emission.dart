import 'package:equatable/equatable.dart';

class RadioEmission extends Equatable {
  final int id;
  final String title;
  final String description;
  final String? posterUrl;
  final String? audioUrl;
  final List<RadioTranscriptionLine> transcription;

  const RadioEmission({
    required this.id,
    required this.title,
    required this.description,
    this.posterUrl,
    this.audioUrl,
    required this.transcription,
  });

  @override
  List<Object?> get props => [id, title, description, posterUrl, audioUrl, transcription];
}

class RadioTranscriptionLine extends Equatable {
  final double startTime;
  final double endTime;
  final String text;

  const RadioTranscriptionLine({
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  @override
  List<Object?> get props => [startTime, endTime, text];
}
