import 'package:dio/dio.dart';
import '../models/tracking_request.dart';
import '../models/tracking_response.dart';

class ForzaApiClient {
  late final Dio _dio;

  ForzaApiClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
    ));
  }

  Future<TrackingResponse> getTrackingPublic({
    required String guideSerie,
    required String guideNumber,
    String baseUrl = 'https://rastreo.forzadelivery.com/fd/Home.aspx/API',
  }) async {
    try {
      final params = TrackingPublicParams(
        guideSerie: guideSerie,
        guideNumber: guideNumber,
      );

      final request = TrackingRequest(
        path: 'Tracking/GetTrackingPublic',
        method: 'GetTrackingPublic',
        params: params.toJson(),
      );

      final response = await _dio.post(
        baseUrl,
        data: {
          'path': request.path,
          'data': request.bodyData,
        },
      );

      return TrackingResponse.fromRawResponse(response.data);
    } on DioException catch (e) {
      return TrackingResponse(
        success: false,
        message: 'Error de conexión: ${e.message}',
      );
    } catch (e) {
      return TrackingResponse(
        success: false,
        message: 'Error inesperado: $e',
      );
    }
  }

  Future<TrackingResponse> getNewDeliveryTracking({
    required String guideSerie,
    required String guideNumber,
    String phone = '',
    String nirPhone = '502',
    String? ticketNumber,
    String baseUrl = 'https://rastreo.forzadelivery.com/fd/Home.aspx/API',
  }) async {
    try {
      final params = TrackingNewDeliveryParams(
        guideSerie: guideSerie,
        guideNumber: guideNumber,
        phone: phone,
        nirPhone: nirPhone,
        ticketNumber: ticketNumber,
      );

      final request = TrackingRequest(
        path: 'Tracking/GetNewDeliveryTracking',
        method: 'GetNewDeliveryTracking',
        params: params.toJson(),
      );

      final response = await _dio.post(
        baseUrl,
        data: {
          'path': request.path,
          'data': request.bodyData,
        },
      );

      return TrackingResponse.fromRawResponse(response.data);
    } on DioException catch (e) {
      return TrackingResponse(
        success: false,
        message: 'Error de conexión: ${e.message}',
      );
    } catch (e) {
      return TrackingResponse(
        success: false,
        message: 'Error inesperado: $e',
      );
    }
  }
}