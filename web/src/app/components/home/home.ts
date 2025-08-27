import { Component, OnInit } from '@angular/core';
import { JsonPipe } from '@angular/common';
import { AuthService } from '../../auth/auth.service';
import { IdentityApi } from '../../integration/identity/identity.api';

@Component({
  standalone: true,
  imports: [JsonPipe],
  template: `
    <h1>Home</h1>
    <button (click)="logout()">Logout</button>

    @if(auth.isLoggedIn){
      <section>
        <h3>Claims (ID Token)</h3>
        <pre>{{ auth.claims | json }}</pre>

        <h3>WhoAmI (Gateway → gRPC Identity)</h3>
        <pre>{{ whoami | json }}</pre>
      </section>
    } @else {
      <p>No autenticado.</p>
    }
  `
})
export class HomeComponent implements OnInit {
  whoami: any;

  constructor(public auth: AuthService, private idApi: IdentityApi) {}

  async ngOnInit() {
    if (this.auth.isLoggedIn) {
      this.idApi.whoAmI().subscribe({
        next: r => this.whoami = r,
        error: e => this.whoami = { error: true, detail: e?.message ?? e }
      });
    }
  }

  logout(){ this.auth.logout(); }
}
