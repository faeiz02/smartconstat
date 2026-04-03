class UserModel {
  final String assuranceId;
  final String nom;
  final String prenom;
  final String cin;
  final String phone;
  final String email;
  final String vehicleBrand;
  final String vehicleModel;
  final String vehiclePlate;
  final String insuranceNumber;

  UserModel({
    required this.assuranceId,
    required this.nom,
    required this.prenom,
    required this.cin,
    required this.phone,
    required this.email,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.insuranceNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      assuranceId: json['assurance_id'] ?? json['assuranceId'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      cin: json['cin'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? json['emailAuth'] ?? '',
      vehicleBrand: json['vehicle_brand'] ?? json['vehicleBrand'] ?? '',
      vehicleModel: json['vehicle_model'] ?? json['vehicleModel'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? json['vehiclePlate'] ?? '',
      insuranceNumber: json['insurance_number'] ?? json['insuranceNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assurance_id': assuranceId,
      'nom': nom,
      'prenom': prenom,
      'cin': cin,
      'phone': phone,
      'email': email,
      'vehicle_brand': vehicleBrand,
      'vehicle_model': vehicleModel,
      'vehicle_plate': vehiclePlate,
      'insurance_number': insuranceNumber,
    };
  }
}