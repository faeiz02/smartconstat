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
  private apiUrl = 'http://localhost:8082/api/constats';

  constructor(private http: HttpClient) { }

  getAllConstats(statut?: string): Observable<Constat[]> {
    let url = `${this.apiUrl}/all`;
    if (statut) {
      url += `?statut=${encodeURIComponent(statut)}`;
    }
    return this.http.get<Constat[]>(url);
  }

  updateStatut(id: number, statut: string): Observable<any> {
    return this.http.put(`${this.apiUrl}/${id}/statut`, { statut });
  }
}
