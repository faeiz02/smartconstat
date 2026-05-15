import { Routes } from '@angular/router';
import { LoginComponent } from './features/login/login.component';
import { DashboardComponent } from './features/dashboard/dashboard';
import { ConstatDetailComponent } from './features/constat-detail/constat-detail';
import { ClientsComponent } from './features/clients/clients.component';
import { EmployeesComponent } from './features/employees/employees.component';
import { FacturesComponent } from './features/factures/factures.component';
import { AssistanceComponent } from './features/assistance/assistance.component';
import { PartenairesComponent } from './features/partenaires/partenaires.component';
import { AssurancesComponent } from './features/assurances/assurances.component';
import { AvisComponent } from './features/avis/avis.component';
import { AdminLayoutComponent } from './core/layout/admin-layout/admin-layout';
import { adminGuard, authGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  {
    path: '',
    component: AdminLayoutComponent,
    children: [
      // Shared routes (admin + employee)
      { path: 'dashboard', component: DashboardComponent, canActivate: [authGuard] },
      { path: 'constat/:id', component: ConstatDetailComponent, canActivate: [authGuard] },

      // Admin-only routes
      { path: 'clients', component: ClientsComponent, canActivate: [adminGuard] },
      { path: 'employes', component: EmployeesComponent, canActivate: [adminGuard] },
      { path: 'assistance', component: AssistanceComponent, canActivate: [adminGuard] },
      { path: 'factures', component: FacturesComponent, canActivate: [adminGuard] },
      { path: 'partenaires', component: PartenairesComponent, canActivate: [adminGuard] },
      { path: 'assurances', component: AssurancesComponent, canActivate: [adminGuard] },
      { path: 'avis', component: AvisComponent, canActivate: [adminGuard] },
    ]
  },
  { path: '**', redirectTo: 'login' }
];
