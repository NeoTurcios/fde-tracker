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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'GuideSerie': guideSerie,
      'GuideNumber': guideNumber,
      'NirPhone': nirPhone,
      'Phone': phone,
    };
    if (ticketNumber != null) map['TicketNumber'] = ticketNumber;
    return map;
  }
}
