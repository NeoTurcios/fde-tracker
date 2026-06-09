import 'dart:convert';
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
      responseType: ResponseType.plain,
    ));
  }

  Future<TrackingResponse> getTrackingPublic({
    required String guideSerie,
    required String guideNumber,
    String baseUrl = 'https://rastreo.forzadelivery.com/fd/Home.aspx/API',
  }) async {
    try {
      final params = TrackingPublicParams(guideSerie: guideSerie, guideNumber: guideNumber);
      final innerData = jsonEncode({
        'Method': 'GetTrackingPublic',
        'Params': params.toJson(),
      });

      final response = await _dio.post(
        baseUrl,
        data: {
          'path': 'Tracking/GetTrackingPublic',
          'data': innerData,
        },
      );

      final rawBody = response.data as String;
      return TrackingResponse.fromRawResponse(rawBody);
    } on DioException catch (e) {
      return TrackingResponse(success: false, message: 'Error de conexion: ${e.message}');
    } catch (e) {
      return TrackingResponse(success: false, message: 'Error inesperado: $e');
    }
  }
}