import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:phone_state/phone_state.dart';

class PhoneCallService {
  static StreamSubscription? _subscription;
  static bool _isOnCall = false;
  static final List<VoidCallback> _callStartListeners = [];
  static final List<VoidCallback> _callEndListeners = [];

  static bool get isOnCall => _isOnCall;

  static void addCallStartListener(VoidCallback cb) => _callStartListeners.add(cb);
  static void addCallEndListener(VoidCallback cb) => _callEndListeners.add(cb);
  static void removeCallStartListener(VoidCallback cb) => _callStartListeners.remove(cb);
  static void removeCallEndListener(VoidCallback cb) => _callEndListeners.remove(cb);

  static void init() {
    _subscription = PhoneState.stream.listen((state) {
      switch (state.status) {
        case PhoneStateStatus.CALL_INCOMING:
        case PhoneStateStatus.CALL_STARTED:
          if (!_isOnCall) {
            _isOnCall = true;
            for (final cb in List.from(_callStartListeners)) {
              cb();
            }
          }
          break;
        case PhoneStateStatus.CALL_ENDED:
        case PhoneStateStatus.NOTHING:
          if (_isOnCall) {
            _isOnCall = false;
            for (final cb in List.from(_callEndListeners)) {
              cb();
            }
          }
          break;
      }
    });
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _callStartListeners.clear();
    _callEndListeners.clear();
  }
}
