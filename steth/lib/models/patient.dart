class Patient {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String? weight;
  final String? height;
  final List<String> healthConditions;
  final String createdAt;

  const Patient({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.weight,
    this.height,
    required this.healthConditions,
    required this.createdAt,
  });

  // Factory constructor to create Patient from JSON
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      gender: json['gender'] as String,
      weight: json['weight'] as String?,
      height: json['height'] as String?,
      healthConditions: List<String>.from(json['healthConditions'] ?? []),
      createdAt: json['createdAt'] as String,
    );
  }

  // Method to convert Patient to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'weight': weight,
      'height': height,
      'healthConditions': healthConditions,
      'createdAt': createdAt,
    };
  }

  // Getter for full name
  String get fullName {
    String name = firstName;
    if (middleName.isNotEmpty) {
      name += ' $middleName';
    }
    name += ' $lastName';
    return name;
  }

  // Method to create a copy with updated values
  Patient copyWith({
    String? id,
    String? firstName,
    String? middleName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    String? weight,
    String? height,
    List<String>? healthConditions,
    String? createdAt,
  }) {
    return Patient(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      healthConditions: healthConditions ?? this.healthConditions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Patient(id: $id, fullName: $fullName, gender: $gender, dateOfBirth: $dateOfBirth)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
