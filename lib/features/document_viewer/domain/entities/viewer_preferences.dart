class ViewerPreferences {

  const ViewerPreferences({
    this.keepScreenAwake = true,
    this.restoreLastPosition = true,
  });
  final bool keepScreenAwake;
  final bool restoreLastPosition;

  ViewerPreferences copyWith({
    bool? keepScreenAwake,
    bool? restoreLastPosition,
  }) => ViewerPreferences(
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      restoreLastPosition: restoreLastPosition ?? this.restoreLastPosition,
    );
}
