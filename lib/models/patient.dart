class Patient {
  final String id_patient;
  final String name;
  final String picture;
  final String gender;
  final DateTime birthDate;
  final String email;
  final String password;
  final String phoneNumber;
  

  Patient({
    required this.id_patient,
    required this.name,
    required this.email,
    required this.picture,
    required this.password,
    required this.phoneNumber,
    required this.gender,
    required this.birthDate
  });

  static fromJson(item) {}
}