class StopsReport {
  int? deviceId;
  String? deviceName;
  int? duration;
  String? startTime;
  String? address;
  double? lat;
  double? lon;
  String? endTime;
  double? spentFuel;
  int? engineHours;

 StopsReport(
      {this.deviceId,
      this.deviceName,
      this.duration,
      this.startTime,
      this.address,
      this.lat,
      this.lon,
      this.endTime,
      this.spentFuel,
      this.engineHours});

  StopsReport.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    deviceName = json['deviceName'];
    duration = json['duration'];
    startTime = json['startTime'];
    address = json['address'];
    lat = json['latitude'];
    lon = json['longitude'];
    endTime = json['endTime'];
    spentFuel = json['spentFuel'];
    engineHours = json['engineHours'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['deviceName'] = deviceName;
    data['duration'] = duration;
    data['startTime'] = startTime;
    data['address'] = address;
    data['lat'] = lat;
    data['lon'] = lon;
    data['endTime'] = endTime;
    data['spentFuel'] = spentFuel;
    data['engineHours'] = engineHours;
    return data;
  }
}