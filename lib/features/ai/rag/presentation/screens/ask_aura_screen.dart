import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../viewmodels/ask_aura_viewmodel.dart';
import '../viewmodels/ask_aura_state.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/citation.dart';
import '../../../../document_viewer/presentation/screens/document_viewer_screen.dart';
import '../../../../../core/widgets/aura_chip.dart';

class AskAuraScreen extends ConsumerStatefulWidget {

  const AskAuraScreen({super.key, required this.workspaceId});
  final String workspaceId;

  @override
  ConsumerState<AskAuraScreen> createState() => _AskAuraScreenState();
}

class _AskAuraScreenState extends ConsumerState<AskAuraScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(askAuraViewModelProvider.notifier).initConversation(widget.workspaceId);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(askAuraViewModelProvider);

    // Auto-scroll when new content arrives
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask AURA'),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildChatHistory(state),
          ),
          _buildInputArea(state.status == AskAuraStatus.loading || state.status == AskAuraStatus.streaming),
        ],
      ),
    );
  }

  Widget _buildChatHistory(AskAuraState state) {
    final messages = state.activeConversation?.messages ?? [];
    
    if (messages.isEmpty && state.status == AskAuraStatus.initial) {
      return const Center(child: Text('Ask me anything about your documents!'));
    }

    final hasTrailingBubble = state.status == AskAuraStatus.streaming ||
        state.status == AskAuraStatus.loading ||
        state.status == AskAuraStatus.error;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: messages.length + (hasTrailingBubble ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          // Active streaming bubble, or the failure that ended the turn.
          return state.status == AskAuraStatus.error
              ? _buildErrorBubble(state)
              : _buildStreamingBubble(state);
        }

        final msg = messages[index];
        return _buildMessageBubble(msg, state);
      },
    );
  }

  /// Renders a failed turn.
  ///
  /// Without this the error status produced no widget at all: the user saw
  /// their own question and nothing else, so a missing API key or a rejected
  /// key was indistinguishable from the app hanging.
  Widget _buildErrorBubble(AskAuraState state) {
    final theme = Theme.of(context);
    final message = state.errorMessage?.trim();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.error),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 20,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message == null || message.isEmpty
                    ? "Something went wrong and AURA couldn't answer."
                    : message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, AskAuraState state) {
    final isUser = message.role == MessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isUser ? null : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: message.content,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: isUser ? Colors.white : null),
              ),
            ),
            // We only have citations active on the streaming/latest message for now in this simplified view, 
            // but in a production app we would store citations in ChatMessage.
          ],
        ),
      ),
    );
  }

  Widget _buildStreamingBubble(AskAuraState state) {
    if (state.status == AskAuraStatus.loading) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final response = state.latestResponse;
    if (response == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(data: response.text),
            if (response.citations.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const Text('Sources', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: response.citations.map(_buildCitationChip).toList(),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCitationChip(Citation citation) => AuraChip(
      label: '[${citation.index}] ${citation.fileName}',
      icon: Icons.article_outlined,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DocumentViewerScreen(documentId: citation.documentId),
          ),
        );
      },
    );

  Widget _buildInputArea(bool isProcessing) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                enabled: !isProcessing,
                decoration: const InputDecoration(
                  hintText: 'Ask a question...',
                  border: InputBorder.none,
                ),
                onSubmitted: isProcessing ? null : (_) => _submit(),
              ),
            ),
            IconButton(
              icon: isProcessing ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
              onPressed: isProcessing ? null : _submit,
            ),
          ],
        ),
      ),
    );

  void _submit() {
    final query = _textController.text;
    if (query.isNotEmpty) {
      _textController.clear();
      ref.read(askAuraViewModelProvider.notifier).submitQuery(query);
    }
  }
}
