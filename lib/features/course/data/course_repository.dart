import '../../../features/course/domain/course.dart';

class CourseRepository {
  /// MOCK API CALL: Simulates fetching courses from the Django backend.
  /// 
  /// TODO: Phase 5 - Replace this entire method body with an http.get request 
  /// to http://[SERVER_IP]/api/courses/ and parse the returned JSON.
  Future<List<Course>> fetchAvailableCourses() async {
    // 1. Simulate a 1.5-second network latency
    await Future.delayed(const Duration(milliseconds: 1500));

    // 2. Return hardcoded mock data for offline UI testing
    return [
      Course(
        id: 'c1', 
        title: 'Architecture SOA', 
        description: 'Création d\'une architecture distribuée et intégration SOAP/REST.'
      ),
      Course(
        id: 'c2', 
        title: 'Big Data', 
        description: 'Analyse de données massives et traitement distribué.'
      ),
      Course(
        id: 'c3', 
        title: 'Sécurité Informatique', 
        description: 'Cryptographie, sécurisation des réseaux et des systèmes.'
      ),
    ];
  }
}