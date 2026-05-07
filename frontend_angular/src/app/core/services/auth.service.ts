import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, map } from 'rxjs';

export interface LoginResponse {
  success: boolean;
  message: string;
  token: string;
  user: {
    assurance_id: string;
    nom: string;
    prenom: string;
    cin: string;
    phone: string;
    email: string;
    vehicle_brand: string;
    vehicle_model: string;
    vehicle_plate: string;
    insurance_number: string;
    role: string;
    compagnie: string;
    dateExpiration: string;
  };
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = 'http://localhost:8082/api/auth';
  private tokenKey = 'admin_jwt_token';
  private userKey = 'admin_user';
  
  private _isLoggedIn = new BehaviorSubject<boolean>(this.hasToken());
  isLoggedIn$ = this._isLoggedIn.asObservable();

  constructor(private http: HttpClient) {}

  login(email: string, password: string): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(`${this.apiUrl}/login`, { email, password }).pipe(
      tap(res => {
        if (res.success && res.token) {
          localStorage.setItem(this.tokenKey, res.token);
          // Normalize user object for dashboard
          const user = {
            email: res.user?.email || email,
            nom: res.user?.nom || '',
            prenom: res.user?.prenom || '',
            role: res.user?.role || 'client',
            cin: res.user?.cin || '',
            phone: res.user?.phone || '',
          };
          localStorage.setItem(this.userKey, JSON.stringify(user));
          this._isLoggedIn.next(true);
        }
      })
    );
  }

  logout(): void {
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem(this.userKey);
    this._isLoggedIn.next(false);
  }

  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  getUser(): any {
    const u = localStorage.getItem(this.userKey);
    return u ? JSON.parse(u) : null;
  }

  getUserRole(): string {
    const user = this.getUser();
    return user?.role || 'client';
  }

  isAdmin(): boolean {
    return this.getUserRole() === 'admin';
  }

  isEmploye(): boolean {
    return this.getUserRole() === 'employe';
  }

  hasToken(): boolean {
    return !!localStorage.getItem(this.tokenKey);
  }
}
