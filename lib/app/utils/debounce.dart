import 'dart:async';

class Debounce {
  final Duration duration;
  Timer? _timer;

  Debounce({this.duration = const Duration(milliseconds: 500)});

  void call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}
