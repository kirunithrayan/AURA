import 'package:flutter/material.dart';
import '../../../ai/rag/domain/services/ai_key_store.dart';

/// Lets the user enter, replace, or remove the Gemini API key.
///
/// The key is written to platform secure storage and read back only when a
/// query is issued, so it never appears in the compiled binary.
class AiKeyDialog extends StatefulWidget {
  const AiKeyDialog({super.key, required this.keyStore});

  final AiKeyStore keyStore;

  @override
  State<AiKeyDialog> createState() => _AiKeyDialogState();
}

class _AiKeyDialogState extends State<AiKeyDialog> {
  final _controller = TextEditingController();
  bool _obscured = true;
  bool _hasExistingKey = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    widget.keyStore.hasApiKey().then((has) {
      if (mounted) setState(() => _hasExistingKey = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;

    setState(() => _busy = true);
    await widget.keyStore.saveApiKey(value);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _remove() async {
    setState(() => _busy = true);
    await widget.keyStore.clearApiKey();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Gemini API Key'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _hasExistingKey
                ? 'A key is already stored. Entering a new one replaces it.'
                : 'Ask AURA needs a Google Gemini API key. Get one free at '
                    'aistudio.google.com.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: _obscured,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'API key',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscured = !_obscured),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Stored in the Android Keystore on this device only.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        if (_hasExistingKey)
          TextButton(
            onPressed: _busy ? null : _remove,
            child: Text(
              'Remove',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
