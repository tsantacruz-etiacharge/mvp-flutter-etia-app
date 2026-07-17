import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/message_provider.dart';
import '../theme/colors.dart';

class MessageOverlay extends ConsumerWidget {
  const MessageOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(messageProvider);
    final topInset = MediaQuery.of(context).padding.top;

    if (message == null) return const SizedBox.shrink();

    final color = message.type == MessageType.error
        ? AppColors.error
        : AppColors.success;

    return Positioned(
      top: topInset + 40,
      left: 48,
      right: 48,
      child: GestureDetector(
        onTap: () => ref.read(messageProvider.notifier).clear(),
        child: Container(
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            message.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
