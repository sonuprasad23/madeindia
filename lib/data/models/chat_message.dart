enum ChatSender { user, assistant }

/// A single message in the "Ask Rakshak" assistant conversation.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.sentAt,
    this.isAiAssisted = false,
    this.suggestedQuestions = const [],
  });

  final String id;
  final ChatSender sender;
  final String text;
  final DateTime sentAt;

  /// True when this response was composed with AI-assisted phrasing rather
  /// than a fixed template — still shown with the "review required" label.
  final bool isAiAssisted;
  final List<String> suggestedQuestions;
}
