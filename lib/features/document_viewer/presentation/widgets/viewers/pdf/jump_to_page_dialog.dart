import 'package:flutter/material.dart';

class JumpToPageDialog extends StatefulWidget {

  const JumpToPageDialog({
    super.key,
    required this.currentPage,
    required this.pageCount,
  });
  final int currentPage;
  final int pageCount;

  @override
  State<JumpToPageDialog> createState() => _JumpToPageDialogState();
}

class _JumpToPageDialogState extends State<JumpToPageDialog> {
  late TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentPage.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final val = int.tryParse(_controller.text);
    if (val == null || val < 1 || val > widget.pageCount) {
      setState(() {
        _error = 'Enter a page between 1 and ${widget.pageCount}';
      });
    } else {
      Navigator.of(context).pop(val);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: const Text('Jump to Page'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Page Number',
          errorText: _error,
        ),
        onSubmitted: (_) => _validateAndSubmit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _validateAndSubmit,
          child: const Text('Go'),
        ),
      ],
    );
}
