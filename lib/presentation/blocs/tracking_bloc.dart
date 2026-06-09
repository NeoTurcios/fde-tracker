import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/api/forza_api_client.dart';
import '../../data/models/tracking_response.dart';
import '../../core/utils.dart';

part 'tracking_state.dart';
part 'tracking_event.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final ForzaApiClient _apiClient;

  TrackingBloc({ForzaApiClient? apiClient})
      : _apiClient = apiClient ?? ForzaApiClient(),
        super(const TrackingInitial()) {
    on<TrackPackageEvent>(_onTrackPackage);
    on<ClearTrackingEvent>(_onClearTracking);
  }

  Future<void> _onTrackPackage(
    TrackPackageEvent event,
    Emitter<TrackingState> emit,
  ) async {
    emit(const TrackingLoading());

    final parsed = GuideParser.parse(event.guideNumber);
    if (!GuideParser.isValid(event.guideNumber)) {
      emit(const TrackingError('Número de guía inválido'));
      return;
    }

    final response = await _apiClient.getTrackingPublic(
      guideSerie: parsed.serie,
      guideNumber: parsed.number,
      baseUrl: event.baseUrl,
    );

    if (response.success && response.payload != null) {
      emit(TrackingLoaded(response.payload!, parsed.serie, parsed.number));
    } else {
      emit(TrackingError(response.message ?? 'Error al rastrear'));
    }
  }

  void _onClearTracking(
    ClearTrackingEvent event,
    Emitter<TrackingState> emit,
  ) {
    emit(const TrackingInitial());
  }
}