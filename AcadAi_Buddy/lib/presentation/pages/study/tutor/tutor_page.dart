import 'package:flutter/material.dart';

import '../../../core/widgets/states.dart';
import '../chat/start_chat.dart';

/// Tutor tab: chat history (filled in with the chat history work).
class TutorPage extends StatelessWidget {
  const TutorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutor')),
      body: EmptyState(
        icon: Icons.forum_rounded,
        title: 'Ask the tutor anything',
        message: 'Pick a subject and start a study session.',
        actionLabel: 'New chat',
        actionIcon: Icons.add_rounded,
        onAction: () => startNewChat(context),
      ),
    );
  }
}
