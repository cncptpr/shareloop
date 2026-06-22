# Auth

## Two-Token Workflow

Shareloop uses a **two-token** authentication scheme:

| Token         | Lifetime | Purpose                           |
|---------------|----------|-----------------------------------|
| Access token  | 1 hour   | Authenticates API requests        |
| Refresh token | 30 days  | Obtains a new access/refresh pair |

On refresh, both tokens are **rotated** — a new pair is issued and the old access/refresh tokens become invalid immediately.

## App-Side Auth
Lives in `app/lib/state/auth.dart`.

- `authProvider` — Fetches and provides logged in `User` (riverpod).

- `authStatusNotifier` — enum with `initial`, `authenticated`, `unauthenticated` (riverpod).

- `UnauthorizedException` — simple enum with `missingTokens`, `verifyFailed`, `refreshFailed`, `loginFailed`.

- `login(email, password)` — calls the API, handles the tokens, and returns the `User`.

- `logout()` — calls, removes the tokens and sets status to `unauthenticated`.

## API Client

Use `AppConfig.apiClient` for all request. It is a preconfigured `ApiClient`, that automatically performs refreshes. 

## Development

### Seeded default user

When you run the seed script, it creates a dev user for local testing:

```
Email:    dev@example.com
Password: dev
```

In debug mode, the app pre-fills the login fields with these credentials.

### Debug display

The profile screen shows for debug purposes the current auth state some infos.

### CLI tool

Lives in `server/test/server/cli.gleam`.

Run with `gleam run -m server/cli`. Commands:

| Command                          | Description                                    |
|----------------------------------|------------------------------------------------|
| `help` / `-h`                    | Print help                                     |
| `users create <email>`           | Create a new user (prompts for password)       |
| `users list`                     | List all users                                 |
| `users sessions`                 | Show active sessions with expiry times         |
| `users login <email>`            | Login (prompts for password), saves tokens     |
| `users validate`                 | Validate the stored access token               |
| `users refresh`                  | Refresh tokens using the stored refresh token  |
| `users expire-access [email]`    | Expire the stored access token (or all for email) |
| `users expire-refresh [email]`   | Expire both tokens for the session (or all for email) |
| `users logout`                   | Delete the session for the stored access token |

Tokens are stored in `tokens.txt` in the server working directory.

## API Endpoints

All auth endpoints are defined in `api/shareloop.openapi.yaml` and generated into server handlers.

| Method | Path             | OperationId   | Auth required | Request body                                     | Response body                  |
|--------|------------------|---------------|---------------|--------------------------------------------------|--------------------------------|
| POST   | `/auth/login`    | `login`       | No            | `{ email: string, password: string }`            | `LoginResult` (user + tokens) |
| POST   | `/auth/refresh`  | `refresh`     | No            | `{ refreshToken: string }`                       | `LoginResult` (new tokens)    |
| POST   | `/auth/verify`   | `verify`      | Bearer token  | —                                                | `User`                        |
| POST   | `/auth/logout`   | `logout`      | Bearer token  | —                                                | 204 No Content                |

All return **401** on invalid credentials, expired tokens, or missing/auth headers.

## Hashing

### Passwords

Uses **PBKDF2 with HMAC-SHA256**, 600,000 iterations, 16-byte random salt, 32-byte derived key.

Stored format: `$pbkdf2-sha256$<iterations>$<base64url-salt>$<base64url-hash>`

Implemented in `server/src/server/auth/password.gleam` with an Erlang NIF (`auth_ffi.pbkdf2_hmac`) calling `crypto:pbkdf2_hmac/5`.

### Tokens

Both access and refresh tokens are generated as 32 random bytes, base64url-encoded for the client. The server stores `SHA-256(raw_bytes)` → base64url-encoded hash.

Implemented in `server/src/server/auth/session.gleam`.

## Relevant Files

### Server
- `server/src/server/auth.gleam` — core auth logic
- `server/src/server/auth/*` — password and token helpers and http handlers for auth
- `server/src/auth_ffi.erl` — Erlang FFI for PBKDF2
- `server/db/priv/migrations/20260516000001-create_users.sql` — users table migration
- `server/db/priv/migrations/20260516000002-create_sessions.sql` — sessions table migration
- `server/test/server/cli.gleam` — dev CLI for auth operations

### App (Flutter/Dart)
- `app/lib/state/auth.dart` — auth state management
- `app/lib/state/token_storage.dart` — token persistence via `FlutterSecureStorage`

