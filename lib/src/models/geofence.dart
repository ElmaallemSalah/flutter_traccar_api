class Geofence {
  final int id;
  final Map<String, dynamic> attributes;
  final int calendarId;
  final String name;
  final String? description;
  final String area;

  Geofence({
    required this.id,
    required this.attributes,
    required this.calendarId,
    required this.name,
    this.description,
    required this.area,
  });

  // Factory constructor to create a Geofence instance from JSON
  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      id: json['id'],
      attributes: json['attributes'] ?? {},
      calendarId: json['calendarId'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      area: json['area'] ?? '',
    );
  }

  // Method to convert the model back to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attributes': attributes,
      'calendarId': calendarId,
      'name': name,
      'description': description,
      'area': area,
    };
  }
}
