class TrackingHistoryEntry {
  final String guideSerie;
  final String guideNumber;
  final String statusTitle;
  final String statusDescription;
  final String receiverName;
  final String lastUpdate;
  final bool hasError;

  TrackingHistoryEntry({
    required this.guideSerie,
    required this.guideNumber,
    this.statusTitle = '',
    this.statusDescription = '',
    this.receiverName = '',
    this.lastUpdate = '',
    this.hasError = false,
  });

  String get formattedGuide {
    if (guideSerie.isEmpty) return guideNumber;
    return '$guideSerie$guideNumber';
  }

  TrackingHistoryEntry copyWith({
    String? statusTitle,
    String? statusDescription,
    String? receiverName,
    String? lastUpdate,
    bool? hasError,
  }) {
    return TrackingHistoryEntry(
      guideSerie: guideSerie,
      guideNumber: guideNumber,
      statusTitle: statusTitle ?? this.statusTitle,
      statusDescription: statusDescription ?? this.statusDescription,
      receiverName: receiverName ?? this.receiverName,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      hasError: hasError ?? this.hasError,
    );
  }
}