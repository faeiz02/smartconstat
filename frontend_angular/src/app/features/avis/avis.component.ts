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
  templateUrl: './avis.component.html',
  styleUrls: ['../assurances/assurances.component.css', './avis.component.css']
})
export class AvisComponent implements OnInit {
  avis: AvisAdmin[] = []; filteredAvis: AvisAdmin[] = []; isLoading = true; searchQuery = ''; ratingFilter: number|null = null;
  showDeleteModal = false; isDeleting = false; itemToDelete: AvisAdmin|null = null;

  constructor(private clientService: ClientService, private authService: AuthService, private router: Router, public themeService: ThemeService, private cdr: ChangeDetectorRef) {}
  ngOnInit(): void { if(!this.authService.hasToken()){this.router.navigate(['/login']);return;} this.loadData(); }

  loadData(): void {
    this.isLoading=true;
    this.clientService.getAllAvis().subscribe({
      next:(data:any[])=>{this.avis=data;this.applyFilters();this.isLoading=false;this.cdr.markForCheck();},
      error:(err:any)=>{if(err.status===401||err.status===403){this.authService.logout();this.router.navigate(['/login']);}this.isLoading=false;this.cdr.markForCheck();}
    });
  }
  onSearch():void{this.applyFilters();}
  filterByRating(r:number|null):void{this.ratingFilter=r;this.applyFilters();}
  applyFilters():void{let r=[...this.avis];if(this.ratingFilter!==null){r=r.filter(a=>Math.floor(a.rating||0)===this.ratingFilter);}const q=this.searchQuery.toLowerCase().trim();if(q){r=r.filter(a=>(a.userName||'').toLowerCase().includes(q)||(a.comment||'').toLowerCase().includes(q));}this.filteredAvis=r;}
  getAverageRating():string{if(this.avis.length===0)return'0.0';return(this.avis.reduce((s,a)=>s+(a.rating||0),0)/this.avis.length).toFixed(1);}
  getStars(rating?:number):number[]{const r=Math.round(rating||0);return Array(5).fill(0).map((_:any,i:number)=>i<r?1:0);}
  formatDate(d?:string):string{if(!d)return'N/A';try{return new Date(d).toLocaleDateString('fr-FR',{day:'2-digit',month:'2-digit',year:'numeric'});}catch{return d;}}
  openDeleteModal(item:AvisAdmin):void{this.itemToDelete=item;this.showDeleteModal=true;}
  closeDeleteModal():void{this.showDeleteModal=false;this.itemToDelete=null;}
  confirmDelete():void{if(!this.itemToDelete?.id)return;this.isDeleting=true;this.clientService.adminDeleteAvis(this.itemToDelete.id).subscribe({next:()=>{this.isDeleting=false;this.closeDeleteModal();this.loadData();this.cdr.markForCheck();},error:(err:any)=>{console.error(err);this.isDeleting=false;this.closeDeleteModal();}});}
  exportCSV():void{const h=['Utilisateur','Note','Commentaire','Date','ID Professionnel'];const rows=this.avis.map(a=>[a.userName,a.rating,a.comment,a.createdAt,a.professionalId]);const csv=[h,...rows].map(r=>r.map(v=>`"${v||''}"`).join(',')).join('\n');const blob=new Blob(['\ufeff'+csv],{type:'text/csv;charset=utf-8;'});const url=URL.createObjectURL(blob);const a=document.createElement('a');a.href=url;a.download='avis.csv';a.click();URL.revokeObjectURL(url);}
}
