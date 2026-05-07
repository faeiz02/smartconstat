import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Client {
  id?: number;
  email?: string;
  nom?: string;
  prenom?: string;
  cin?: string;
  phone?: string;
  role?: string;
  assuranceId?: string;
  vehicleBrand?: string;
  vehicleModel?: string;
  vehiclePlate?: string;
  compagnie?: string;
  dateExpiration?: string;
  isVerified?: boolean;
  createdAt?: string;
}

export interface Facture {
  id?: number;
  mois?: string;
  montant?: number;
  echeance?: string;
  statut?: string;
  typeFacture?: string;
  photoUrl?: string;
  userId?: number;
  userName?: string;
  userEmail?: string;
}

export interface EmergencyNumber {
  id?: number;
  label?: string;
  number?: string;
  iconStr?: string;
}

export interface AssistanceType {
  id?: number;
  title?: string;
  description?: string;
  iconStr?: string;
}

export interface HealthcareProfessional {
  id?: number;
  name?: string;
  type?: string;
  address?: string;
  distanceStr?: string;
  phone?: string;
  rating?: number;
  reviewCount?: number;
  bio?: string;
}

@Injectable({
  providedIn: 'root'
})
export class ClientService {
  private apiUrl = 'http://localhost:8082/api';

  constructor(private http: HttpClient) { }

  // ─── Users ───
  getAllClients(): Observable<Client[]> {
    return this.http.get<Client[]>(`${this.apiUrl}/users/all`);
  }

  updateUserRole(userId: number, role: string): Observable<any> {
    return this.http.put(`${this.apiUrl}/users/${userId}/role`, { role });
  }

  deleteUser(userId: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/users/${userId}`);
  }

  createUser(userData: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/users/create`, userData);
  }

  // ─── Factures (Admin) ───
  getAllFactures(): Observable<Facture[]> {
    return this.http.get<Facture[]>(`${this.apiUrl}/services/factures/all`);
  }

  adminDeleteFacture(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/services/factures/admin/${id}`);
  }

  // ─── Assistance ───
  getEmergencyNumbers(): Observable<EmergencyNumber[]> {
    return this.http.get<EmergencyNumber[]>(`${this.apiUrl}/services/assistance-numbers`);
  }

  createEmergencyNumber(data: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/services/assistance-numbers`, data);
  }

  updateEmergencyNumber(id: number, data: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/services/assistance-numbers/${id}`, data);
  }

  deleteEmergencyNumber(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/services/assistance-numbers/${id}`);
  }

  getAssistanceTypes(): Observable<AssistanceType[]> {
    return this.http.get<AssistanceType[]>(`${this.apiUrl}/services/assistance-types`);
  }

  createAssistanceType(data: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/services/assistance-types`, data);
  }

  updateAssistanceType(id: number, data: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/services/assistance-types/${id}`, data);
  }

  deleteAssistanceType(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/services/assistance-types/${id}`);
  }

  // ─── Healthcare (Réseau Soins) ───
  getHealthcareProfessionals(): Observable<HealthcareProfessional[]> {
    return this.http.get<HealthcareProfessional[]>(`${this.apiUrl}/services/healthcare`);
  }

  createHealthcareProfessional(data: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/services/healthcare`, data);
  }

  updateHealthcareProfessional(id: number, data: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/services/healthcare/${id}`, data);
  }

  deleteHealthcareProfessional(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/services/healthcare/${id}`);
  }
}
