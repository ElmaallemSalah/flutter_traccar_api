/// Driver model for Traccar API
class Driver {
  final int? id;
  final String name;
  final String? uniqueId;
  final Map<String, dynamic> attributes;

  Driver({
    this.id,
    required this.name,
    this.uniqueId,
    this.attributes = const {},
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'] ?? '',
      uniqueId: json['uniqueId'],
      attributes: json['attributes'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'attributes': attributes,
    };

    if (id != null) data['id'] = id;
    if (uniqueId != null) data['uniqueId'] = uniqueId;

    return data;
  }

  Driver copyWith({
    int? id,
    String? name,
    String? uniqueId,
    Map<String, dynamic>? attributes,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      uniqueId: uniqueId ?? this.uniqueId,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Driver &&
        other.id == id &&
        other.name == name &&
        other.uniqueId == uniqueId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ uniqueId.hashCode;
  }

  @override
  String toString() {
    return 'Driver{id: $id, name: $name, uniqueId: $uniqueId}';
  }

  // Helper getters for common attributes
  String? get phone => attributes['phone'];
  String? get email => attributes['email'];
  String? get licenseNumber => attributes['licenseNumber'];
  String? get licenseExpiry => attributes['licenseExpiry'];
  String? get category => attributes['category'];
  String? get notes => attributes['notes'];

  // Helper setters for common attributes
  Driver withPhone(String? phone) {
    final newAttributes = Map<String, dynamic>.from(attributes);
    if (phone != null) {
      newAttributes['phone'] = phone;
    } else {
      newAttributes.remove('phone');
    }
    return copyWith(attributes: newAttributes);
  }

  Driver withEmail(String? email) {
    final newAttributes = Map<String, dynamic>.from(attributes);
    if (email != null) {
      newAttributes['email'] = email;
    } else {
      newAttributes.remove('email');
    }
    return copyWith(attributes: newAttributes);
  }

  Driver withLicenseNumber(String? licenseNumber) {
    final newAttributes = Map<String, dynamic>.from(attributes);
    if (licenseNumber != null) {
      newAttributes['licenseNumber'] = licenseNumber;
    } else {
      newAttributes.remove('licenseNumber');
    }
    return copyWith(attributes: newAttributes);
  }

  Driver withLicenseExpiry(String? licenseExpiry) {
    final newAttributes = Map<String, dynamic>.from(attributes);
    if (licenseExpiry != null) {
      newAttributes['licenseExpiry'] = licenseExpiry;
    } else {
      newAttributes.remove('licenseExpiry');
    }
    return copyWith(attributes: newAttributes);
  }

  Driver withCategory(String? category) {
    final newAttributes = Map<String, dynamic>.from(attributes);
    if (category != null) {
      newAttributes['category'] = category;
    } else {
      newAttributes.remove('category');
    }
    return copyWith(attributes: newAttributes);
  }

  Driver withNotes(String? notes) {
    final newAttributes = Map<String, dynamic>.from(attributes);
    if (notes != null) {
      newAttributes['notes'] = notes;
    } else {
      newAttributes.remove('notes');
    }
    return copyWith(attributes: newAttributes);
  }
}