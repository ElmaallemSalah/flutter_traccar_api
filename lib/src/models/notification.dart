class Notification {
  final int? id;
  final String type;
  final bool always;
  final bool web;
  final bool mail;
  final bool sms;
  final Map<String, dynamic> attributes;
  final int? calendarId;
  final String? notificators;

  Notification({
    this.id,
    required this.type,
    this.always = false,
    this.web = true,
    this.mail = false,
    this.sms = false,
    this.attributes = const {},
    this.calendarId,
    this.notificators,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      type: json['type'] ?? '',
      always: json['always'] ?? false,
      web: json['web'] ?? true,
      mail: json['mail'] ?? false,
      sms: json['sms'] ?? false,
      attributes: json['attributes'] ?? {},
      calendarId: json['calendarId'],
      notificators: json['notificators'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'type': type,
      'always': always,
      'web': web,
      'mail': mail,
      'sms': sms,
      'attributes': attributes,
    };

    if (id != null) data['id'] = id;
    if (calendarId != null) data['calendarId'] = calendarId;
    if (notificators != null) data['notificators'] = notificators;

    return data;
  }

  Notification copyWith({
    int? id,
    String? type,
    bool? always,
    bool? web,
    bool? mail,
    bool? sms,
    Map<String, dynamic>? attributes,
    int? calendarId,
    String? notificators,
  }) {
    return Notification(
      id: id ?? this.id,
      type: type ?? this.type,
      always: always ?? this.always,
      web: web ?? this.web,
      mail: mail ?? this.mail,
      sms: sms ?? this.sms,
      attributes: attributes ?? this.attributes,
      calendarId: calendarId ?? this.calendarId,
      notificators: notificators ?? this.notificators,
    );
  }
}
