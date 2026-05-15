import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { ClientService, Assurance } from '../../core/services/client.service';
import { AuthService } from '../../core/services/auth.service';
import { ThemeService } from '../../core/services/theme.service';

@Component({
  selector: 'app-assurances',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './assurances.component.html',
  styleUrls: ['./assurances.component.css']
})
export class AssurancesComponent implements OnInit {
  assurances: Assurance[] = []; filteredAssurances: Assurance[] = []; isLoading = true; searchQuery = '';
  showModal = false; isEditing = false; isSaving = false; modalMessage = ''; modalMessageType: 'success'|'error' = 'success'; editItem: any = {};
  showDeleteModal = false; isDeleting = false; itemToDelete: Assurance|null = null;

  constructor(private clientService: ClientService, private authService: AuthService, private router: Router, public themeService: ThemeService, private cdr: ChangeDetectorRef) {}
  ngOnInit(): void { if(!this.authService.hasToken()){this.router.navigate(['/login']);return;} this.loadData(); }

  loadData(): void {
    this.isLoading=true;
    this.clientService.getAllAssurances().subscribe({
      next:(data:any[])=>{this.assurances=data;this.applyFilters();this.isLoading=false;this.cdr.markForCheck();},
      error:(err:any)=>{if(err.status===401||err.status===403){this.authService.logout();this.router.navigate(['/login']);}this.isLoading=false;this.cdr.markForCheck();}
    });
  }
  onSearch(): void { this.applyFilters(); }
  applyFilters(): void {
    const q=this.searchQuery.toLowerCase().trim();
    if(!q){this.filteredAssurances=[...this.assurances];}else{this.filteredAssurances=this.assurances.filter(a=>(a.assuranceId||'').toLowerCase().includes(q)||(a.nom||'').toLowerCase().includes(q)||(a.prenom||'').toLowerCase().includes(q)||(a.cin||'').toLowerCase().includes(q)||(a.compagnie||'').toLowerCase().includes(q)||(a.vehiclePlate||'').toLowerCase().includes(q));}
  }
  formatDate(d?:string):string{if(!d)return'N/A';try{return new Date(d).toLocaleDateString('fr-FR',{day:'2-digit',month:'2-digit',year:'numeric'});}catch{return d;}}
  isExpired(d?:string):boolean{if(!d)return false;return new Date(d)<new Date();}
  getInitials(a:Assurance):string{return`${(a.nom||'?')[0]}${(a.prenom||'?')[0]}`.toUpperCase();}
  openAddModal():void{this.isEditing=false;this.editItem={assuranceId:'',nom:'',prenom:'',cin:'',phone:'',vehicleBrand:'',vehicleModel:'',vehiclePlate:'',compagnie:'',dateExpiration:''};this.modalMessage='';this.showModal=true;}
  openEditModal(item:Assurance):void{this.isEditing=true;this.editItem={...item};this.modalMessage='';this.showModal=true;}
  closeModal():void{this.showModal=false;}
  saveItem():void{
    if(!this.editItem.assuranceId||!this.editItem.cin){this.modalMessage="L'ID d'assurance et le CIN sont requis.";this.modalMessageType='error';this.cdr.markForCheck();return;}
    this.isSaving=true;this.modalMessage='';
    const obs=this.isEditing?this.clientService.updateAssurance(this.editItem.id,this.editItem):this.clientService.createAssurance(this.editItem);
    obs.subscribe({next:()=>{this.modalMessage=this.isEditing?'Modifié avec succès':'Ajouté avec succès';this.modalMessageType='success';this.isSaving=false;this.cdr.markForCheck();setTimeout(()=>{this.closeModal();this.loadData();},800);},error:(err:any)=>{this.modalMessage=err.error?.error||'Erreur';this.modalMessageType='error';this.isSaving=false;this.cdr.markForCheck();}});
  }
  openDeleteModal(item:Assurance):void{this.itemToDelete=item;this.showDeleteModal=true;}
  closeDeleteModal():void{this.showDeleteModal=false;this.itemToDelete=null;}
  confirmDelete():void{if(!this.itemToDelete?.id)return;this.isDeleting=true;this.clientService.deleteAssurance(this.itemToDelete.id).subscribe({next:()=>{this.isDeleting=false;this.closeDeleteModal();this.loadData();this.cdr.markForCheck();},error:(err:any)=>{console.error(err);this.isDeleting=false;this.closeDeleteModal();}});}
  exportCSV():void{
    const h=['ID Assurance','Nom','Prénom','CIN','Téléphone','Marque','Modèle','Plaque','Compagnie','Expiration'];
    const rows=this.assurances.map(a=>[a.assuranceId,a.nom,a.prenom,a.cin,a.phone,a.vehicleBrand,a.vehicleModel,a.vehiclePlate,a.compagnie,a.dateExpiration]);
    const csv=[h,...rows].map(r=>r.map(v=>`"${v||''}"`).join(',')).join('\n');
    const blob=new Blob(['\ufeff'+csv],{type:'text/csv;charset=utf-8;'});const url=URL.createObjectURL(blob);const a=document.createElement('a');a.href=url;a.download='assurances.csv';a.click();URL.revokeObjectURL(url);
  }
}
