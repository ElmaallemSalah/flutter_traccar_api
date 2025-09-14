

class Session {
  int? id;
  Attributes? attributes;
  String? name;
  String? login;
  String? email;
  String? phone;
  bool? readonly;
  bool? administrator;
  String? map;
  double? latitude;
  double? longitude;
  int? zoom;
  String? coordinateFormat;
  bool? disabled;
  String? expirationTime;
  int? deviceLimit;
  int? userLimit;
  bool? deviceReadonly;
  bool? limitCommands;
  bool? disableReports;
  bool? fixedEmail;
  String? poiLayer;
  String? totpKey;
  bool? temporary;
  String? password;

  Session(
      {this.id,
      this.attributes,
      this.name,
      this.login,
      this.email,
      this.phone,
      this.readonly,
      this.administrator,
      this.map,
      this.latitude,
      this.longitude,
      this.zoom,
      this.coordinateFormat,
      this.disabled,
      this.expirationTime,
      this.deviceLimit,
      this.userLimit,
      this.deviceReadonly,
      this.limitCommands,
      this.disableReports,
      this.fixedEmail,
      this.poiLayer,
      this.totpKey,
      this.temporary,
      this.password});

  Session.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    name = json['name'];
    login = json['login'];
    email = json['email'];
    phone = json['phone'];
    readonly = json['readonly'];
    administrator = json['administrator'];
    map = json['map'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    zoom = json['zoom'];
    coordinateFormat = json['coordinateFormat'];
    disabled = json['disabled'];
    expirationTime = json['expirationTime'];
    deviceLimit = json['deviceLimit'];
    userLimit = json['userLimit'];
    deviceReadonly = json['deviceReadonly'];
    limitCommands = json['limitCommands'];
    disableReports = json['disableReports'];
    fixedEmail = json['fixedEmail'];
    poiLayer = json['poiLayer'];
    totpKey = json['totpKey'];
    temporary = json['temporary'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    data['name'] = name;
    data['login'] = login;
    data['email'] = email;
    data['phone'] = phone;
    data['readonly'] = readonly;
    data['administrator'] = administrator;
    data['map'] = map;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['zoom'] = zoom;
    data['coordinateFormat'] = coordinateFormat;
    data['disabled'] = disabled;
    data['expirationTime'] = expirationTime;
    data['deviceLimit'] = deviceLimit;
    data['userLimit'] = userLimit;
    data['deviceReadonly'] = deviceReadonly;
    data['limitCommands'] = limitCommands;
    data['disableReports'] = disableReports;
    data['fixedEmail'] = fixedEmail;
    data['poiLayer'] = poiLayer;
    data['totpKey'] = totpKey;
    data['temporary'] = temporary;
    data['password'] = password;
    return data;
  }
}


class Attributes {
  String? notificationTokens;

  Attributes({ this.notificationTokens});

  Attributes.fromJson(Map<String, dynamic> json) {


    // Handle optional notificationTokens
    notificationTokens = json['notificationTokens'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (notificationTokens != null) {
      data['notificationTokens'] = notificationTokens;
    }
    return data;
  }
}

