import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MessageType { error, success }

class MessageState {
  final MessageType type;
  final String message;

  MessageState(this.type, this.message);
}

final messageProvider =
    StateNotifierProvider<MessageNotifier, MessageState?>((ref) {
  return MessageNotifier();
});

class MessageNotifier extends StateNotifier<MessageState?> {
  MessageNotifier() : super(null);

  Timer? _timer;

  void _show(String message, MessageType type) {
    _timer?.cancel();
    state = MessageState(type, message);
    _timer = Timer(const Duration(seconds: 5), () {
      state = null;
    });
  }

  void showError(String message) => _show(message, MessageType.error);
  void showSuccess(String message) => _show(message, MessageType.success);
  void clear() {
    _timer?.cancel();
    state = null;
  }
}
