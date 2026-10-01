/// Connection state reported by the weigh scale service.
enum ScaleConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// A snapshot of the weigh scale's connection and reading state.
///
/// The status stream emits a new [ScaleStatus] whenever the connection state,
/// stability, or the live reading changes. Consumers (e.g. the bill screen
/// and the settings diagnostics panel) should react to [isConnected] and
/// [stale].
class ScaleStatus {
  final ScaleConnectionState state;
  final double? currentWeightKg;
  final bool stable;
  final bool isMotion;
  final bool isOverload;
  final bool stale;
  final DateTime? lastReceivedAt;
  final String? error;
  final int reconnectAttempt;

  const ScaleStatus({
    this.state = ScaleConnectionState.disconnected,
    this.currentWeightKg,
    this.stable = false,
    this.isMotion = false,
    this.isOverload = false,
    this.stale = false,
    this.lastReceivedAt,
    this.error,
    this.reconnectAttempt = 0,
  });

  bool get isConnected => state == ScaleConnectionState.connected;

  bool get isTransitioning =>
      state == ScaleConnectionState.connecting ||
      state == ScaleConnectionState.reconnecting;

  ScaleStatus copyWith({
    ScaleConnectionState? state,
    double? currentWeightKg,
    bool clearCurrentWeight = false,
    bool? stable,
    bool? isMotion,
    bool? isOverload,
    bool? stale,
    DateTime? lastReceivedAt,
    String? error,
    bool clearError = false,
    int? reconnectAttempt,
  }) {
    return ScaleStatus(
      state: state ?? this.state,
      currentWeightKg: clearCurrentWeight
          ? null
          : (currentWeightKg ?? this.currentWeightKg),
      stable: stable ?? this.stable,
      isMotion: isMotion ?? this.isMotion,
      isOverload: isOverload ?? this.isOverload,
      stale: stale ?? this.stale,
      lastReceivedAt: lastReceivedAt ?? this.lastReceivedAt,
      error: clearError ? null : (error ?? this.error),
      reconnectAttempt: reconnectAttempt ?? this.reconnectAttempt,
    );
  }
}
