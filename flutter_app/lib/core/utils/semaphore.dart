import 'dart:async';
import 'dart:collection';

/// Limits concurrent asynchronous operations.
class Semaphore {
  Semaphore(int maxPermits) : _maxPermits = maxPermits, _available = maxPermits;

  // ignore: unused_field
  final int _maxPermits;
  int _available;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();

  Future<T> run<T>(Future<T> Function() action) async {
    if (_available > 0) {
      _available--;
    } else {
      final completer = Completer<void>();
      _waiters.add(completer);
      await completer.future;
    }
    try {
      return await action();
    } finally {
      if (_waiters.isNotEmpty) {
        _waiters.removeFirst().complete();
      } else {
        _available++;
      }
    }
  }
}
