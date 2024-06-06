class Patient {
  final String id_patient;
  final String name;
  final String picture;
  final String gender;
  final String birthDate;
  final String email;
  final String phoneNumber;
  final String symptoms;
  final String consultationReport;
  final DateTime? completionTime; // Allow nullable DateTime
  final String consultationType;
  final String consultationPrice;
  final String consultationStatus;
  
  

  Patient({
    required this.id_patient,
    required this.name,
    required this.email,
    required this.picture,
    required this.phoneNumber,
    required this.gender,
    required this.birthDate,
    required this.symptoms,
    required this.consultationReport,
    required this.completionTime,
    required this.consultationType,
    required this.consultationPrice,
    required this.consultationStatus
  });

  static fromJson(item) {}
}