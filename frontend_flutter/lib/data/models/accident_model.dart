class AccidentModel {
  final String id;
  final DateTime date;
  final String lieu;
  final String status;
  final String responsabilite;
  final String immatriculation;

  AccidentModel({
    required this.id,
    required this.date,
    required this.lieu,
    required this.status,
    required this.responsabilite,
    required this.immatriculation,
  });
}