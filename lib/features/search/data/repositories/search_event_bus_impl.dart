import 'dart:async';
import '../../domain/entities/search_event.dart';
import '../../domain/repositories/search_event_bus.dart';

class SearchEventBusImpl implements SearchEventBus {
  final StreamController<SearchEvent> _controller = StreamController<SearchEvent>.broadcast();

  @override
  void publish(SearchEvent event) {
    _controller.add(event);
  }

  @override
  Stream<SearchEvent> get events => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
