# IDP Auth Flow — Authentik + Flutter + Angular + Go + Spring Boot

![Go](https://img.shields.io/badge/Go-00ADD8?logo=go&logoColor=white&style=for-the-badge)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-6DB33F?logo=springboot&logoColor=white&style=for-the-badge)
![Angular](https://img.shields.io/badge/Angular-DD0031?logo=angular&logoColor=white&style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white&style=for-the-badge)
![gRPC](https://img.shields.io/badge/gRPC-4A154B?logo=grpc&logoColor=white&style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white&style=for-the-badge)
![Authentik](https://img.shields.io/badge/Authentik-4A90E2?logo=openid&logoColor=white&style=for-the-badge)


Multi-platform **OpenID Connect (OIDC)** authentication using a single IdP (**Authentik**).  
Both the mobile app (Flutter) and the web admin (Angular) share the same login flow.  
A Go gateway validates issued tokens (multi-issuer support) and communicates with a Spring Boot identity microservice via gRPC to link/upsert users and return a compact profile.

---

## 📂 Repository layout

├─ app/ # Flutter mobile app (patient)
├─ web/ # Angular admin web
├─ gateway/ # Go HTTP gateway (token verify, gRPC clients)
├─ identity/ # Spring Boot identity microservice (gRPC server)
├─ proto/ # Protobuf definitions (IdentityService)
├─ libs/ # Shared utilities for general tools
└─ deploy/ # docker deployment


---

## 🔐 What this implements

- Single IdP (**Authentik**) for both web and mobile.
- **Authorization Code + PKCE** everywhere (no implicit flow).
- Native app redirect via custom scheme (`com.clinic.patient://oauthredirect`).
- Optional HTTPS bridge page (`https://app-patient.<domain>`) to jump back into the app.
- **Gateway (Go):**
  - Validates access tokens against multiple issuers.
  - Forwards authenticated requests to services.
- **Identity service (Spring Boot):**
  - Verifies JWTs.
  - Upserts/links `Person` and `UserAccount`.
  - Returns a compact `WhoAmI` profile.
- Refresh tokens handled client-side (secure storage) with automatic refresh and 401 retry.

---

## 🏗️ High-level architecture
[Flutter app] --(OIDC code+PKCE)--> [Authentik]
| |
| <--- tokens (access/id/refresh) --
|
|--(Bearer access)--> [Gateway /api/...]
|
| (gRPC)
v
[Identity svc]
verifies JWT,
upsert/link, WhoAmI


Web (Angular) follows the same pattern: browser → Authentik → tokens → Gateway → Identity.

---

## 📱 Auth flows

### Mobile (Flutter)
- Launch authorization with `authorizeAndExchangeCode` (PKCE).
- Authentik redirects to:
  - `com.clinic.patient://oauthredirect` (deep link), or  
  - HTTPS bridge page → deep-links back to the app.
- App stores tokens securely and calls:
  - `POST /api/v1/end-user-app/identity/link` with `X-ID-Token` (first login/link).
  - `GET /api/v1/end-user-app/identity/whoami` with access token (subsequent logins).
- Gateway validates, Identity upserts/links, returns `accountId + person`.

### Web (Angular)
- Browser uses code+PKCE with Authentik.
- Calls Gateway with access token → resolved via Identity.

---

## ⚙️ Configuration (examples)

### Authentik (per provider)
Redirect URIs/Origins:
- `com.clinic.patient://oauthredirect` (mobile deep link)
- `https://app-patient.<your-domain>` (optional bridge)
- Your Angular app callback URL  

Enable **Public client + PKCE**.

### Gateway (`.env`)
```env
HTTP_PORT=8085
WHITE_LIST_ORIGIN=*  # or your origins

# Multi-issuer support
OIDC_ISSUERS=https://idp.<domain>/application/o/admin-web/,https://idp.<domain>/application/o/patient-app/
OIDC_AUDIENCE=gateway-api

# or per-issuer mapping
OIDC_AUDIENCES_MAP=https://idp.<domain>/application/o/admin-web/=gateway-api;https://idp.<domain>/application/o/patient-app/=gateway-api

# gRPC
IDENTITY_SERVICE_ADDR=localhost:50051

# Custom header to pass ID token
HEADER_ID_TOKEN_NAME=X-ID-Token
```
### Identity (`.env`)
```
# Allowed issuers (comma separated)
idp.issuers=https://idp.<domain>/application/o/admin-web/,https://idp.<domain>/application/o/patient-app/

# Audiences per issuer
idp.audiences['https://idp.<domain>/application/o/patient-app/']=gateway-api

# Authentik admin API (optional sync)
authentik.host=https://idp.<domain>
authentik.adminToken=<token>
```

## 🔑 Token handling (client side)
- Store access, id, refresh, expires_at in secure storage.

- Attach Authorization: Bearer <access> to API calls.

- On 401, refresh once and retry.

- Refresh proactively before expiry to ensure smooth UX.
- 
## 📌 Notes & tips
- Always use Authorization Code + PKCE, avoid implicit.

- Use HTTPS everywhere (bridge page, web admin).

- Keep mobile deep links (scheme://host/path) stable and whitelisted in Authentik.