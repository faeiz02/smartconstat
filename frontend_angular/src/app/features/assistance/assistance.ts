import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule, Router } from '@angular/router';
import { ClientService, EmergencyNumber, AssistanceType } from '../../core/services/client.service';
import { AuthService } from '../../core/services/auth.service';
import { ThemeService } from '../../core/services/theme.service';

@Component({
  selector: 'app-assistance',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './assistance.html',
  styleUrls: ['./assistance.css']
})
export class AssistanceComponent implements OnInit {
  emergencyNumbers: EmergencyNumber[] = [];
  assistanceTypes: AssistanceType[] = [];
  isLoading = true;

  // Tab
  activeTab: 'numbers' | 'types' = 'numbers';

  // Modals
  showModal = false;
  isEditing = false;
  isSaving = false;
  modalMessage = '';
  modalMessageType: 'success' | 'error' = 'success';
  editItem: any = {};
  editingEntity: 'number' | 'type' = 'number';

  // Delete
  showDeleteModal = false;
  isDeleting = false;
  itemToDelete: any = null;
  deletingEntity: 'number' | 'type' = 'number';

  constructor(
    private clientService: ClientService,
    private authService: AuthService,
    private router: Router,
    public themeService: ThemeService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    if (!this.authService.hasToken()) { this.router.navigate(['/login']); return; }
    this.loadData();
  }

  loadData(): void {
    this.isLoading = true;
    let loaded = 0;
    const checkDone = () => { loaded++; if (loaded >= 2) { this.isLoading = false; this.cdr.markForCheck(); } };

    this.clientService.getEmergencyNumbers().subscribe({
      next: (data: any) => { this.emergencyNumbers = data; checkDone(); },
      error: () => checkDone()
    });

    this.clientService.getAssistanceTypes().subscribe({
      next: (data: any) => { this.assistanceTypes = data; checkDone(); },
      error: () => checkDone()
    });
  }

  getIconName(iconStr?: string): string {
    if (!iconStr) return 'help_outline';
    const match = iconStr.match(/Icons\.(\w+?)(?:_outlined)?$/);
    return match ? match[1] : iconStr;
  }

  // ─── Emergency Numbers CRUD ───
  openAddNumber(): void {
    this.editingEntity = 'number';
    this.isEditing = false;
    this.editItem = { label: '', number: '', iconStr: '' };
    this.modalMessage = '';
    this.showModal = true;
  }

  openEditNumber(item: any): void {
    this.editingEntity = 'number';
    this.isEditing = true;
    this.editItem = { ...item };
    this.modalMessage = '';
    this.showModal = true;
  }

  // ─── Assistance Types CRUD ───
  openAddType(): void {
    this.editingEntity = 'type';
    this.isEditing = false;
    this.editItem = { title: '', description: '', iconStr: '' };
    this.modalMessage = '';
    this.showModal = true;
  }

  openEditType(item: any): void {
    this.editingEntity = 'type';
    this.isEditing = true;
    this.editItem = { ...item };
    this.modalMessage = '';
    this.showModal = true;
  }

  closeModal(): void { this.showModal = false; }

  saveItem(): void {
    this.isSaving = true;
    this.modalMessage = '';
    let obs: any;

    if (this.editingEntity === 'number') {
      if (!this.editItem.label || !this.editItem.number) {
        this.modalMessage = 'Label et numéro sont requis.';
        this.modalMessageType = 'error';
        this.isSaving = false;
        this.cdr.markForCheck();
        return;
      }
      obs = this.isEditing
        ? this.clientService.updateEmergencyNumber(this.editItem.id, this.editItem)
        : this.clientService.createEmergencyNumber(this.editItem);
    } else {
      if (!this.editItem.title) {
        this.modalMessage = 'Le titre est requis.';
        this.modalMessageType = 'error';
        this.isSaving = false;
        this.cdr.markForCheck();
        return;
      }
      obs = this.isEditing
        ? this.clientService.updateAssistanceType(this.editItem.id, this.editItem)
        : this.clientService.createAssistanceType(this.editItem);
    }

    obs.subscribe({
      next: () => {
        this.modalMessage = this.isEditing ? 'Modifié avec succès' : 'Ajouté avec succès';
        this.modalMessageType = 'success';
        this.isSaving = false;
        this.cdr.markForCheck();
        setTimeout(() => { this.closeModal(); this.loadData(); }, 800);
      },
      error: (err: any) => {
        this.modalMessage = err.error?.error || 'Erreur';
        this.modalMessageType = 'error';
        this.isSaving = false;
        this.cdr.markForCheck();
      }
    });
  }

  // ─── Delete ───
  openDeleteNumber(item: any): void { this.deletingEntity = 'number'; this.itemToDelete = item; this.showDeleteModal = true; }
  openDeleteType(item: any): void { this.deletingEntity = 'type'; this.itemToDelete = item; this.showDeleteModal = true; }
  closeDeleteModal(): void { this.showDeleteModal = false; this.itemToDelete = null; }

  confirmDelete(): void {
    if (!this.itemToDelete?.id) return;
    this.isDeleting = true;
    const obs = this.deletingEntity === 'number'
      ? this.clientService.deleteEmergencyNumber(this.itemToDelete.id)
      : this.clientService.deleteAssistanceType(this.itemToDelete.id);

    obs.subscribe({
      next: () => { this.isDeleting = false; this.closeDeleteModal(); this.loadData(); this.cdr.markForCheck(); },
      error: (err: any) => { console.error(err); this.isDeleting = false; this.closeDeleteModal(); }
    });
  }
}
