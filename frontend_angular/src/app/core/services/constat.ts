import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Constat {
  id?: number;
  accidentId?: string;
  dateTime?: string;
  lieu?: string;
  statut?: string;
  userName?: string;
  userEmail?: string;
  traiteParNom?: string;
  traiteParId?: number;
  priorite?: string;
  dateLimite?: string;
  noteInterne?: string;
  documentsManquants?: string;
  motifRejet?: string;
  commentaireDecision?: string;
  responsabiliteEstimee?: string;
  montantEstime?: number;
  factureStatut?: string;
  montantFacturesTotal?: number;
  nombreFactures?: number;
  priseEnChargeDecision?: string;
  factures?: Array<{
    id?: number;
    mois?: string;
    montant?: number;
    echeance?: string;
    statut?: string;
    typeFacture?: string;
    photoUrl?: string;
    decisionStatut?: string;
    decisionCommentaire?: string;
    decisionAt?: string;
  }>;
  escalade?: boolean;
  escaladeRaison?: string;
  updatedAt?: string;
  
  // Véhicule A
  nomA?: string;
  prenomA?: string;
  assureurA?: string;
  contratA?: string;
  immatriculationA?: string;
  vehiculeMarqueA?: string;
  vehiculeModeleA?: string;
  adresseA?: string;
  degatsApparentsA?: string;
  
  // Véhicule B
  nomB?: string;
  prenomB?: string;
  assureurB?: string;
  contratB?: string;
  immatriculationB?: string;
  vehiculeMarqueB?: string;
  vehiculeModeleB?: string;
  adresseB?: string;
  degatsApparentsB?: string;
  
  // Détails
  circonstances?: string[];
  observations?: string;
  temoins?: string;
  pointChocInitial?: string;
  autresDegats?: string;
  blesses?: boolean;
  interventionPolice?: boolean;
  
  // Fichiers uploadés
  croquisPath?: string;
  signatureAPath?: string;
  signatureBPath?: string;
  photosPaths?: string;
}

@Injectable({
  providedIn: 'root'
})
export class ConstatService {
  // Using the local IP since this is a mobile environment test backend
  private apiUrl = 'http://192.168.1.189:8082/api/constats';

  constructor(private http: HttpClient) { }

  getAllConstats(statut?: string): Observable<Constat[]> {
    let url = `${this.apiUrl}/all`;
    if (statut) {
      url += `?statut=${encodeURIComponent(statut)}`;
    }
    return this.http.get<Constat[]>(url);
  }

  updateStatut(id: number, statut: string, comment?: string): Observable<any> {
    return this.http.put(`${this.apiUrl}/${id}/statut`, { statut, comment });
  }

  assignConstat(id: number, employeId: number, comment?: string): Observable<any> {
    return this.http.put(`${this.apiUrl}/${id}/assign`, { employeId, comment });
  }

  updateTracking(id: number, payload: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/${id}/tracking`, payload);
  }

  getHistory(id: number): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/${id}/history`);
  }

  getAdminNotifications(): Observable<any> {
    return this.http.get(`${this.apiUrl}/admin/notifications`);
  }

  getEmployeePerformance(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/admin/performance`);
  }
}
