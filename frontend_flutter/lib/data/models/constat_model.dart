class ConstatModel {
  // Informations générales
  final String? accidentId;
  final DateTime? dateTime;
  final String? lieu;

  // Véhicule A
  final String? assureurA;
  final String? contratA;
  final String? nomA;
  final String? prenomA;
  final String? adresseA;
  final String? vehiculeMarqueA;
  final String? vehiculeModeleA;
  final String? immatriculationA;
  final String? paysA;
  final String? sensSuiviA;

  // Véhicule B
  final String? assureurB;
  final String? contratB;
  final String? nomB;
  final String? prenomB;
  final String? adresseB;
  final String? vehiculeMarqueB;
  final String? vehiculeModeleB;
  final String? immatriculationB;
  final String? paysB;
  final String? sensSuiviB;

  // Dégâts
  final String? pointChocInitial;
  final String? degatsApparentsA;
  final String? degatsApparentsB;
  final String? autresDegats;

  // Observations
  final List<String>? circonstances;
  final String? observations;

  final String? temoins;
  final bool? blesses;
  final bool? degatsMaterielsAutres;
  final bool? interventionPolice;

  // Statut et info utilisateur (dashboard)
  final String? statut;
  final String? userName;
  final String? userEmail;
  final String? factureStatut;
  final double? montantFacturesTotal;
  final int? nombreFactures;
  final String? priseEnChargeDecision;

  ConstatModel({
    this.accidentId,
    this.dateTime,
    this.lieu,
    this.assureurA,
    this.contratA,
    this.nomA,
    this.prenomA,
    this.adresseA,
    this.vehiculeMarqueA,
    this.vehiculeModeleA,
    this.immatriculationA,
    this.paysA,
    this.sensSuiviA,
    this.assureurB,
    this.contratB,
    this.nomB,
    this.prenomB,
    this.adresseB,
    this.vehiculeMarqueB,
    this.vehiculeModeleB,
    this.immatriculationB,
    this.paysB,
    this.sensSuiviB,
    this.pointChocInitial,
    this.degatsApparentsA,
    this.degatsApparentsB,
    this.autresDegats,
    this.circonstances,
    this.observations,
    this.temoins,
    this.blesses,
    this.degatsMaterielsAutres,
    this.interventionPolice,
    this.statut,
    this.userName,
    this.userEmail,
    this.factureStatut,
    this.montantFacturesTotal,
    this.nombreFactures,
    this.priseEnChargeDecision,
  });

  factory ConstatModel.fromJson(Map<String, dynamic> json) {
    return ConstatModel(
      accidentId: json['accidentId'],
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
      lieu: json['lieu'],
      assureurA: json['assureurA'],
      contratA: json['contratA'],
      nomA: json['nomA'],
      prenomA: json['prenomA'],
      adresseA: json['adresseA'],
      vehiculeMarqueA: json['vehiculeMarqueA'],
      vehiculeModeleA: json['vehiculeModeleA'],
      immatriculationA: json['immatriculationA'],
      paysA: json['paysA'],
      sensSuiviA: json['sensSuiviA'],
      assureurB: json['assureurB'],
      contratB: json['contratB'],
      nomB: json['nomB'],
      prenomB: json['prenomB'],
      adresseB: json['adresseB'],
      vehiculeMarqueB: json['vehiculeMarqueB'],
      vehiculeModeleB: json['vehiculeModeleB'],
      immatriculationB: json['immatriculationB'],
      paysB: json['paysB'],
      sensSuiviB: json['sensSuiviB'],
      pointChocInitial: json['pointChocInitial'],
      degatsApparentsA: json['degatsApparentsA'],
      degatsApparentsB: json['degatsApparentsB'],
      autresDegats: json['autresDegats'],
      circonstances: json['circonstances'] != null ? List<String>.from(json['circonstances']) : null,
      observations: json['observations'],
      temoins: json['temoins'],
      blesses: json['blesses'],
      degatsMaterielsAutres: json['degatsMaterielsAutres'],
      interventionPolice: json['interventionPolice'],
      statut: json['statut'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      factureStatut: json['factureStatut'],
      montantFacturesTotal: json['montantFacturesTotal'] != null ? (json['montantFacturesTotal'] as num).toDouble() : null,
      nombreFactures: json['nombreFactures'],
      priseEnChargeDecision: json['priseEnChargeDecision'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accidentId': accidentId,
      'dateTime': dateTime?.toIso8601String(),
      'lieu': lieu,
      'assureurA': assureurA,
      'contratA': contratA,
      'nomA': nomA,
      'prenomA': prenomA,
      'adresseA': adresseA,
      'vehiculeMarqueA': vehiculeMarqueA,
      'vehiculeModeleA': vehiculeModeleA,
      'immatriculationA': immatriculationA,
      'paysA': paysA,
      'sensSuiviA': sensSuiviA,
      'assureurB': assureurB,
      'contratB': contratB,
      'nomB': nomB,
      'prenomB': prenomB,
      'adresseB': adresseB,
      'vehiculeMarqueB': vehiculeMarqueB,
      'vehiculeModeleB': vehiculeModeleB,
      'immatriculationB': immatriculationB,
      'paysB': paysB,
      'sensSuiviB': sensSuiviB,
      'pointChocInitial': pointChocInitial,
      'degatsApparentsA': degatsApparentsA,
      'degatsApparentsB': degatsApparentsB,
      'autresDegats': autresDegats,
      'circonstances': circonstances,
      'observations': observations,
      'temoins': temoins,
      'blesses': blesses,
      'degatsMaterielsAutres': degatsMaterielsAutres,
      'interventionPolice': interventionPolice,
      'statut': statut,
      'userName': userName,
      'userEmail': userEmail,
      'factureStatut': factureStatut,
      'montantFacturesTotal': montantFacturesTotal,
      'nombreFactures': nombreFactures,
      'priseEnChargeDecision': priseEnChargeDecision,
    };
  }
}
