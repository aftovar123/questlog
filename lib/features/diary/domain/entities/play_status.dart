/// Where a game sits in the player's personal backlog.
enum PlayStatus {
  backlog,
  playing,
  completed;

  /// Stored as a plain string in Hive — explicit names, not `.index`, so
  /// reordering this enum later can't silently corrupt saved data.
  String toStorageValue() => name;

  static PlayStatus fromStorageValue(String value) {
    return PlayStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PlayStatus.backlog,
    );
  }
}
