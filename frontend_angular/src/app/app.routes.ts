import { Routes } from '@angular/router';
import { LoginComponent } from './features/login/login';
import { DashboardComponent } from './features/dashboard/dashboard';
import { ConstatDetailComponent } from './features/constat-detail/constat-detail';
import { ClientsComponent } from './features/clients/clients';
import { EmployeesComponent } from './features/employees/employees';
import { FacturesComponent } from './features/factures/factures';
import { AssistanceComponent } from './features/assistance/assistance';
import { PartenairesComponent } from './features/partenaires/partenaires';
import { AdminLayoutComponent } from './core/layout/admin-layout/admin-layout';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { 
    path: '', 
    component: AdminLayoutComponent,
    children: [
      { path: 'dashboard', component: DashboardComponent },
      { path: 'clients', component: ClientsComponent },
      { path: 'employes', component: EmployeesComponent },
      { path: 'constat/:id', component: ConstatDetailComponent },
      { path: 'assistance', component: AssistanceComponent },
      { path: 'factures', component: FacturesComponent },
      { path: 'partenaires', component: PartenairesComponent },
    ]
  },
  { path: '**', redirectTo: 'login' }
];
