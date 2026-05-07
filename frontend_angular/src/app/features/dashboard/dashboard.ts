import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { ConstatService, Constat } from '../../core/services/constat';
import { AuthService } from '../../core/services/auth.service';
import { ThemeService } from '../../core/services/theme.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './dashboard.html',
  styleUrls: ['./dashboard.css']
})
export class DashboardComponent implements OnInit {
  constats: Constat[] = [];
  filteredConstats: Constat[] = [];
  isLoading = true;
  activeTab: string | null = null;
  userName = '';
  userRole = '';

  tabs = [
    { label: 'Tous', statut: null, icon: 'list_alt' },
    { label: 'Non examinés', statut: 'Non examiné', icon: 'pending' },
    { label: 'En cours', statut: "En cours d'exécution", icon: 'hourglass_top' },
    { label: 'Traités', statut: 'Traité', icon: 'check_circle' },
    { label: 'Rejetés', statut: 'Rejeté', icon: 'cancel' }
  ];

  constructor(
    private constatService: ConstatService,
    private authService: AuthService,
    private router: Router,
    public themeService: ThemeService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    if (!this.authService.hasToken()) {
      this.router.navigate(['/login']);
      return;
    }
    const user = this.authService.getUser();
    this.userName = user ? `${user.nom || ''} ${user.prenom || ''}`.trim() : 'Admin';
    this.userRole = this.authService.getUserRole();
    this.loadConstats();
  }

  isAdmin(): boolean {
    return this.userRole === 'admin';
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  loadConstats(): void {
    this.isLoading = true;
    this.constatService.getAllConstats().subscribe({
      next: (data: any) => {
        this.constats = data;
        this.filterConstats(this.activeTab);
        this.isLoading = false;
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        console.error('Error loading constats', err);
        if (err.status === 401 || err.status === 403) {
          this.authService.logout();
          this.router.navigate(['/login']);
        }
        this.isLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  filterConstats(statut: string | null): void {
    this.activeTab = statut;
    if (!statut) {
      this.filteredConstats = [...this.constats];
    } else {
      this.filteredConstats = this.constats.filter(c => c.statut === statut);
    }
  }

  countByStatut(statut: string): number {
    return this.constats.filter(c => c.statut === statut).length;
  }

  getMyAssignedCount(): number {
    const user = this.authService.getUser();
    return this.constats.filter(c => c.statut === "En cours d'exécution").length;
  }

  getMyTreatedCount(): number {
    return this.constats.filter(c => c.statut === 'Traité').length;
  }

  getStatutClass(statut?: string): string {
    switch (statut) {
      case 'Non examiné': return 'status-warning';
      case "En cours d'exécution": return 'status-info';
      case 'Traité': return 'status-success';
      case 'Rejeté': return 'status-danger';
      default: return 'status-default';
    }
  }

  getStatutIcon(statut?: string): string {
    switch (statut) {
      case 'Non examiné': return 'pending_actions';
      case "En cours d'exécution": return 'hourglass_top';
      case 'Traité': return 'check_circle';
      case 'Rejeté': return 'cancel';
      default: return 'help_outline';
    }
  }

  formatDate(dateStr?: string): string {
    if (!dateStr) return 'N/A';
    try {
      const d = new Date(dateStr);
      return d.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
    } catch {
      return dateStr;
    }
  }

  getTimeAgo(dateStr?: string): string {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    const now = new Date();
    const diffMs = now.getTime() - d.getTime();
    const diffH = Math.floor(diffMs / (1000 * 60 * 60));
    if (diffH < 1) return "Il y a moins d'1h";
    if (diffH < 24) return `Il y a ${diffH}h`;
    const diffD = Math.floor(diffH / 24);
    if (diffD === 1) return 'Hier';
    return `Il y a ${diffD} jours`;
  }
}
