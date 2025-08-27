import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';

@Injectable({ providedIn: 'root' })
export class IdentityApi {
  constructor(private http: HttpClient) {}

  /** POST /api/v1/administrator-web/identity/link (id_token via header) */
  link(idToken: string) {
    const headers = new HttpHeaders().set('X-ID-Token', idToken);
    return this.http.post('http://localhost:8085/api/v1/administrator-web/identity/link', {}, { headers });
  }

  /** GET /api/v1/administrator-web/identity/whoami (access_token via interceptor) */
  whoAmI() {
    return this.http.get('http://localhost:8085/api/v1/administrator-web/identity/whoami');
  }
}
