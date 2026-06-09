import 'dart:convert';

class TrackingStatus {
  final String label;
  final String icon;
  final String description;
  final String dateCreate;

  TrackingStatus({
    required this.label,
    required this.icon,
    required this.description,
    required this.dateCreate,
  });

  factory TrackingStatus.fromJson(Map<String, dynamic> json) {
    return TrackingStatus(
      label: json['label'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      description: json['Description'] as String? ?? '',
      dateCreate: json['DateCreate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'icon': icon,
        'Description': description,
        'DateCreate': dateCreate,
      };
}

class TrackingPayload {
  final List<TrackingStatus> statusList;
  final String senderName;
  final String receiverName;
  final String poblado;
  final String municipio;
  final String departamento;
  final String country;
  final int statusTracking;
  final String statusTrackingTitle;
  final String statusTrackingDescription;
  final String deliveryEta;
  final String areaCode;
  final List<String> flagMenus;

  TrackingPayload({
    required this.statusList,
    required this.senderName,
    required this.receiverName,
    required this.poblado,
    required this.municipio,
    required this.departamento,
    required this.country,
    required this.statusTracking,
    required this.statusTrackingTitle,
    required this.statusTrackingDescription,
    required this.deliveryEta,
    required this.areaCode,
    required this.flagMenus,
  });

  factory TrackingPayload.fromJson(Map<String, dynamic> json) {
    final ov = json['ObjectValue'] as Map<String, dynamic>? ?? json;
    return TrackingPayload(
      statusList: (ov['statusList'] as List<dynamic>?)
              ?.map((e) => TrackingStatus.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      senderName: ov['SenderName'] as String? ?? '',
      receiverName: ov['ReceiverName'] as String? ?? '',
      poblado: ov['Poblado'] as String? ?? '',
      municipio: ov['Municipio'] as String? ?? '',
      departamento: ov['Departamento'] as String? ?? '',
      country: ov['Country'] as String? ?? '',
      statusTracking: ov['StatusTracking'] as int? ?? 0,
      statusTrackingTitle: ov['StatusTrackingTitle'] as String? ?? '',
      statusTrackingDescription: ov['StatusTrackingDescription'] as String? ?? '',
      deliveryEta: ov['DeliveryETA'] as String? ?? '',
      areaCode: ov['AreaCode'] as String? ?? '',
      flagMenus: (ov['flagMenus'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'ObjectValue': {
          'statusList': statusList.map((e) => e.toJson()).toList(),
          'SenderName': senderName,
          'ReceiverName': receiverName,
          'Poblado': poblado,
          'Municipio': municipio,
          'Departamento': departamento,
          'Country': country,
          'StatusTracking': statusTracking,
          'StatusTrackingTitle': statusTrackingTitle,
          'StatusTrackingDescription': statusTrackingDescription,
          'DeliveryETA': deliveryEta,
          'AreaCode': areaCode,
          'flagMenus': flagMenus,
        }
      };

  String get address {
    return [poblado, municipio, departamento, country]
        .where((s) => s.isNotEmpty)
        .join(', ');
  }
}

class TrackingResponse {
  final bool success;
  final String? message;
  final TrackingPayload? payload;

  TrackingResponse({required this.success, this.message, this.payload});

  factory TrackingResponse.fromRawResponse(dynamic raw) {
    try {
      final rawMap = raw is Map<String, dynamic> ? raw : jsonDecode(raw as String) as Map<String, dynamic>;
      final dStr = rawMap['d'] as String?;
      if (dStr == null) return TrackingResponse(success: false, message: 'Respuesta vacía');

      final dParsed = jsonDecode(dStr) as Map<String, dynamic>;
      final dataStr = dParsed['Data'] as String?;
      if (dataStr == null) return TrackingResponse(success: false, message: 'Error: sin datos');

      final dataParsed = jsonDecode(dataStr) as Map<String, dynamic>;
      final payloadStr = dataParsed['PayLoad'] as String?;
      if (payloadStr == null) return TrackingResponse(success: false, message: 'Error: sin payload');

      final payloadParsed = jsonDecode(payloadStr) as Map<String, dynamic>;
      return TrackingResponse(
        success: true,
        payload: TrackingPayload.fromJson(payloadParsed),
      );
    } catch (e) {
      return TrackingResponse(success: false, message: 'Error al procesar: $e');
    }
  }
}