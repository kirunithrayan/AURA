import '../entities/optimization/search_profile.dart';

abstract class SearchProfiler {
  /// Returns a profile for a specific query ID.
  SearchProfile? getProfile(String queryId);
  
  /// Clears all recorded profiles.
  void clear();
}
