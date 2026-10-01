import 'dart:async';

/// Lightweight reading timer service for the PDF reader.
///
/// Tracks elapsed reading time in seconds. Does NOT extend ChangeNotifier —
/// the [PdfReaderScreen] holds this and calls [elapsed] directly on rebuild.
///
/// Modular: dictionary / text-selection features can call [pause] / [resume]
/// without touching AppState.
class PdfSessionService {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _running = false;

  /// Total seconds of active reading time accumulated this session.
  int get elapsedSeconds => _elapsedSeconds;

  bool get isRunning => _running;

  /// Human-readable elapsed time, e.g. "02:34" or "1:12:05".
  String get formattedElapsed {
    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    final s = _elapsedSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  /// Callback invoked every second — update state in the caller.
  final void Function()? onTick;

  PdfSessionService({this.onTick});

  void start() {
    if (_running) return;
    _running = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      onTick?.call();
    });
  }

  void pause() {
    if (!_running) return;
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  void resume() {
    if (_running) return;
    start();
  }

  /// Stops the timer and returns total seconds elapsed this session.
  int stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
    return _elapsedSeconds;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

