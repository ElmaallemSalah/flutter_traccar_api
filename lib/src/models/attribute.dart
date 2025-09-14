/// Attribute model for Traccar API
/// Based on official Traccar API specification
class Attribute {
  final int? id;
  final String description;
  final String attribute;
  final String expression;
  final String type;

  const Attribute({
    this.id,
    required this.description,
    required this.attribute,
    required this.expression,
    required this.type,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      id: json['id'] as int?,
      description: json['description'] as String? ?? '',
      attribute: json['attribute'] as String? ?? '',
      expression: json['expression'] as String? ?? '',
      type: json['type'] as String? ?? 'String',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'description': description,
      'attribute': attribute,
      'expression': expression,
      'type': type,
    };

    if (id != null) data['id'] = id;

    return data;
  }

  /// Creates a String type attribute
  factory Attribute.string({
    int? id,
    required String description,
    required String attribute,
    required String expression,
  }) {
    return Attribute(
      id: id,
      description: description,
      attribute: attribute,
      expression: expression,
      type: 'String',
    );
  }

  /// Creates a Number type attribute
  factory Attribute.number({
    int? id,
    required String description,
    required String attribute,
    required String expression,
  }) {
    return Attribute(
      id: id,
      description: description,
      attribute: attribute,
      expression: expression,
      type: 'Number',
    );
  }

  /// Creates a Boolean type attribute
  factory Attribute.boolean({
    int? id,
    required String description,
    required String attribute,
    required String expression,
  }) {
    return Attribute(
      id: id,
      description: description,
      attribute: attribute,
      expression: expression,
      type: 'Boolean',
    );
  }

  /// Check if the attribute is a String type
  bool get isString => type == 'String';

  /// Check if the attribute is a Number type
  bool get isNumber => type == 'Number';

  /// Check if the attribute is a Boolean type
  bool get isBoolean => type == 'Boolean';

  Attribute copyWith({
    int? id,
    String? description,
    String? attribute,
    String? expression,
    String? type,
  }) {
    return Attribute(
      id: id ?? this.id,
      description: description ?? this.description,
      attribute: attribute ?? this.attribute,
      expression: expression ?? this.expression,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'Attribute(id: $id, description: $description, attribute: $attribute, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attribute && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}