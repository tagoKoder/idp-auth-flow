import { Routes } from '@angular/router';
import { HomeComponent } from './components/home/home';
import { CallbackComponent } from './components/callback/callback';
import { authGuard } from './auth/auth.guard';

export const routes: Routes = [
  // protegida: exige login
  { path: '', component: HomeComponent, canActivate: [authGuard] },

  // retorno del IdP
  { path: 'callback', component: CallbackComponent},

  // comodín
  { path: '**', redirectTo: '' },
];
