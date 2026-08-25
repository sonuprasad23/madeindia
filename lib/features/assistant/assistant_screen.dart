import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_logo.dart';
import '../../data/models/case_record.dart';
import '../../data/models/chat_message.dart';
import '../../data/repositories/case_repository.dart';
import 'assistant_engine.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key, this.seedQuestion, this.focusedCaseId});

  final String? seedQuestion;
  final String? focusedCaseId;

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        id: _uuid.v4(),
        sender: ChatSender.assistant,
        text:
            'Hi, I\'m Ask Rakshak. I can explain how the app works, what a case status means, or general next '
            'steps. I don\'t determine outcomes or represent any authority.',
        sentAt: DateTime.now(),
      ),
    );
    if (widget.seedQuestion != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _send(widget.seedQuestion!),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  CaseRecord? get _focusedCase {
    if (widget.focusedCaseId == null) return null;
    final matches = ref
        .read(caseRepositoryProvider)
        .where((c) => c.id == widget.focusedCaseId);
    return matches.isEmpty ? null : matches.first;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: _uuid.v4(),
          sender: ChatSender.user,
          text: trimmed,
          sentAt: DateTime.now(),
        ),
      );
      _controller.clear();
    });
    _scrollToBottom();

    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final response = AssistantEngine.respond(
        trimmed,
        focusedCase: _focusedCase,
      );
      setState(() {
        _messages.add(
          ChatMessage(
            id: _uuid.v4(),
            sender: ChatSender.assistant,
            text: response,
            sentAt: DateTime.now(),
            isAiAssisted: true,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RakshakLogo(size: 24, variant: RakshakLogoVariant.compact),
            SizedBox(width: Spacing.sm),
            Text('Ask Rakshak'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: theme.colorScheme.secondaryContainer,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.sm,
            ),
            child: Text(
              'AI-assisted explanations — review required. Not a substitute for legal or police advice.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(Spacing.lg),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _bubble(context, _messages[index]),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              children: AssistantEngine.suggestedQuestions
                  .map(
                    (q) => Padding(
                      padding: const EdgeInsets.only(right: Spacing.sm),
                      child: ActionChip(
                        label: Text(q),
                        onPressed: () => _send(q),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                0,
                Spacing.lg,
                Spacing.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      decoration: const InputDecoration(
                        hintText: 'Ask a question…',
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  IconButton.filled(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: () => _send(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(BuildContext context, ChatMessage message) {
    final theme = Theme.of(context);
    final isUser = message.sender == ChatSender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: Spacing.md),
        padding: const EdgeInsets.all(Spacing.md),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        child: Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
