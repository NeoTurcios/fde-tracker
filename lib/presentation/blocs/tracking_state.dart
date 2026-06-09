part of 'tracking_bloc.dart';

sealed class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

class TrackingInitial extends TrackingState {
  const TrackingInitial();
}

class TrackingLoading extends TrackingState {
  const TrackingLoading();
}

class TrackingLoaded extends TrackingState {
  final TrackingPayload payload;
  final String guideSerie;
  final String guideNumber;

  const TrackingLoaded(this.payload, this.guideSerie, this.guideNumber);

  String get formattedGuide {
    if (guideSerie.isEmpty) return guideNumber;
    return '$guideSerie$guideNumber';
  }

  @override
  List<Object?> get props => [payload, guideSerie, guideNumber];
}

class TrackingError extends TrackingState {
  final String message;

  const TrackingError(this.message);

  @override
  List<Object?> get props => [message];
}