import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { ThemeService } from '../../services/theme.service';
import { ConstatService, Constat } from '../../services/constat';
import { ClientService } from '../../services/client.service';

@Component({
  selector: 'app-admin-layout',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './admin-layout.html',
  styleUrls: ['./admin-layout.css']
})
export class AdminLayoutComponent implements OnInit {
  userName = '';
  userRole = 'admin';

  // Badge counters
  pendingConstats = 0;
  totalClients = 0;
  totalEmployees = 0;

  constructor(
    private authService: AuthService,
    private router: Router,
    public themeService: ThemeService,
    private constatService: ConstatService,
    private clientService: ClientService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    if (!this.authService.hasToken()) {
      this.router.navigate(['/login']);
      return;
    }
    const user = this.authService.getUser();
    this.userName = user ? `${user.nom || ''} ${user.prenom || ''}`.trim() : 'Utilisateur';
    this.userRole = this.authService.getUserRole();
    this.loadBadgeCounts();
  }

  loadBadgeCounts(): void {
    this.constatService.getAllConstats().subscribe({
      next: (data: any[]) => {
        this.pendingConstats = data.filter((c: any) => c.statut === 'Non examiné').length;
        this.cdr.markForCheck();
      },
      error: () => {}
    });
    if (this.isAdmin()) {
      this.clientService.getAllClients().subscribe({
        next: (data: any[]) => {
          this.totalClients = data.filter((c: any) => (c.role || 'client') === 'client').length;
          this.totalEmployees = data.filter((c: any) => c.role === 'employe' || c.role === 'admin').length;
          this.cdr.markForCheck();
        },
        error: () => {}
      });
    }
  }

  isAdmin(): boolean {
    return this.userRole === 'admin';
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  getRoleLabel(): string {
    switch (this.userRole) {
      case 'admin': return 'Administrateur';
      case 'employe': return 'Employé';
      default: return 'Utilisateur';
    }
  }

  getInitials(): string {
    const parts = this.userName.split(' ');
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return this.userName.substring(0, 2).toUpperCase();
  }
}
