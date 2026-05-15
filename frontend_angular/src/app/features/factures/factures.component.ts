import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { ClientService, Facture } from '../../core/services/client.service';
import { AuthService } from '../../core/services/auth.service';
import { ThemeService } from '../../core/services/theme.service';

@Component({
  selector: 'app-factures',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './factures.component.html',
  styleUrls: ['../clients/clients.component.css', './factures.component.css']
})
export class FacturesComponent implements OnInit {
  factures: Facture[] = [];
  filteredFactures: Facture[] = [];
  isLoading = true;
  searchQuery = '';
  activeTypeFilter: string | null = null;
  types: string[] = [];
  showDeleteModal = false;
  isDeleting = false;
  itemToDelete: Facture | null = null;

  constructor(private clientService: ClientService, private authService: AuthService, private router: Router, public themeService: ThemeService, private cdr: ChangeDetectorRef) {}

  ngOnInit(): void { if (!this.authService.hasToken()) { this.router.navigate(['/login']); return; } this.loadFactures(); }

  loadFactures(): void {
    this.isLoading = true;
    this.clientService.getAllFactures().subscribe({
      next: (data: any[]) => { this.factures = data; const s = new Set<string>(data.map((f:any) => f.typeFacture||'Autre').filter((t:any)=>t)); this.types = Array.from(s); this.applyFilters(); this.isLoading = false; this.cdr.markForCheck(); },
      error: (err: any) => { if (err.status===401||err.status===403) { this.authService.logout(); this.router.navigate(['/login']); } this.isLoading = false; this.cdr.markForCheck(); }
    });
  }
  filterByType(type: string|null): void { this.activeTypeFilter = type; this.applyFilters(); }
  onSearch(): void { this.applyFilters(); }
  applyFilters(): void {
    let r = [...this.factures]; if (this.activeTypeFilter) r = r.filter(f=>(f.typeFacture||'Autre')===this.activeTypeFilter);
    const q = this.searchQuery.toLowerCase().trim(); if (q) { r = r.filter(f=>(f.userName||'').toLowerCase().includes(q)||(f.userEmail||'').toLowerCase().includes(q)||(f.mois||'').toLowerCase().includes(q)||(f.typeFacture||'').toLowerCase().includes(q)||String(f.montant||'').includes(q)); }
    this.filteredFactures = r;
  }
  countByType(type: string): number { return this.factures.filter(f=>(f.typeFacture||'Autre')===type).length; }
  countByStatut(statut: string): number { return this.factures.filter(f=>(f.statut||'')===statut).length; }
  getTotalMontant(): number { return this.factures.reduce((s,f)=>s+(f.montant||0),0); }
  getStatutClass(statut?: string): string { switch(statut){case'Payée':case'Prise en charge directe':return'status-success';case'À payer':case'En attente':return'status-warning';case'Expertise requise':return'status-info';default:return'status-default';} }
  getTypeIcon(type?: string): string { switch(type){case'Maladie':return'medical_services';case'Réparation':return'build';case'Visite technique':return'engineering';default:return'receipt_long';} }
  formatDate(d?: string): string { if(!d)return'N/A'; try{return new Date(d).toLocaleDateString('fr-FR',{day:'2-digit',month:'2-digit',year:'numeric'});}catch{return d;} }
  formatMontant(m?: number): string { if(m==null)return'0.00 TND'; return m.toFixed(2)+' TND'; }
  openDeleteModal(item: Facture): void { this.itemToDelete=item; this.showDeleteModal=true; }
  closeDeleteModal(): void { this.showDeleteModal=false; this.itemToDelete=null; }
  confirmDelete(): void { if(!this.itemToDelete?.id)return; this.isDeleting=true; this.clientService.adminDeleteFacture(this.itemToDelete.id).subscribe({ next:()=>{this.isDeleting=false;this.closeDeleteModal();this.loadFactures();this.cdr.markForCheck();}, error:(e:any)=>{console.error(e);this.isDeleting=false;this.closeDeleteModal();} }); }
}
