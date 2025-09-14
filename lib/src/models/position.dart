import 'package:flutter/material.dart';

class PositionList {
  List<Position>? positions;

  PositionList({this.positions});

  PositionList.fromJson(Map<String, dynamic> json) {
    if (json['positions'] != null) {
      positions = <Position>[];
      json['positions'].forEach((v) {
        positions!.add(Position.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (positions != null) {
      data['positions'] = positions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Position {
  int? id;
  Attributes? attributes;
  int? deviceId;
  String? distanceParCorue;
  String? protocol;
  String? serverTime;
  String? deviceTime;
  String? fixTime;
  bool? outdated;
  bool? valid;
  double? latitude;
  double? longitude;
  double? altitude;
  double? speed;
  double? course;
  String? address;
  double? accuracy;
  Network? network;
  List<dynamic>? geofenceIds;
  double? get getFuel {
    if (attributes?.fuel != null) {
      return double.parse(attributes!.fuel!.toStringAsFixed(2));
    } else {
      return null;
    }
  }

  int? get getFuelLevelPercentage {
    if (attributes?.fuelLevelPercentage != null) {
      return attributes!.fuelLevelPercentage;
    } else {
      return null;
    }
  }

  // ignore: non_constant_identifier_names
  double? get Getpower {
    if (attributes?.power == null) {
      return null;
    }
    return double.parse(attributes!.power!.toStringAsFixed(2));
  }

  int? get getDeviceId => deviceId;
  String? get getDistanceParCorue => distanceParCorue;
  String? get getDate => deviceTime;
  bool? get motion => attributes?.motion == true;
  bool? get ignition => attributes?.ignition == true;
  int? get obdOdometer => attributes?.obdOdometer;
  int? get odometer {
    if (attributes != null) {
      if (attributes!.obdOdometer != null) {
        return double.tryParse(
          (attributes!.obdOdometer! / 1000).toString(),
        )!.toInt();
      } else if (attributes!.odometer != null) {
        return double.tryParse(
          (attributes!.odometer! / 1000).toString(),
        )!.toInt();
      } else if (attributes!.io16 != null) {
        return double.tryParse((attributes!.io16! / 1000).toString())!.toInt();
      }
    }

    return null; // Return null if no valid odometer data
  }

  Position({
    this.id,
    this.attributes,
    this.deviceId,
    this.protocol,
    this.serverTime,
    this.deviceTime,
    this.fixTime,
    this.outdated,
    this.valid,
    this.latitude,
    this.longitude,
    this.altitude,
    this.speed,
    this.course,
    this.address,
    this.accuracy,
    this.network,
    this.geofenceIds,
    this.distanceParCorue,
  });

  Position.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    deviceId = json['deviceId'];
    protocol = json['protocol'];
    serverTime = json['serverTime'];
    deviceTime = json['deviceTime'];
    fixTime = json['fixTime'];
    outdated = json['outdated'];
    valid = json['valid'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    altitude = json['altitude'];
    speed = json['speed'];
    course = json['course'];
    distanceParCorue = json['distanceParCorue'] ?? '';

    address = json['address'] ?? '';
    accuracy = json['accuracy'];

    network = json['network'] != null
        ? Network.fromJson(json['network'])
        : null;
    geofenceIds = json['geofenceIds'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    data['deviceId'] = deviceId;

    data['protocol'] = protocol;
    data['serverTime'] = serverTime;
    data['deviceTime'] = deviceTime;
    data['fixTime'] = fixTime;
    data['outdated'] = outdated;
    data['valid'] = valid;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['altitude'] = altitude;
    data['speed'] = speed;
    data['course'] = course;
    data['address'] = address;
    data['accuracy'] = accuracy;
    data['distanceParCorue'] = distanceParCorue;
    if (network != null) {
      data['network'] = network!.toJson();
    }
    data['geofenceIds'] = geofenceIds;
    return data;
  }
}

class Attributes {
  int? priority;
  int? sat;
  String? event;
  bool? ignition;
  bool? motion;
  int? dataMode;
  int? rssi;
  int? sleepMode;
  int? io69;
  bool? in1;
  bool? out1;
  bool? in2;
  bool? in3;
  bool? out2;
  int? batteryLevel;
  int? io263;
  int? io303;
  int? io383;
  int? obdSpeed;
  int? throttle;
  bool? cngStatus;
  int? oilLevel;
  int? io652;
  int? io653;
  int? io654;
  int? io655;
  int? io656;
  int? io657;
  int? io658;
  int? io659;
  int? io660;
  int? io661;
  bool? door;
  int? io898;
  int? io899;
  int? io900;
  int? io901;
  int? io902;
  int? io903;
  int? io904;
  int? io905;
  int? io906;
  int? io907;
  int? io908;
  int? io909;
  int? io910;
  int? io911;
  int? io912;
  int? io913;
  int? io914;
  int? io915;
  int? io916;
  int? io917;
  int? io918;
  int? io919;
  int? io920;
  int? io921;
  int? io922;
  int? io923;
  int? io924;
  int? io925;
  int? io926;
  int? io927;
  int? io953;
  int? io954;
  int? io955;
  int? io956;
  int? io957;
  int? io958;
  int? io959;
  int? io960;
  int? io961;
  int? io962;
  int? io963;
  int? io964;
  int? io965;
  int? io966;
  int? io967;
  int? io968;
  int? io969;
  int? io970;
  int? io971;
  int? io972;
  int? io973;
  int? io974;
  int? io975;
  int? io976;
  int? io977;
  int? io978;
  int? io979;
  int? io980;
  int? io981;
  int? io982;
  int? io983;
  int? io984;
  int? io985;
  int? io986;
  int? io987;
  int? io988;
  int? io989;
  int? io990;
  int? io991;
  int? io992;
  int? io1083;
  int? io1084;
  int? io84;
  int? io83;
  double? pdop;
  double? hdop;
  double? power;
  double? battery;
  double? batteryCurrent;
  double? adc1;
  int? axisX;
  int? axisY;
  int? axisZ;
  int? io6;
  int? io622;
  int? io623;
  double? fuel;
  int? rpm;
  int? io90;
  double? engineTemp;
  int? operator;
  bool? in4;
  int? io5;
  int? io449;
  int? obdOdometer;
  int? odometer;
  int? io100;
  int? io107;
  int? io123;
  String? iccid;
  int? io124;
  int? io132;
  int? io517;
  int? io519;
  int? io14;
  int? io16;
  String? io387;
  double? distance;
  double? totalDistance;
  int? hours;

  int? io87;
  int? io105;
  int? fuelLevelPercentage;
  int? io940;
  int? io941;
  int? io942;
  int? io943;

  Attributes({
    this.priority,
    this.sat,
    this.event,
    this.ignition,
    this.motion,
    this.dataMode,
    this.rssi,
    this.sleepMode,
    this.io69,
    this.in1,
    this.out1,
    this.in2,
    this.in3,
    this.out2,
    this.batteryLevel,
    this.io263,
    this.io303,
    this.io383,
    this.obdSpeed,
    this.throttle,
    this.cngStatus,
    this.oilLevel,
    this.io652,
    this.io653,
    this.io654,
    this.io655,
    this.io656,
    this.io657,
    this.io658,
    this.io659,
    this.io660,
    this.io661,
    this.door,
    this.io898,
    this.io899,
    this.io900,
    this.io901,
    this.io902,
    this.io903,
    this.io904,
    this.io905,
    this.io906,
    this.io907,
    this.io908,
    this.io909,
    this.io910,
    this.io911,
    this.io912,
    this.io913,
    this.io914,
    this.io915,
    this.io916,
    this.io917,
    this.io918,
    this.io919,
    this.io920,
    this.io921,
    this.io922,
    this.io923,
    this.io924,
    this.io925,
    this.io926,
    this.io927,
    this.io953,
    this.io954,
    this.io955,
    this.io956,
    this.io957,
    this.io958,
    this.io959,
    this.io960,
    this.io961,
    this.io962,
    this.io963,
    this.io964,
    this.io965,
    this.io966,
    this.io967,
    this.io968,
    this.io969,
    this.io970,
    this.io971,
    this.io972,
    this.io973,
    this.io974,
    this.io975,
    this.io976,
    this.io977,
    this.io978,
    this.io979,
    this.io980,
    this.io981,
    this.io982,
    this.io983,
    this.io984,
    this.io985,
    this.io986,
    this.io987,
    this.io988,
    this.io989,
    this.io990,
    this.io991,
    this.io992,
    this.io1083,
    this.io1084,
    this.pdop,
    this.hdop,
    this.power,
    this.battery,
    this.batteryCurrent,
    this.adc1,
    this.axisX,
    this.axisY,
    this.axisZ,
    this.io6,
    this.io622,
    this.io623,
    this.fuel,
    this.rpm,
    this.io90,
    this.engineTemp,
    this.operator,
    this.in4,
    this.io5,
    this.io449,
    this.obdOdometer,
    this.odometer,
    this.io100,
    this.io107,
    this.io123,
    this.iccid,
    this.io124,
    this.io132,
    this.io517,
    this.io519,
    this.io14,
    this.io387,
    this.distance,
    this.totalDistance,
    this.hours,
    this.io84,
    this.io83,
    this.io16,
    this.io87,
    this.io105,
    this.fuelLevelPercentage,
    this.io940,
    this.io941,
    this.io942,
    this.io943,

  });

  Attributes.fromJson(Map<String, dynamic> json) {
    io84 = json['io83'];
    io84 = json['io84'];
    priority = json['priority'];
    sat = json['sat'];
    event = json['event'].toString();
    ignition = json['ignition'];
    motion = json['motion'];
    dataMode = json['dataMode'];
    rssi = json['rssi'];
    sleepMode = json['sleepMode'];
    io69 = json['io69'];
    in1 = json['in1'];
    out1 = json['out1'];
    in2 = json['in2'];
    in3 = json['in3'];
    out2 = json['out2'];
    batteryLevel = json['batteryLevel'];
    io263 = json['io263'];
    io303 = json['io303'];
    io383 = json['io383'];
    obdSpeed = json['obdSpeed'];
    throttle = json['throttle'];
    cngStatus = json['cngStatus'];
    oilLevel = json['oilLevel'];
    io652 = json['io652'];
    io653 = json['io653'];
    io654 = json['io654'];
    io655 = json['io655'];
    io656 = json['io656'];
    io657 = json['io657'];
    io658 = json['io658'];
    io659 = json['io659'];
    io660 = json['io660'];
    io661 = json['io661'];
    door = json['door'];
    io898 = json['io898'];
    io899 = json['io899'];
    io900 = json['io900'];
    io901 = json['io901'];
    io902 = json['io902'];
    io903 = json['io903'];
    io904 = json['io904'];
    io905 = json['io905'];
    io906 = json['io906'];
    io907 = json['io907'];
    io908 = json['io908'];
    io909 = json['io909'];
    io910 = json['io910'];
    io911 = json['io911'];
    io912 = json['io912'];
    io913 = json['io913'];
    io914 = json['io914'];
    io915 = json['io915'];
    io916 = json['io916'];
    io917 = json['io917'];
    io918 = json['io918'];
    io919 = json['io919'];
    io920 = json['io920'];
    io921 = json['io921'];
    io922 = json['io922'];
    io923 = json['io923'];
    io924 = json['io924'];
    io925 = json['io925'];
    io926 = json['io926'];
    io927 = json['io927'];
    io953 = json['io953'];
    io954 = json['io954'];
    io955 = json['io955'];
    io956 = json['io956'];
    io957 = json['io957'];
    io958 = json['io958'];
    io959 = json['io959'];
    io960 = json['io960'];
    io961 = json['io961'];
    io962 = json['io962'];
    io963 = json['io963'];
    io964 = json['io964'];
    io965 = json['io965'];
    io966 = json['io966'];
    io967 = json['io967'];
    io968 = json['io968'];
    io969 = json['io969'];
    io970 = json['io970'];
    io971 = json['io971'];
    io972 = json['io972'];
    io973 = json['io973'];
    io974 = json['io974'];
    io975 = json['io975'];
    io976 = json['io976'];
    io977 = json['io977'];
    io978 = json['io978'];
    io979 = json['io979'];
    io980 = json['io980'];
    io981 = json['io981'];
    io982 = json['io982'];
    io983 = json['io983'];
    io984 = json['io984'];
    io985 = json['io985'];
    io986 = json['io986'];
    io987 = json['io987'];
    io988 = json['io988'];
    io989 = json['io989'];
    io990 = json['io990'];
    io991 = json['io991'];
    io992 = json['io992'];
    io1083 = json['io1083'];
    io1084 = json['io1084'];
    pdop = json['pdop'];
    hdop = json['hdop'];
    power = json['power'];
    battery = json['battery'];
    batteryCurrent = json['batteryCurrent'];
    adc1 = json['adc1'];
    axisX = json['axisX'];
    axisY = json['axisY'];
    axisZ = json['axisZ'];
    io6 = json['io6'];
    io622 = json['io622'];
    io623 = json['io623'];
    fuel = json['fuel'];
    rpm = json['rpm'];
    io90 = json['io90'];
    engineTemp = json['engineTemp'];
    operator = json['operator'];
    in4 = json['in4'];
    io5 = json['io5'];
    io449 = json['io449'];
    obdOdometer = json['obdOdometer'];
    odometer = json['odometer'];
    io100 = json['io100'];
    io107 = json['io107'];
    io123 = json['io123'];
    iccid = json['iccid'];
    io124 = json['io124'];
    io132 = json['io132'];
    io517 = json['io517'];
    io519 = json['io519'];
    io14 = json['io14'];
    io387 = json['io387'];
    distance = json['distance'];
    totalDistance = json['totalDistance'];
    hours = json['hours'];
    io16 = json['io16'];
    io87 = json['io87'];
    io105 = json['io105'];
    fuelLevelPercentage = json['fuelLevelPercentage'];
    io940 = json['io940'];
    io941 = json['io941'];
    io942 = json['io942'];
    io943 = json['io943'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['priority'] = priority;
    data['sat'] = sat;
    data['event'] = event;
    data['ignition'] = ignition;
    data['motion'] = motion;
    data['dataMode'] = dataMode;
    data['rssi'] = rssi;
    data['sleepMode'] = sleepMode;
    data['io69'] = io69;
    data['in1'] = in1;
    data['out1'] = out1;
    data['in2'] = in2;
    data['in3'] = in3;
    data['out2'] = out2;
    data['batteryLevel'] = batteryLevel;
    data['io263'] = io263;
    data['io303'] = io303;
    data['io383'] = io383;
    data['obdSpeed'] = obdSpeed;
    data['throttle'] = throttle;
    data['cngStatus'] = cngStatus;
    data['oilLevel'] = oilLevel;
    data['io652'] = io652;
    data['io653'] = io653;
    data['io654'] = io654;
    data['io655'] = io655;
    data['io656'] = io656;
    data['io657'] = io657;
    data['io658'] = io658;
    data['io659'] = io659;
    data['io660'] = io660;
    data['io661'] = io661;
    data['door'] = door;
    data['io898'] = io898;
    data['io899'] = io899;
    data['io900'] = io900;
    data['io901'] = io901;
    data['io902'] = io902;
    data['io903'] = io903;
    data['io904'] = io904;
    data['io905'] = io905;
    data['io906'] = io906;
    data['io907'] = io907;
    data['io908'] = io908;
    data['io909'] = io909;
    data['io910'] = io910;
    data['io911'] = io911;
    data['io912'] = io912;
    data['io913'] = io913;
    data['io914'] = io914;
    data['io915'] = io915;
    data['io916'] = io916;
    data['io917'] = io917;
    data['io918'] = io918;
    data['io919'] = io919;
    data['io920'] = io920;
    data['io921'] = io921;
    data['io922'] = io922;
    data['io923'] = io923;
    data['io924'] = io924;
    data['io925'] = io925;
    data['io926'] = io926;
    data['io927'] = io927;
    data['io953'] = io953;
    data['io954'] = io954;
    data['io955'] = io955;
    data['io956'] = io956;
    data['io957'] = io957;
    data['io958'] = io958;
    data['io959'] = io959;
    data['io960'] = io960;
    data['io961'] = io961;
    data['io962'] = io962;
    data['io963'] = io963;
    data['io964'] = io964;
    data['io965'] = io965;
    data['io966'] = io966;
    data['io967'] = io967;
    data['io968'] = io968;
    data['io969'] = io969;
    data['io970'] = io970;
    data['io971'] = io971;
    data['io972'] = io972;
    data['io973'] = io973;
    data['io974'] = io974;
    data['io975'] = io975;
    data['io976'] = io976;
    data['io977'] = io977;
    data['io978'] = io978;
    data['io979'] = io979;
    data['io980'] = io980;
    data['io981'] = io981;
    data['io982'] = io982;
    data['io983'] = io983;
    data['io984'] = io984;
    data['io985'] = io985;
    data['io986'] = io986;
    data['io987'] = io987;
    data['io988'] = io988;
    data['io989'] = io989;
    data['io990'] = io990;
    data['io991'] = io991;
    data['io992'] = io992;
    data['io1083'] = io1083;
    data['io1084'] = io1084;
    data['pdop'] = pdop;
    data['hdop'] = hdop;
    data['power'] = power;
    data['battery'] = battery;
    data['batteryCurrent'] = batteryCurrent;
    data['adc1'] = adc1;
    data['axisX'] = axisX;
    data['axisY'] = axisY;
    data['axisZ'] = axisZ;
    data['io6'] = io6;
    data['io622'] = io622;
    data['io623'] = io623;
    data['fuel'] = fuel;
    data['rpm'] = rpm;
    data['io90'] = io90;
    data['engineTemp'] = engineTemp;
    data['operator'] = operator;
    data['in4'] = in4;
    data['io5'] = io5;
    data['io449'] = io449;
    data['obdOdometer'] = obdOdometer;
    data['odometer'] = odometer;
    data['io100'] = io100;
    data['io107'] = io107;
    data['io123'] = io123;
    data['iccid'] = iccid;
    data['io124'] = io124;
    data['io132'] = io132;
    data['io517'] = io517;
    data['io519'] = io519;
    data['io14'] = io14;
    data['io387'] = io387;
    data['distance'] = distance;
    data['totalDistance'] = totalDistance;
    data['hours'] = hours;

    return data;
  }
}

class Network {
  String? radioType;
  bool? considerIp;
  List<CellTowers>? cellTowers;

  Network({this.radioType, this.considerIp, this.cellTowers});

  Network.fromJson(Map<String, dynamic> json) {
    radioType = json['radioType'];
    considerIp = json['considerIp'];
    if (json['cellTowers'] != null) {
      cellTowers = <CellTowers>[];
      json['cellTowers'].forEach((v) {
        cellTowers!.add(CellTowers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['radioType'] = radioType;
    data['considerIp'] = considerIp;
    if (cellTowers != null) {
      data['cellTowers'] = cellTowers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CellTowers {
  int? cellId;
  int? locationAreaCode;
  int? mobileCountryCode;
  int? mobileNetworkCode;

  CellTowers({
    this.cellId,
    this.locationAreaCode,
    this.mobileCountryCode,
    this.mobileNetworkCode,
  });

  CellTowers.fromJson(Map<String, dynamic> json) {
    cellId = json['cellId'];
    locationAreaCode = json['locationAreaCode'];
    mobileCountryCode = json['mobileCountryCode'];
    mobileNetworkCode = json['mobileNetworkCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cellId'] = cellId;
    data['locationAreaCode'] = locationAreaCode;
    data['mobileCountryCode'] = mobileCountryCode;
    data['mobileNetworkCode'] = mobileNetworkCode;
    return data;
  }
}

