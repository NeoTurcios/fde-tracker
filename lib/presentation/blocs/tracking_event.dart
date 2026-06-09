part of 'tracking_bloc.dart';

sealed class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

class TrackPackageEvent extends TrackingEvent {
  final String guideNumber;
  final String baseUrl;

  const TrackPackageEvent(this.guideNumber, {this.baseUrl = 'https://rastreo.forzadelivery.com/fd/Home.aspx/API'});

  @override
  List<Object?> get props => [guideNumber, baseUrl];
}

class ClearTrackingEvent extends TrackingEvent {}