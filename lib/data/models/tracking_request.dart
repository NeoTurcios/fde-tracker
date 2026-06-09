class TrackingRequest {
  final String path;
  final String method;
  final Map<String, dynamic> params;

  TrackingRequest({
    required this.path,
    required this.method,
    required this.params,
  });

  String get bodyData => _encodeMap({
        'Method': method,
        'Params': params,
      });

  static String _encodeMap(Map<String, dynamic> map) {
    final buffer = StringBuffer();
    buffer.write('{');
    var first = true;
    map.forEach((key, value) {
      if (!first) buffer.write(',');
      first = false;
      buffer.write('"$key":');
      buffer.write(_encodeValue(value));
    });
    buffer.write('}');
    return buffer.toString();
  }

  static String _encodeValue(dynamic value) {
    if (value is String) return '"${value.replaceAll('"', '\\"')}"';
    if (value is num || value is bool) return value.toString();
    if (value is Map) return _encodeValue(Map<String, dynamic>.from(value));
    if (value is List) {
      final items = value.map((e) => _encodeValue(e)).join(',');
      return '[$items]';
    }
    return 'null';
  }
}

class TrackingPublicParams {
  final String guideSerie;
  final String guideNumber;

  TrackingPublicParams({required this.guideSerie, required this.guideNumber});

  Map<String, dynamic> toJson() => {
        'GuideSerie': guideSerie,
        'GuideNumber': guideNumber,
      };
}

class TrackingNewDeliveryParams {
  final String guideSerie;
  final String guideNumber;
  final String nirPhone;
  final String phone;
  final String? ticketNumber;

  TrackingNewDeliveryParams({
    required this.guideSerie,
    required this.guideNumber,
    this.nirPhone = '502',
    this.phone = '',
    this.ticketNumber,
  });

  Map<String, dynamic> toJson() => {
        'GuideSerie': guideSerie,
        'GuideNumber': guideNumber,
        'NirPhone': nirPhone,
        'Phone': phone,
        if (ticketNumber != null) 'TicketNumber': ticketNumber,
      };
}