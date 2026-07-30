abstract class AiStreamEvent {
  const AiStreamEvent();
}

class AiStreamToken extends AiStreamEvent {
  const AiStreamToken(this.text);
  final String text;
}

class AiStreamComplete extends AiStreamEvent {
  const AiStreamComplete(this.fullResponse);
  final String fullResponse;
}

class AiStreamError extends AiStreamEvent {
  const AiStreamError(this.message);
  final String message;
}
