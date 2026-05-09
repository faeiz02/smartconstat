import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { ClientService, AvisAdmin } from '../../core/services/client.service';
import { AuthService } from '../../core/services/auth.service';
import { ThemeService } from '../../core/services/theme.service';

@Component({
  selector: 'app-avis',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './avis.html',
  styleUrls: ['../assurances/assurances.css', './avis.css']
})
export class AvisComponent implements OnInit {
  avis: AvisAdmin[] = [];
  filteredAvis: AvisAdmin[] = [];
  isLoading = true;
  searchQuery = '';
  ratingFilter: number | null = null;

  // Delete
  showDeleteModal = false;
  isDeleting = false;
  itemToDelete: AvisAdmin | null = null;

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
    this.clientService.getAllAvis().subscribe({
      next: (data: any[]) => {
        this.avis = data;
        this.applyFilters();
        this.isLoading = false;
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        console.error('Error loading avis', err);
        if (err.status === 401 || err.status === 403) { this.authService.logout(); this.router.navigate(['/login']); }
        this.isLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  onSearch(): void { this.applyFilters(); }

  filterByRating(rating: number | null): void {
    this.ratingFilter = rating;
    this.applyFilters();
  }

  applyFilters(): void {
    let result = [...this.avis];
    if (this.ratingFilter !== null) {
      result = result.filter(a => Math.floor(a.rating || 0) === this.ratingFilter);
    }
    const q = this.searchQuery.toLowerCase().trim();
    if (q) {
      result = result.filter(a =>
        (a.userName || '').toLowerCase().includes(q) ||
        (a.comment || '').toLowerCase().includes(q)
      );
    }
    this.filteredAvis = result;
  }

  getAverageRating(): string {
    if (this.avis.length === 0) return '0.0';
    const avg = this.avis.reduce((sum, a) => sum + (a.rating || 0), 0) / this.avis.length;
    return avg.toFixed(1);
  }

  getStars(rating?: number): number[] {
    const r = Math.round(rating || 0);
    return Array(5).fill(0).map((_: any, i: number) => i < r ? 1 : 0);
  }

  formatDate(dateStr?: string): string {
    if (!dateStr) return 'N/A';
    try { return new Date(dateStr).toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric' }); } catch { return dateStr; }
  }

  openDeleteModal(item: AvisAdmin): void { this.itemToDelete = item; this.showDeleteModal = true; }
  closeDeleteModal(): void { this.showDeleteModal = false; this.itemToDelete = null; }

  confirmDelete(): void {
    if (!this.itemToDelete?.id) return;
    this.isDeleting = true;
    this.clientService.adminDeleteAvis(this.itemToDelete.id).subscribe({
      next: () => { this.isDeleting = false; this.closeDeleteModal(); this.loadData(); this.cdr.markForCheck(); },
      error: (err: any) => { console.error(err); this.isDeleting = false; this.closeDeleteModal(); }
    });
  }

  exportCSV(): void {
    const headers = ['Utilisateur', 'Note', 'Commentaire', 'Date', 'ID Professionnel'];
    const rows = this.avis.map(a => [a.userName, a.rating, a.comment, a.createdAt, a.professionalId]);
    const csv = [headers, ...rows].map(r => r.map(v => `"${v || ''}"`).join(',')).join('\n');
    const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url; a.download = 'avis.csv'; a.click();
    URL.revokeObjectURL(url);
  }
}
