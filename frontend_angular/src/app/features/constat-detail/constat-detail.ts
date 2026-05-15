import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { ConstatService, Constat } from '../../core/services/constat';
import { ClientService, Client } from '../../core/services/client.service';
import { AuthService } from '../../core/services/auth.service';
import { ThemeService } from '../../core/services/theme.service';

@Component({
  selector: 'app-constat-detail',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './constat-detail.component.html',
  styleUrls: ['./constat-detail.component.css']
})
export class ConstatDetailComponent implements OnInit {
  constat: Constat | null = null;
  history: any[] = [];
  employees: Client[] = [];
  isLoading = true;
  isUpdating = false;
  isSavingTracking = false;
  isAssigning = false;
  successMessage = '';
  errorMessage = '';
  userName = '';
  userRole = '';
  routeConstatId = '';
  selectedEmployeeId: number | null = null;
  assignmentComment = '';
  statusComment = '';

  workflowStatuses = [
    { label: 'En cours', value: "En cours d'exécution", icon: 'hourglass_top', className: 'btn-info' },
    { label: 'Docs manquants', value: 'Documents manquants', icon: 'folder_off', className: 'btn-warning' },
    { label: 'Expertise', value: 'En expertise', icon: 'manage_search', className: 'btn-neutral' },
    { label: 'Traité', value: 'Traité', icon: 'check_circle', className: 'btn-success' },
    { label: 'Rejeté', value: 'Rejeté', icon: 'cancel', className: 'btn-danger' },
    { label: 'Archivé', value: 'Archivé', icon: 'inventory_2', className: 'btn-secondary' }
  ];

  tracking = {
    priorite: 'Normale',
    dateLimite: '',
    noteInterne: '',
    documentsManquants: '',
    responsabiliteEstimee: '',
    montantEstime: null as number | null,
    commentaireDecision: '',
    escalade: false,
    escaladeRaison: ''
  };

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private constatService: ConstatService,
    private clientService: ClientService,
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
    this.routeConstatId = this.route.snapshot.paramMap.get('id') || '';

    if (this.isAdmin()) {
      this.loadEmployees();
    }
    if (this.routeConstatId) {
      this.loadConstatDetails(this.routeConstatId);
    }
  }

  isAdmin(): boolean {
    return this.userRole === 'admin';
  }

  isEmployee(): boolean {
    return this.userRole === 'employe';
  }

  loadConstatDetails(id: string): void {
    this.isLoading = true;
    this.constatService.getAllConstats().subscribe({
      next: (data: any[]) => {
        this.constat = data.find((c: any) => String(c.id) === id || c.accidentId === id) || null;
        if (this.constat) {
          this.syncTracking(this.constat);
          this.selectedEmployeeId = this.constat.traiteParId || null;
          this.loadHistory();
        }
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

  loadEmployees(): void {
    this.clientService.getAllClients().subscribe({
      next: (data: Client[]) => {
        this.employees = data.filter(emp =>
          (emp.role === 'employe' || emp.role === 'admin') && emp.active !== false
        );
        this.cdr.markForCheck();
      },
      error: () => {}
    });
  }

  loadHistory(): void {
    const id = this.getConstatId();
    if (!id) return;
    this.constatService.getHistory(id).subscribe({
      next: data => {
        this.history = data || [];
        this.cdr.markForCheck();
      },
      error: () => {}
    });
  }

  syncTracking(constat: Constat): void {
    this.tracking = {
      priorite: constat.priorite || 'Normale',
      dateLimite: this.toDateTimeLocal(constat.dateLimite),
      noteInterne: constat.noteInterne || '',
      documentsManquants: constat.documentsManquants || '',
      responsabiliteEstimee: constat.responsabiliteEstimee || '',
      montantEstime: constat.montantEstime ?? null,
      commentaireDecision: constat.commentaireDecision || '',
      escalade: !!constat.escalade,
      escaladeRaison: constat.escaladeRaison || ''
    };
  }

  getConstatId(): number | null {
    if (!this.constat) return null;
    const id = this.constat.id || Number(this.constat.accidentId);
    return Number.isFinite(id) ? Number(id) : null;
  }

  assignConstat(): void {
    const id = this.getConstatId();
    if (!id || !this.selectedEmployeeId) {
      this.showError('Sélectionnez un employé.');
      return;
    }

    this.isAssigning = true;
    this.constatService.assignConstat(id, this.selectedEmployeeId, this.assignmentComment).subscribe({
      next: () => {
        const selected = this.employees.find(emp => emp.id === this.selectedEmployeeId);
        if (this.constat) {
          this.constat = {
            ...this.constat,
            statut: this.constat.statut === 'Non examiné' ? "En cours d'exécution" : this.constat.statut,
            traiteParId: this.selectedEmployeeId || undefined,
            traiteParNom: selected ? `${selected.nom || ''} ${selected.prenom || ''}`.trim() : this.constat.traiteParNom
          };
        }
        this.assignmentComment = '';
        this.isAssigning = false;
        this.showSuccess('Dossier affecté.');
        this.loadHistory();
      },
      error: (err: any) => {
        this.isAssigning = false;
        this.showError(err.error?.error || 'Affectation impossible.');
      }
    });
  }

  updateStatut(newStatut: string): void {
    const id = this.getConstatId();
    if (!this.constat || !id) return;

    const comment = this.buildStatusComment(newStatut);
    if (newStatut === 'Rejeté' && !comment) {
      this.showError('Le motif de rejet est obligatoire.');
      return;
    }

    this.isUpdating = true;
    this.constatService.updateStatut(id, newStatut, comment).subscribe({
      next: () => {
        if (this.constat) {
          this.constat = {
            ...this.constat,
            statut: newStatut,
            traiteParNom: newStatut === "En cours d'exécution" && !this.constat.traiteParNom
              ? this.userName
              : this.constat.traiteParNom,
            motifRejet: newStatut === 'Rejeté' ? comment : this.constat.motifRejet,
            documentsManquants: newStatut === 'Documents manquants' && comment
              ? comment
              : this.constat.documentsManquants
          };
        }
        this.statusComment = '';
        this.isUpdating = false;
        this.showSuccess(`Statut mis à jour : ${newStatut}`);
        this.loadHistory();
      },
      error: (err: any) => {
        console.error('Error updating status', err);
        this.isUpdating = false;
        if (err.status === 409) {
          this.showError('Ce constat est déjà en cours de traitement par un autre employé.');
        } else {
          this.showError(err.error?.error || 'Erreur lors de la mise à jour du statut.');
        }
      }
    });
  }

  saveTracking(): void {
    const id = this.getConstatId();
    if (!id) return;

    const payload = {
      ...this.tracking,
      dateLimite: this.tracking.dateLimite || null,
      montantEstime: this.tracking.montantEstime === null ? null : Number(this.tracking.montantEstime),
      comment: 'Mise à jour du suivi'
    };

    this.isSavingTracking = true;
    this.constatService.updateTracking(id, payload).subscribe({
      next: () => {
        if (this.constat) {
          this.constat = {
            ...this.constat,
            ...payload,
            dateLimite: payload.dateLimite || undefined,
            montantEstime: payload.montantEstime ?? undefined
          };
        }
        this.isSavingTracking = false;
        this.showSuccess('Suivi enregistré.');
        this.loadHistory();
      },
      error: (err: any) => {
        this.isSavingTracking = false;
        this.showError(err.error?.error || 'Mise à jour du suivi impossible.');
      }
    });
  }

  buildStatusComment(newStatut: string): string {
    const typed = this.statusComment.trim();
    if (typed) return typed;
    if (newStatut === 'Documents manquants') return this.tracking.documentsManquants.trim();
    if (newStatut === 'Traité') return this.tracking.commentaireDecision.trim();
    if (newStatut === 'En expertise') return this.tracking.escaladeRaison.trim();
    return '';
  }

  canUpdateStatus(newStatut: string): boolean {
    if (!this.constat) return false;
    if (this.isAdmin()) return true;

    const current = this.constat.statut || 'Non examiné';
    if (newStatut === "En cours d'exécution") return current === 'Non examiné';
    if (['Documents manquants', 'En expertise', 'Traité', 'Rejeté'].includes(newStatut)) {
      return ["En cours d'exécution", 'Documents manquants', 'En expertise'].includes(current);
    }
    return false;
  }

  canSaveTracking(): boolean {
    if (!this.constat) return false;
    return this.isAdmin() || (this.isEmployee() && !!this.constat.traiteParNom && this.constat.statut !== 'Non examiné');
  }

  canReset(): boolean {
    return this.isAdmin() && ['Traité', 'Rejeté', 'Archivé'].includes(this.constat?.statut || '');
  }

  getPriorityClass(priority?: string): string {
    switch (priority) {
      case 'Urgente': return 'priority-danger';
      case 'Haute': return 'priority-warning';
      case 'Basse': return 'priority-muted';
      default: return 'priority-default';
    }
  }

  getChecklist(): Array<{ label: string; ok: boolean }> {
    if (!this.constat) return [];
    return [
      { label: 'Identité conducteur A', ok: !!(this.constat.nomA && this.constat.prenomA) },
      { label: 'Identité conducteur B', ok: !!(this.constat.nomB && this.constat.prenomB) },
      { label: 'Contrats renseignés', ok: !!(this.constat.contratA && this.constat.contratB) },
      { label: 'Deux parties renseignées', ok: !!(this.constat.immatriculationA && this.constat.immatriculationB) },
      { label: 'Croquis présent', ok: !!this.constat.croquisPath },
      { label: 'Signatures présentes', ok: !!(this.constat.signatureAPath && this.constat.signatureBPath) },
      { label: 'Photos présentes', ok: !!this.constat.photosPaths }
    ];
  }

  showSuccess(message: string): void {
    this.successMessage = message;
    this.errorMessage = '';
    this.cdr.markForCheck();
    setTimeout(() => {
      this.successMessage = '';
      this.cdr.markForCheck();
    }, 3000);
  }

  showError(message: string): void {
    this.errorMessage = message;
    this.successMessage = '';
    this.cdr.markForCheck();
    setTimeout(() => {
      this.errorMessage = '';
      this.cdr.markForCheck();
    }, 5000);
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  getStatutClass(statut?: string): string {
    switch (statut) {
      case 'Non examiné': return 'status-warning';
      case "En cours d'exécution": return 'status-info';
      case 'Documents manquants': return 'status-warning';
      case 'En expertise': return 'status-info';
      case 'Traité': return 'status-success';
      case 'Rejeté': return 'status-danger';
      case 'Archivé': return 'status-default';
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

  formatAction(actionType?: string): string {
    switch (actionType) {
      case 'CREATION': return 'Création';
      case 'STATUT': return 'Statut';
      case 'AFFECTATION': return 'Affectation';
      case 'SUIVI': return 'Suivi';
      default: return actionType || 'Action';
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

  toDateTimeLocal(dateStr?: string): string {
    if (!dateStr) return '';
    return dateStr.length >= 16 ? dateStr.substring(0, 16) : dateStr;
  }
}
