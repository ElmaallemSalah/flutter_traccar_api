class Command {
  int? id;
  Attributes? attributes;
  int? deviceId;
  String? type;
  bool? textChannel;
  String? description;

  Command(
      {this.id,
      this.attributes,
      this.deviceId,
      this.type,
      this.textChannel,
      this.description});

  Command.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    deviceId = json['deviceId'];
    type = json['type'];
    textChannel = json['textChannel'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    data['deviceId'] = deviceId;
    data['type'] = type;
    data['textChannel'] = textChannel;
    data['description'] = description;
    return data;
  }
}

class Attributes {
  Map<String, dynamic> data;

  Attributes({this.data = const {}});

  Attributes.fromJson(Map<String, dynamic> json) : data = json;

  Attributes.fromMap(Map<String, dynamic> map) : data = map;

  Map<String, dynamic> toJson() {
    return data;
  }

  // Helper methods for common attributes
  String? get stringData => data['data'];
  set stringData(String? value) => data['data'] = value;

  int? get frequency => data['frequency'];
  set frequency(int? value) => data['frequency'] = value;

  String? get phone => data['phone'];
  set phone(String? value) => data['phone'] = value;

  String? get message => data['message'];
  set message(String? value) => data['message'] = value;

  bool? get enable => data['enable'];
  set enable(bool? value) => data['enable'] = value;
}