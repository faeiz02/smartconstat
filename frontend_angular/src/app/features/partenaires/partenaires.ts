import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule, Router } from '@angular/router';
import { ClientService, HealthcareProfessional } from '../../core/services/client.service';
import { AuthService } from '../../core/services/auth.service';
import { ThemeService } from '../../core/services/theme.service';

@Component({
  selector: 'app-partenaires',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './partenaires.html',
  styleUrls: ['./partenaires.css']
})
export class PartenairesComponent implements OnInit {
  professionals: HealthcareProfessional[] = [];
  filteredProfessionals: HealthcareProfessional[] = [];
  isLoading = true;
  searchQuery = '';
  activeTypeFilter: string | null = null;
  types: string[] = [];

  // Add/Edit modal
  showModal = false;
  isEditing = false;
  isSaving = false;
  modalMessage = '';
  modalMessageType: 'success' | 'error' = 'success';
  editItem: any = {};

  // Delete modal
  showDeleteModal = false;
  isDeleting = false;
  itemToDelete: any = null;

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
    this.clientService.getHealthcareProfessionals().subscribe({
      next: (data: any[]) => {
        this.professionals = data;
        const typeSet = new Set<string>(data.map((p: any) => p.type || 'Autre').filter((t: any) => t));
        this.types = Array.from(typeSet);
        this.applyFilters();
        this.isLoading = false;
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        console.error('Error loading healthcare professionals', err);
        if (err.status === 401 || err.status === 403) { this.authService.logout(); this.router.navigate(['/login']); }
        this.isLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  filterByType(type: string | null): void { this.activeTypeFilter = type; this.applyFilters(); }
  onSearch(): void { this.applyFilters(); }

  applyFilters(): void {
    let result = [...this.professionals];
    if (this.activeTypeFilter) result = result.filter(p => (p.type || 'Autre') === this.activeTypeFilter);
    const q = this.searchQuery.toLowerCase().trim();
    if (q) {
      result = result.filter(p =>
        (p.name || '').toLowerCase().includes(q) || (p.type || '').toLowerCase().includes(q) ||
        (p.address || '').toLowerCase().includes(q) || (p.phone || '').includes(q)
      );
    }
    this.filteredProfessionals = result;
  }

  countByType(type: string): number { return this.professionals.filter(p => (p.type || 'Autre') === type).length; }

  getTypeIcon(type?: string): string {
    switch (type) {
      case 'Clinique': return 'local_hospital';
      case 'Généraliste': return 'person';
      case 'Dentiste': return 'medical_services';
      case 'Garage': return 'garage';
      default: return 'health_and_safety';
    }
  }

  getStars(rating?: number): number[] {
    const r = Math.round(rating || 0);
    return Array(5).fill(0).map((_: any, i: number) => i < r ? 1 : 0);
  }

  // ─── CRUD ───
  openAddModal(): void {
    this.isEditing = false;
    this.editItem = { name: '', type: '', address: '', phone: '', distanceStr: '', rating: 0, reviewCount: 0, bio: '' };
    this.modalMessage = '';
    this.showModal = true;
  }

  openEditModal(item: any): void {
    this.isEditing = true;
    this.editItem = { ...item };
    this.modalMessage = '';
    this.showModal = true;
  }

  closeModal(): void { this.showModal = false; }

  saveItem(): void {
    if (!this.editItem.name || !this.editItem.type) {
      this.modalMessage = 'Nom et type sont requis.';
      this.modalMessageType = 'error';
      this.cdr.markForCheck();
      return;
    }
    this.isSaving = true;
    this.modalMessage = '';

    const obs = this.isEditing
      ? this.clientService.updateHealthcareProfessional(this.editItem.id, this.editItem)
      : this.clientService.createHealthcareProfessional(this.editItem);

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

  openDeleteModal(item: any): void { this.itemToDelete = item; this.showDeleteModal = true; }
  closeDeleteModal(): void { this.showDeleteModal = false; this.itemToDelete = null; }

  confirmDelete(): void {
    if (!this.itemToDelete?.id) return;
    this.isDeleting = true;
    this.clientService.deleteHealthcareProfessional(this.itemToDelete.id).subscribe({
      next: () => { this.isDeleting = false; this.closeDeleteModal(); this.loadData(); this.cdr.markForCheck(); },
      error: (err: any) => { console.error(err); this.isDeleting = false; this.closeDeleteModal(); }
    });
  }
}
