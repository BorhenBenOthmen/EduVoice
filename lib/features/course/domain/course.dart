class Course {
  final String id;
  final String title;
  final String description;

  Course({
    required this.id,
    required this.title,
    required this.description,
  });

  // TODO: Future Backend Integration - Add factory to parse Django JSON
  // factory Course.fromJson(Map<String, dynamic> json) { ... }
} 