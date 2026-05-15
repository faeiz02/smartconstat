import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { ClientService, Client } from '../../core/services/client.service';
import { AuthService } from '../../core/services/auth.service';
import { ThemeService } from '../../core/services/theme.service';

@Component({
  selector: 'app-clients',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './clients.component.html',
  styleUrls: ['./clients.component.css']
})
export class ClientsComponent implements OnInit {
  clients: Client[] = []; filteredClients: Client[] = []; isLoading = true; searchQuery = ''; userName = '';

  constructor(private clientService: ClientService, private authService: AuthService, private router: Router, public themeService: ThemeService, private cdr: ChangeDetectorRef) {}
  ngOnInit(): void { if(!this.authService.hasToken()){this.router.navigate(['/login']);return;} const u=this.authService.getUser(); this.userName=u?`${u.nom||''} ${u.prenom||''}`.trim():'Admin'; this.loadClients(); }
  logout():void{this.authService.logout();this.router.navigate(['/login']);}

  loadClients():void{
    this.isLoading=true;
    this.clientService.getAllClients().subscribe({
      next:(data:any[])=>{this.clients=data;this.applyFilters();this.isLoading=false;this.cdr.markForCheck();},
      error:(err:any)=>{if(err.status===401||err.status===403){this.authService.logout();this.router.navigate(['/login']);}this.isLoading=false;this.cdr.markForCheck();}
    });
  }
  onSearch():void{this.applyFilters();}
  applyFilters():void{const q=this.searchQuery.toLowerCase().trim();if(!q){this.filteredClients=[...this.clients];}else{this.filteredClients=this.clients.filter(c=>(c.nom||'').toLowerCase().includes(q)||(c.prenom||'').toLowerCase().includes(q)||(c.email||'').toLowerCase().includes(q)||(c.cin||'').toLowerCase().includes(q)||(c.phone||'').includes(q));}}
  countByRole(role:string):number{return this.clients.filter(c=>c.role===role).length;}
  getInitials(client:Client):string{return`${(client.nom||'?')[0]}${(client.prenom||'?')[0]}`.toUpperCase();}
  formatDate(d?:string):string{if(!d)return'N/A';try{return new Date(d).toLocaleDateString('fr-FR',{day:'2-digit',month:'2-digit',year:'numeric'});}catch{return d;}}
}
