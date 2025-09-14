class Trips {
  int? deviceId;
  String? deviceName;
  double? maxSpeed;
  double? averageSpeed;
  double? distance;
  double? spentFuel;
  int? duration;
  String? startTime;
  String? startAddress;
  double? startLat;
  double? startLon;
  String? endTime;
  String? endAddress;
  double? endLat;
  double? endLon;
  int? driverUniqueId;
  String? driverName;

  Trips(
      {this.deviceId,
      this.deviceName,
      this.maxSpeed,
      this.averageSpeed,
      this.distance,
      this.spentFuel,
      this.duration,
      this.startTime,
      this.startAddress,
      this.startLat,
      this.startLon,
      this.endTime,
      this.endAddress,
      this.endLat,
      this.endLon,
      this.driverUniqueId,
      this.driverName});

  Trips.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    deviceName = json['deviceName'];
    maxSpeed = json['maxSpeed'];
    averageSpeed = json['averageSpeed'];
    distance = json['distance'];
    spentFuel = json['spentFuel'];
    duration = json['duration'];
    startTime = json['startTime'];
    startAddress = json['startAddress'];
    startLat = json['startLat'];
    startLon = json['startLon'];
    endTime = json['endTime'];
    endAddress = json['endAddress'];
    endLat = json['endLat'];
    endLon = json['endLon'];
    driverUniqueId = json['driverUniqueId'];
    driverName = json['driverName'];
  }
  int? get getdistanceTraveled {
    if (distance != null) {
      return double.tryParse((distance! / 1000).toString())?.toInt();
    } else if (distance!= null) {
      return double.tryParse((distance! / 1000).toString())?.toInt();
    }
    return 0;
  }
   double? get getSpentFuel  {
    if (spentFuel != null) {
      return spentFuel!*100;
    } 
    return 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['deviceName'] = deviceName;
    data['maxSpeed'] = maxSpeed;
    data['averageSpeed'] = averageSpeed;
    data['distance'] = distance;
    data['spentFuel'] = spentFuel;
    data['duration'] = duration;
    data['startTime'] = startTime;
    data['startAddress'] = startAddress;
    data['startLat'] = startLat;
    data['startLon'] = startLon;
    data['endTime'] = endTime;
    data['endAddress'] = endAddress;
    data['endLat'] = endLat;
    data['endLon'] = endLon;
    data['driverUniqueId'] = driverUniqueId;
    data['driverName'] = driverName;
    return data;
  }
}