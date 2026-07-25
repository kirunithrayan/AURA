class ViewerPreferences {
  final bool keepScreenAwake;
  final bool restoreLastPosition;

  const ViewerPreferences({
    this.keepScreenAwake = true,
    this.restoreLastPosition = true,
  });

  ViewerPreferences copyWith({
    bool? keepScreenAwake,
    bool? restoreLastPosition,
  }) {
    return ViewerPreferences(
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      restoreLastPosition: restoreLastPosition ?? this.restoreLastPosition,
    );
  }
}
