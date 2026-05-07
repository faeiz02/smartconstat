import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { ClientService, Client } from '../../core/services/client.service';
import { AuthService } from '../../core/services/auth.service';
import { ThemeService } from '../../core/services/theme.service';

@Component({
  selector: 'app-employees',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './employees.html',
  styleUrls: ['./employees.css']
})
export class EmployeesComponent implements OnInit {
  employees: Client[] = [];
  filteredEmployees: Client[] = [];
  isLoading = true;
  searchQuery = '';
  userName = '';
  activeRoleFilter: string | null = null;

  // Role modal
  showRoleModal = false;
  selectedUser: Client | null = null;
  selectedRole = 'employe';
  isUpdatingRole = false;
  roleMessage = '';
  roleMessageType: 'success' | 'error' = 'success';

  // Delete modal
  showDeleteModal = false;
  userToDelete: Client | null = null;
  isDeleting = false;

  // Add modal
  showAddModal = false;
  isCreating = false;
  addMessage = '';
  addMessageType: 'success' | 'error' = 'success';
  newUser = {
    email: '',
    password: '',
    nom: '',
    prenom: '',
    cin: '',
    phone: '',
    role: 'employe'
  };

  constructor(
    private clientService: ClientService,
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
    this.loadEmployees();
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  loadEmployees(): void {
    this.isLoading = true;
    this.clientService.getAllClients().subscribe({
      next: (data: any[]) => {
        this.employees = data.filter((c: any) => c.role === 'employe' || c.role === 'admin');
        this.applyFilters();
        this.isLoading = false;
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        console.error('Error loading employees', err);
        if (err.status === 401 || err.status === 403) {
          this.authService.logout();
          this.router.navigate(['/login']);
        }
        this.isLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  onSearch(): void { this.applyFilters(); }

  filterByRole(role: string | null): void {
    this.activeRoleFilter = role;
    this.applyFilters();
  }

  applyFilters(): void {
    let result = [...this.employees];
    if (this.activeRoleFilter) {
      result = result.filter(c => c.role === this.activeRoleFilter);
    }
    const q = this.searchQuery.toLowerCase().trim();
    if (q) {
      result = result.filter(c =>
        (c.nom || '').toLowerCase().includes(q) ||
        (c.prenom || '').toLowerCase().includes(q) ||
        (c.email || '').toLowerCase().includes(q) ||
        (c.cin || '').toLowerCase().includes(q) ||
        (c.phone || '').includes(q)
      );
    }
    this.filteredEmployees = result;
  }

  countByRole(role: string): number {
    return this.employees.filter(c => c.role === role).length;
  }

  getInitials(emp: Client): string {
    const n = (emp.nom || '?')[0];
    const p = (emp.prenom || '?')[0];
    return `${n}${p}`.toUpperCase();
  }

  formatDate(dateStr?: string): string {
    if (!dateStr) return 'N/A';
    try {
      const d = new Date(dateStr);
      return d.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric' });
    } catch { return dateStr; }
  }

  // ─── Add Employee ───
  openAddModal(): void {
    this.newUser = { email: '', password: '', nom: '', prenom: '', cin: '', phone: '', role: 'employe' };
    this.addMessage = '';
    this.showAddModal = true;
  }

  closeAddModal(): void {
    this.showAddModal = false;
  }

  createUser(): void {
    if (!this.newUser.email || !this.newUser.password || !this.newUser.nom || !this.newUser.prenom) {
      this.addMessage = 'Veuillez remplir tous les champs obligatoires.';
      this.addMessageType = 'error';
      this.cdr.markForCheck();
      return;
    }
    this.isCreating = true;
    this.addMessage = '';

    this.clientService.createUser(this.newUser).subscribe({
      next: (res: any) => {
        this.addMessage = res.message || 'Compte créé avec succès';
        this.addMessageType = 'success';
        this.isCreating = false;
        this.cdr.markForCheck();
        setTimeout(() => {
          this.closeAddModal();
          this.loadEmployees();
        }, 1200);
      },
      error: (err: any) => {
        this.addMessage = err.error?.error || 'Erreur lors de la création';
        this.addMessageType = 'error';
        this.isCreating = false;
        this.cdr.markForCheck();
      }
    });
  }

  // ─── Role Management ───
  openRoleModal(emp: Client): void {
    this.selectedUser = emp;
    this.selectedRole = emp.role || 'employe';
    this.roleMessage = '';
    this.showRoleModal = true;
  }

  closeRoleModal(): void {
    this.showRoleModal = false;
    this.selectedUser = null;
  }

  updateRole(): void {
    if (!this.selectedUser || !this.selectedUser.id) return;
    this.isUpdatingRole = true;
    this.roleMessage = '';

    this.clientService.updateUserRole(this.selectedUser.id, this.selectedRole).subscribe({
      next: () => {
        this.roleMessage = 'Rôle mis à jour avec succès';
        this.roleMessageType = 'success';
        this.isUpdatingRole = false;
        this.cdr.markForCheck();
        if (this.selectedUser) this.selectedUser.role = this.selectedRole;
        setTimeout(() => { this.closeRoleModal(); this.loadEmployees(); }, 1000);
      },
      error: (err: any) => {
        this.roleMessage = err.error?.error || 'Erreur lors de la mise à jour';
        this.roleMessageType = 'error';
        this.isUpdatingRole = false;
        this.cdr.markForCheck();
      }
    });
  }

  // ─── Delete User ───
  openDeleteModal(emp: Client): void {
    this.userToDelete = emp;
    this.showDeleteModal = true;
  }

  closeDeleteModal(): void {
    this.showDeleteModal = false;
    this.userToDelete = null;
  }

  confirmDelete(): void {
    if (!this.userToDelete || !this.userToDelete.id) return;
    this.isDeleting = true;

    this.clientService.deleteUser(this.userToDelete.id).subscribe({
      next: () => {
        this.isDeleting = false;
        this.closeDeleteModal();
        this.loadEmployees();
        this.cdr.markForCheck();
      },
      error: (err: any) => {
        console.error('Error deleting user', err);
        this.isDeleting = false;
        this.closeDeleteModal();
      }
    });
  }
}
