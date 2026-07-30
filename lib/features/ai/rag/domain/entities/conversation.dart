import 'package:equatable/equatable.dart';

enum MessageRole { user, ai, system }

class ChatMessage extends Equatable {

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  @override
  List<Object?> get props => [id, role, content, timestamp];
}

class Conversation extends Equatable {

  const Conversation({
    required this.id,
    required this.title,
    required this.workspaceId,
    this.messages = const [],
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String title;
  final String workspaceId;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation copyWith({
    String? title,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
  }) => Conversation(
      id: id,
      title: title ?? this.title,
      workspaceId: workspaceId,
      messages: messages ?? this.messages,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );

  @override
  List<Object?> get props => [
        id,
        title,
        workspaceId,
        messages,
        createdAt,
        updatedAt,
      ];
}
