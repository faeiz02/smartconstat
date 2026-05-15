import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ConstatService, Constat } from '../../core/services/constat';
import { AuthService } from '../../core/services/auth.service';
import { ThemeService } from '../../core/services/theme.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {
  constats: Constat[] = [];
  filteredConstats: Constat[] = [];
  isLoading = true;
  activeTab: string | null = null;
  searchQuery = '';
  userName = '';
  userRole = '';
  notifications: any = null;
  performance: any[] = [];

  tabs = [
    { label: 'Tous', statut: null, icon: 'list_alt' },
    { label: 'Non examinés', statut: 'Non examiné', icon: 'pending' },
    { label: 'En cours', statut: "En cours d'exécution", icon: 'hourglass_top' },
    { label: 'Docs manquants', statut: 'Documents manquants', icon: 'folder_off' },
    { label: 'Expertise', statut: 'En expertise', icon: 'manage_search' },
    { label: 'Traités', statut: 'Traité', icon: 'check_circle' },
    { label: 'Rejetés', statut: 'Rejeté', icon: 'cancel' },
    { label: 'Archivés', statut: 'Archivé', icon: 'inventory_2' }
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
    if (this.isAdmin()) this.loadAdminInsights();
  }

  isAdmin(): boolean { return this.userRole === 'admin'; }

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

  loadAdminInsights(): void {
    this.constatService.getAdminNotifications().subscribe({
      next: data => { this.notifications = data; this.cdr.markForCheck(); },
      error: () => {}
    });
    this.constatService.getEmployeePerformance().subscribe({
      next: data => { this.performance = data; this.cdr.markForCheck(); },
      error: () => {}
    });
  }

  filterConstats(statut: string | null): void {
    this.activeTab = statut;
    let result = !statut ? [...this.constats] : this.constats.filter(c => c.statut === statut);
    const q = this.searchQuery.toLowerCase().trim();
    if (q) {
      result = result.filter(c =>
        (c.lieu || '').toLowerCase().includes(q) ||
        (c.userName || '').toLowerCase().includes(q) ||
        (c.userEmail || '').toLowerCase().includes(q) ||
        (c.immatriculationA || '').toLowerCase().includes(q) ||
        (c.immatriculationB || '').toLowerCase().includes(q) ||
        (c.assureurA || '').toLowerCase().includes(q) ||
        (c.assureurB || '').toLowerCase().includes(q) ||
        (c.statut || '').toLowerCase().includes(q)
      );
    }
    this.filteredConstats = result;
  }

  onSearch(): void { this.filterConstats(this.activeTab); }

  countByStatut(statut: string): number {
    return this.constats.filter(c => c.statut === statut).length;
  }

  getMyAssignedCount(): number {
    return this.constats.filter(c =>
      c.statut === "En cours d'exécution" ||
      c.statut === 'Documents manquants' ||
      c.statut === 'En expertise'
    ).length;
  }

  getMyTreatedCount(): number {
    return this.constats.filter(c => c.statut === 'Traité').length;
  }

  getStatutClass(statut?: string): string {
    switch (statut) {
      case 'Non examiné': return 'status-warning';
      case "En cours d'exécution": return 'status-info';
      case 'Documents manquants': return 'status-warning';
      case 'En expertise': return 'status-info';
      case 'Traité': return 'status-success';
      case 'Rejeté': return 'status-danger';
      default: return 'status-default';
    }
  }

  getStatutIcon(statut?: string): string {
    switch (statut) {
      case 'Non examiné': return 'pending_actions';
      case "En cours d'exécution": return 'hourglass_top';
      case 'Documents manquants': return 'folder_off';
      case 'En expertise': return 'manage_search';
      case 'Traité': return 'check_circle';
      case 'Rejeté': return 'cancel';
      case 'Archivé': return 'inventory_2';
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

  getAcceptanceRate(): string {
    const treated = this.constats.filter(c => c.statut === 'Traité').length;
    const total = this.constats.filter(c => c.statut === 'Traité' || c.statut === 'Rejeté').length;
    if (total === 0) return '-';
    return Math.round((treated / total) * 100) + '%';
  }

  getRejectionRate(): string {
    const rejected = this.constats.filter(c => c.statut === 'Rejeté').length;
    const total = this.constats.filter(c => c.statut === 'Traité' || c.statut === 'Rejeté').length;
    if (total === 0) return '-';
    return Math.round((rejected / total) * 100) + '%';
  }

  getStatutPercentage(statut: string): number {
    if (this.constats.length === 0) return 0;
    return Math.round((this.countByStatut(statut) / this.constats.length) * 100);
  }

  isOverdue(constat: Constat): boolean {
    if (!constat.dateLimite) return false;
    return new Date(constat.dateLimite) < new Date() && !['Traité', 'Rejeté', 'Archivé'].includes(constat.statut || '');
  }

  hasMissingPieces(constat: Constat): boolean {
    return !constat.croquisPath || !constat.signatureAPath || !constat.signatureBPath || !constat.photosPaths;
  }

  exportCSV(): void {
    const headers = ['ID', 'Date', 'Lieu', 'Statut', 'Priorité', 'Date limite', 'Conducteur A', 'Immat A', 'Conducteur B', 'Immat B', 'Soumis par', 'Traité par'];
    const rows = this.constats.map(c => [
      c.accidentId || c.id,
      c.dateTime,
      c.lieu,
      c.statut,
      c.priorite,
      c.dateLimite,
      `${c.nomA || ''} ${c.prenomA || ''}`.trim(),
      c.immatriculationA,
      `${c.nomB || ''} ${c.prenomB || ''}`.trim(),
      c.immatriculationB,
      c.userName,
      c.traiteParNom
    ]);
    const csv = [headers, ...rows].map(r => r.map(v => `"${v || ''}"`).join(',')).join('\n');
    const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url; a.download = 'constats.csv'; a.click();
    URL.revokeObjectURL(url);
  }
}
