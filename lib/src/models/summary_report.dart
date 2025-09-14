

class ReportSummary {
  int? deviceId;
  String? deviceName;
  double? distance;
  double? averageSpeed;
  double? maxSpeed;
  double? spentFuel;
  double? startOdometer;
  double? endOdometer;
  String? startTime;
  String? endTime;
  int? startHours;
  int? endHours;
  int? engineHours;
  int? speedNow;
  String? addressNow;
  String? dateRefresh;
  String? status;


// set address now
  set setAddressNow(String? address) {
    addressNow = address;
  }
 int? get odometer {
    if (endOdometer != null) {
      return double.tryParse((endOdometer! / 1000).toString())!
          .toInt();
    } else if (endOdometer!= null) {
      return double.tryParse((endOdometer! / 1000).toString())!
          .toInt();
    }
    return 0;
  }
   int? get startOdometerValue {
    if (startOdometer != null) {
      return double.tryParse((startOdometer! / 1000).toString())!
          .toInt();
    } else if (startOdometer!= null) {
      return double.tryParse((startOdometer! / 1000).toString())!
          .toInt();
    }
    return 0;
  }
int? get distanceTraveled {
    if (distance != null) {
      return double.tryParse((distance! / 1000).toString())!
          .toInt();
    } else if (distance!= null) {
      return double.tryParse((distance! / 1000).toString())!
          .toInt();
    }
    return 0;
  }

int? get maxSpeedValue {
 
    if (maxSpeed != null) {
      return double.tryParse((maxSpeed!*1.852 ).toString())!
          .toInt();
    } else if (maxSpeed!= null) {
      return double.tryParse((maxSpeed!*1.852 ).toString())!
          .toInt();
    }
    return 0;
  }
 String getDrivingTime() {
  int milliseconds =engineHours!;
  int seconds = milliseconds ~/ 1000;
  int minutes = seconds ~/ 60;
  int hours = minutes ~/ 60;

  seconds = seconds % 60; // Remaining seconds
  minutes = minutes % 60; // Remaining minutes

  return '${hours.toString().padLeft(2, '0')}h '
         '${minutes.toString().padLeft(2, '0')}m '
         '${seconds.toString().padLeft(2, '0')}s';
}



  ReportSummary(
      {this.deviceId,
      this.deviceName,
      this.distance,
      this.averageSpeed,
      this.maxSpeed,
      this.spentFuel,
      this.startOdometer,
      this.endOdometer,
      this.startTime,
      this.endTime,
      this.startHours,
      this.endHours,
      this.engineHours,
      this.status
      
      });

  ReportSummary.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    deviceName = json['deviceName'];
    distance = json['distance'];
    averageSpeed = json['averageSpeed'];
    maxSpeed = json['maxSpeed'];

    //BuildTextCell('${(repport.spentFuel ?? 0).toStringAsFixed(2)}', flex: 2),

    spentFuel = (json['spentFuel']??0);
    startOdometer = json['startOdometer'];
    endOdometer = json['endOdometer']  ;
    startTime = json['startTime'];
    endTime = json['endTime'];
    startHours = json['startHours'];
    endHours = json['endHours'];
    engineHours = json['engineHours'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['deviceName'] = deviceName;
    data['distance'] = distance;
    data['averageSpeed'] = averageSpeed;
    data['maxSpeed'] = maxSpeed;
    data['spentFuel'] = spentFuel;
    data['startOdometer'] = startOdometer;
    data['endOdometer'] = endOdometer;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['startHours'] = startHours;
    data['endHours'] = endHours;
    data['engineHours'] = engineHours;
    return data;
  }
}