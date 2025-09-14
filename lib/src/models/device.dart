


import 'package:flutter_traccar_api/src/utils/datetime_helper.dart';

class Device {
    Device({
         this.id,
         this.attributes,
         this.groupId,
         this.calendarId,
         this.name,
         this.uniqueId,
         this.status,
         this.lastUpdate,
         this.positionId,
         this.phone,
         this.model,
         this.contact,
         this.category,
         this.disabled,
         this.expirationTime,
         this.km,
    });

    final int? id;
    final Attributes? attributes;
    final int? groupId;
    final int? calendarId;
    final String? name;
    final String? uniqueId;
    final String? status;
    final DateTime? lastUpdate;
    final int? positionId;
    final dynamic phone;
    final String? model;
    final dynamic contact;
    final String? category;
    final bool? disabled;
    final dynamic expirationTime;
         String? km;
 

    

    factory Device.fromJson(Map<String, dynamic> json){ 
        return Device(
            id: json["id"],
            attributes: json["attributes"] == null ? null : Attributes.fromJson(json["attributes"]),
            groupId: json["groupId"],
            calendarId: json["calendarId"],
            name: json["name"],
            uniqueId: json["uniqueId"],
            status: json["status"],
            lastUpdate: DateTimeHelper.fromJsonString(json["lastUpdate"]),
            positionId: json["positionId"],
            phone: json["phone"],
            model: json["model"],
            contact: json["contact"],
            category: json["category"],
            disabled: json["disabled"],
            expirationTime: json["expirationTime"],
            km: json["km"]?.toString(),
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "attributes": attributes?.toJson(),
        "groupId": groupId,
        "calendarId": calendarId,
        "name": name,
        "uniqueId": uniqueId,
        "status": status,
        "lastUpdate": DateTimeHelper.toJsonString(lastUpdate),
        "positionId": positionId,
        "phone": phone,
        "model": model,
        "contact": contact,
        "category": category,
        "disabled": disabled,
        "expirationTime": expirationTime,
        "km": km,
    };

}

class Position {
}

class Attributes {
  Attributes({required this.json});

  final Map<String, dynamic> json;

  // Factory constructor to create an instance from a JSON map.
  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes(json: json);
  }

  // Method to convert an instance back to JSON.
  Map<String, dynamic> toJson() {
    return json; // Returns the entire map, including the speedLimit field.
  }

  // Getter and setter for speedLimit.
  double? get speedLimit => json['speedLimit'];










  set speedLimit(double? value) {
    if (value != null) {
      json['speedLimit'] = value;
    } else {
      json.remove('speedLimit'); // Remove if value is null.
    }
  }

}


