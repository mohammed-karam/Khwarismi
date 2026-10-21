import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerController extends ChangeNotifier {
  static final TimerController instance = TimerController._internal();

  TimerController._internal();

  static const String _prefTotalSeconds = 'timer.total_seconds';
  static const String _prefRemainingSeconds = 'timer.remaining_seconds';
  static const String _prefIsRunning = 'timer.is_running';
  static const String _prefTargetEndTime = 'timer.target_end_time';
  static const String _prefProblemRating = 'timer.problem_rating';
  static const String _prefHint30Shown = 'timer.hint_30_shown';
  static const String _prefHint60Shown = 'timer.hint_60_shown';

  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  int _problemRating = 1200;
  bool _hint30Shown = false;
  bool _hint60Shown = false;

  Timer? _ticker;
  DateTime? _targetEndTime;
  bool _initialized = false;

  int? _pendingHintMinute;

  int get totalSeconds => _totalSeconds;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isCompleted => _totalSeconds > 0 && _remainingSeconds == 0;
  int get problemRating => _problemRating;
  bool get hint30Shown => _hint30Shown;
  bool get hint60Shown => _hint60Shown;
  int? get pendingHintMinute => _pendingHintMinute;

  double get progress {
    if (_totalSeconds <= 0) return 0.0;
    return (_remainingSeconds / _totalSeconds).clamp(0.0, 1.0);
  }

  int get minutes => _remainingSeconds ~/ 60;
  int get seconds => _remainingSeconds % 60;

  void consumePendingHint() {
    _pendingHintMinute = null;
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _totalSeconds = prefs.getInt(_prefTotalSeconds) ?? (25 * 60);
    _remainingSeconds = prefs.getInt(_prefRemainingSeconds) ?? _totalSeconds;
    _problemRating = prefs.getInt(_prefProblemRating) ?? 1200;
    _hint30Shown = prefs.getBool(_prefHint30Shown) ?? false;
    _hint60Shown = prefs.getBool(_prefHint60Shown) ?? false;
    final wasRunning = prefs.getBool(_prefIsRunning) ?? false;
    final endMillis = prefs.getInt(_prefTargetEndTime);

    if (wasRunning && endMillis != null) {
      _targetEndTime = DateTime.fromMillisecondsSinceEpoch(endMillis);
      final diff = _targetEndTime!.difference(DateTime.now()).inSeconds;
      if (diff > 0) {
        _remainingSeconds = diff;
        _isRunning = true;
        _startTicker();
      } else {
        _remainingSeconds = 0;
        _isRunning = false;
        _saveState();
      }
    } else {
      _isRunning = false;
    }
    notifyListeners();
  }

  void setProblemRating(int rating) {
    _problemRating = rating;
    _saveState();
    notifyListeners();
  }

  void setDurationMinutes(int mins) {
    if (mins <= 0) return;
    _ticker?.cancel();
    _isRunning = false;
    _totalSeconds = mins * 60;
    _remainingSeconds = _totalSeconds;
    _hint30Shown = false;
    _hint60Shown = false;
    _targetEndTime = null;
    _saveState();
    notifyListeners();
  }

  void start() {
    if (_remainingSeconds <= 0) {
      if (_totalSeconds <= 0) _totalSeconds = 25 * 60;
      _remainingSeconds = _totalSeconds;
    }
    _isRunning = true;
    _targetEndTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
    _startTicker();
    _saveState();
    notifyListeners();
  }

  void pause() {
    _isRunning = false;
    _ticker?.cancel();
    _targetEndTime = null;
    _saveState();
    notifyListeners();
  }

  void reset() {
    _ticker?.cancel();
    _isRunning = false;
    _remainingSeconds = _totalSeconds;
    _hint30Shown = false;
    _hint60Shown = false;
    _targetEndTime = null;
    _saveState();
    notifyListeners();
  }

  void addMinutes(int mins) {
    final addedSeconds = mins * 60;
    _totalSeconds += addedSeconds;
    _remainingSeconds += addedSeconds;
    if (_isRunning && _targetEndTime != null) {
      _targetEndTime = _targetEndTime!.add(Duration(seconds: addedSeconds));
    }
    _saveState();
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_targetEndTime != null) {
        final left = _targetEndTime!.difference(DateTime.now()).inSeconds;
        if (left <= 0) {
          _remainingSeconds = 0;
          _isRunning = false;
          _ticker?.cancel();
          _saveState();
          notifyListeners();
          return;
        } else {
          _remainingSeconds = left;
        }
      } else {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isRunning = false;
          _ticker?.cancel();
          _saveState();
          notifyListeners();
          return;
        }
      }

      final elapsed = _totalSeconds - _remainingSeconds;
      if (elapsed >= 30 * 60 && !_hint30Shown) {
        _hint30Shown = true;
        _pendingHintMinute = 30;
      }
      if (elapsed >= 60 * 60 && !_hint60Shown) {
        _hint60Shown = true;
        _pendingHintMinute = 60;
      }

      _saveState();
      notifyListeners();
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefTotalSeconds, _totalSeconds);
    await prefs.setInt(_prefRemainingSeconds, _remainingSeconds);
    await prefs.setInt(_prefProblemRating, _problemRating);
    await prefs.setBool(_prefIsRunning, _isRunning);
    await prefs.setBool(_prefHint30Shown, _hint30Shown);
    await prefs.setBool(_prefHint60Shown, _hint60Shown);
    if (_isRunning && _targetEndTime != null) {
      await prefs.setInt(
        _prefTargetEndTime,
        _targetEndTime!.millisecondsSinceEpoch,
      );
    } else {
      await prefs.remove(_prefTargetEndTime);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
