import '../entities/search_query.dart';
import '../entities/search_event.dart';

abstract class SearchEventBus {
  /// Publishes a search event to all subscribers.
  void publish(SearchEvent event);

  /// Subscribes to search events.
  Stream<SearchEvent> get events;
}
