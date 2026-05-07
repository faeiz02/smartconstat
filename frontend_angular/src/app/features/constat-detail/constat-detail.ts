import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { ConstatService, Constat } from '../../core/services/constat';
import { AuthService } from '../../core/services/auth.service';
import { ThemeService } from '../../core/services/theme.service';

@Component({
  selector: 'app-constat-detail',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './constat-detail.html',
  styleUrls: ['./constat-detail.css']
})
export class ConstatDetailComponent implements OnInit {
  constat: Constat | null = null;
  isLoading = true;
  isUpdating = false;
  successMessage = '';
  errorMessage = '';
  userName = '';
  userRole = '';

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private constatService: ConstatService,
    private authService: AuthService,
    public themeService: ThemeService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    if (!this.authService.hasToken()) {
      this.router.navigate(['/login']);
      return;
    }
    const user = this.authService.getUser();
    this.userName = user ? `${user.nom || ''} ${user.prenom || ''}`.trim() : 'Employé';
    this.userRole = this.authService.getUserRole();
    const idParam = this.route.snapshot.paramMap.get('id');
    if (idParam) {
      this.loadConstatDetails(idParam);
    }
  }

  isAdmin(): boolean {
    return this.userRole === 'admin';
  }

  loadConstatDetails(id: string): void {
    this.isLoading = true;
    this.constatService.getAllConstats().subscribe({
      next: (data: any[]) => {
        this.constat = data.find((c: any) => String(c.id) === id || c.accidentId === id) || null;
        this.isLoading = false;
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        console.error('Error loading constat details', err);
        if (err.status === 401 || err.status === 403) {
          this.authService.logout();
          this.router.navigate(['/login']);
        }
        this.isLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  updateStatut(newStatut: string): void {
    if (!this.constat) return;
    const id = this.constat.id || Number(this.constat.accidentId);
    if (!id) return;
    
    this.isUpdating = true;
    this.successMessage = '';
    this.errorMessage = '';
    this.constatService.updateStatut(Number(id), newStatut).subscribe({
      next: () => {
        if (this.constat) {
          this.constat = { ...this.constat, statut: newStatut, traiteParNom: this.userName };
        }
        this.isUpdating = false;
        this.successMessage = `Statut mis à jour : ${newStatut}`;
        this.cdr.markForCheck();
        setTimeout(() => { this.successMessage = ''; this.cdr.markForCheck(); }, 3000);
      },
      error: (err: any) => {
        console.error('Error updating status', err);
        this.isUpdating = false;
        if (err.status === 409) {
          this.errorMessage = 'Ce constat est déjà en cours de traitement par un autre employé.';
        } else {
          this.errorMessage = 'Erreur lors de la mise à jour du statut.';
        }
        setTimeout(() => { this.errorMessage = ''; this.cdr.markForCheck(); }, 5000);
        this.cdr.markForCheck();
      }
    });
  }

  canTakeCharge(): boolean {
    return this.constat?.statut === 'Non examiné';
  }

  canMarkTreated(): boolean {
    return this.constat?.statut === "En cours d'exécution";
  }

  canReject(): boolean {
    return this.constat?.statut === "En cours d'exécution";
  }

  canReset(): boolean {
    return this.isAdmin() && (this.constat?.statut === 'Traité' || this.constat?.statut === 'Rejeté');
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
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
}
