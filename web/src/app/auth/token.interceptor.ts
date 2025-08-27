import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from './auth.service';
import { environment } from '../../environments/environment'; // si usas apiBase

export const tokenInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const token = auth.accessToken;

  // Detecta path aunque la URL sea absoluta
  let path = req.url;
  if (/^https?:\/\//i.test(req.url)) {
    try { path = new URL(req.url).pathname; } catch {}
  }

  // Considera /api relativo o absoluto hacia tu gateway
  const isApi =
    path.startsWith('/api') ||
    (!!environment?.apiBase && req.url.startsWith(environment.apiBase + '/api'));

  if (isApi && token && !req.headers.has('Authorization')) {
    req = req.clone({ setHeaders: { Authorization: `Bearer ${token}` } });
  }
  return next(req);
};
