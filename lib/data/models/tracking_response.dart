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

class FlagMenus {
  final bool rescheduleDelivery;
  final bool changeAddress;
  final bool payDelivery;
  final bool notifications;
  final bool showImage;
  final bool showMap;
  final bool requestHelp;
  final bool qualify;
  final bool showVoucherDelivery;
  final bool confirmAddress;

  FlagMenus({
    this.rescheduleDelivery = false,
    this.changeAddress = false,
    this.payDelivery = false,
    this.notifications = false,
    this.showImage = false,
    this.showMap = false,
    this.requestHelp = false,
    this.qualify = false,
    this.showVoucherDelivery = false,
    this.confirmAddress = false,
  });

  factory FlagMenus.fromJson(Map<String, dynamic> json) {
    return FlagMenus(
      rescheduleDelivery: json['flagRescheduleDelivery'] as bool? ?? false,
      changeAddress: json['flagChangeAdress'] as bool? ?? false,
      payDelivery: json['flagPayDelivery'] as bool? ?? false,
      notifications: json['flagNotifications'] as bool? ?? false,
      showImage: json['flagShowImage'] as bool? ?? false,
      showMap: json['flagShowMapa'] as bool? ?? false,
      requestHelp: json['flagRequestHelp'] as bool? ?? false,
      qualify: json['flagQualify'] as bool? ?? false,
      showVoucherDelivery: json['flagShowVoucherDelivery'] as bool? ?? false,
      confirmAddress: json['flagConfirmAdress'] as bool? ?? false,
    );
  }
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
  final String pieces;
  final String description;
  final bool isNeedBilling;
  final bool isZigiPay;
  final FlagMenus flagMenus;

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
    this.pieces = '',
    this.description = '',
    this.isNeedBilling = false,
    this.isZigiPay = false,
    required this.flagMenus,
  });

  factory TrackingPayload.fromJson(Map<String, dynamic> json) {
    final ov = json['ObjectValue'] as Map<String, dynamic>? ?? json;

    List<TrackingStatus> parseStatusList(dynamic statusData) {
      if (statusData is List) {
        return statusData.map((e) => TrackingStatus.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    }

    FlagMenus parseFlagMenus(dynamic menusData) {
      if (menusData is Map<String, dynamic>) {
        return FlagMenus.fromJson(menusData);
      }
      if (menusData is List) {
        final map = <String, dynamic>{};
        for (final item in menusData) {
          if (item is String) map[item] = true;
        }
        return FlagMenus.fromJson(map);
      }
      return FlagMenus();
    }

    return TrackingPayload(
      statusList: parseStatusList(ov['statusList']),
      senderName: ov['SenderName'] as String? ?? '',
      receiverName: ov['ReceiverName'] as String? ?? '',
      poblado: ov['Poblado'] as String? ?? '',
      municipio: ov['Municipio'] as String? ?? '',
      departamento: ov['Departamento'] as String? ?? '',
      country: ov['Country'] as String? ?? '',
      statusTracking: ov['StatusTracking'] is int ? ov['StatusTracking'] as int : 0,
      statusTrackingTitle: ov['StatusTrackingTitle'] as String? ?? '',
      statusTrackingDescription: ov['StatusTrackingDescription'] as String? ?? '',
      deliveryEta: ov['DeliveryETA'] as String? ?? '',
      areaCode: ov['AreaCode'] as String? ?? '',
      pieces: ov['Pieces'] as String? ?? '',
      description: ov['Description'] as String? ?? '',
      isNeedBilling: ov['isNeedBilling'] as bool? ?? false,
      isZigiPay: ov['isZigiPay'] as bool? ?? false,
      flagMenus: parseFlagMenus(ov['flagMenus']),
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
      final rawMap = raw is Map<String, dynamic>
          ? raw
          : jsonDecode(raw as String) as Map<String, dynamic>;

      final dStr = rawMap['d'] as String?;
      if (dStr == null) return TrackingResponse(success: false, message: 'Respuesta vacia');

      final dParsed = jsonDecode(dStr) as Map<String, dynamic>;

      final dataStr = dParsed['Data'] as String?;
      if (dataStr == null) {
        final message = dParsed['Message'] as String?;
        return TrackingResponse(success: false, message: message ?? 'Error: sin datos');
      }

      final dataParsed = jsonDecode(dataStr) as Map<String, dynamic>;

      final code = dataParsed['StatusCode'];
      if (code is int && code >= 400) {
        final desc = dataParsed['Description'] as String? ?? 'Error del servidor';
        return TrackingResponse(success: false, message: desc);
      }

      final payloadStr = dataParsed['PayLoad'] as String?;
      if (payloadStr == null) {
        return TrackingResponse(success: false, message: 'No se encontro la guia');
      }

      final payloadParsed = jsonDecode(payloadStr) as Map<String, dynamic>;

      final innerCode = payloadParsed['StatusCode'];
      if (innerCode is int && innerCode >= 400) {
        final desc = payloadParsed['Description'] as String? ?? 'No encontrado';
        return TrackingResponse(success: false, message: desc);
      }

      return TrackingResponse(
        success: true,
        payload: TrackingPayload.fromJson(payloadParsed),
      );
    } catch (e) {
      return TrackingResponse(success: false, message: 'Error al procesar: $e');
    }
  }
}