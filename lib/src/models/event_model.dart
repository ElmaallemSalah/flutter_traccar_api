class EventModel {
  int? id;
  Attributes? attributes;
  int? deviceId;
  String? type;
  String? eventTime;
  int? positionId;
  int? geofenceId;
  int? maintenanceId;

  EventModel(
      {this.id,
      this.attributes,
      this.deviceId,
      this.type,
      this.eventTime,
      this.positionId,
      this.geofenceId,
      this.maintenanceId});

  EventModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    deviceId = json['deviceId'];
    type = json['type'];
    eventTime = json['eventTime'];
    positionId = json['positionId'];
    geofenceId = json['geofenceId'];
    maintenanceId = json['maintenanceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    data['deviceId'] = deviceId;
    data['type'] = type;
    data['eventTime'] = eventTime;
    data['positionId'] = positionId;
    data['geofenceId'] = geofenceId;
    data['maintenanceId'] = maintenanceId;
    return data;
  }
}

class Attributes {
  String? result;
  double? speed;
  double? speedLimit;
  String? alarm;

  Attributes({this.result,this.speed,this.speedLimit});

  Attributes.fromJson(Map<String, dynamic> json) {
    result = json['result'];
     speed = json['speed'];
      speedLimit = json['speedLimit'];
      alarm = json['alarm'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['result'] = result;
     data['speed'] = speed;
      data['speedLimit'] = speedLimit;
      data['alarm'] = alarm;
    return data;
  }
}

class AlertTypeCount {
  String? type;
  String? title;
  String? disc;
  String? time;
  int? count;
  String? icon;
  String? date;

  AlertTypeCount({this.type, this.title, this.disc, this.time, this.count,this.icon,this.date});
}
