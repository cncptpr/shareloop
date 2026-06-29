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

Lives in `server/src/cli/main.py`.

Run with `python -m src.cli.main`. Commands:

| Command                          | Description                                    |
|----------------------------------|------------------------------------------------|
| `create-user <email>`            | Create a new user (prompts for password)       |
| `list-users`                     | List all users                                 |
| `sessions`                       | Show active sessions with expiry times         |
| `login <email>`                  | Login (prompts for password), saves tokens     |
| `validate`                       | Validate the stored access token               |
| `refresh`                        | Refresh tokens using the stored refresh token  |
| `expire-access [email]`          | Expire the stored access token (or all for email) |

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

Implemented in `server/src/auth/password.py`.

### Tokens

Both access and refresh tokens are generated as 32 random bytes, base64url-encoded for the client. The server stores `SHA-256(raw_bytes)` → base64url-encoded hash.

Implemented in `server/src/auth/tokens.py`.

## Relevant Files

### Server
- `server/src/handlers/auth.py` — auth HTTP handlers
- `server/src/auth/password.py` — password hashing
- `server/src/auth/tokens.py` — token generation and hashing
- `server/src/cli/main.py` — dev CLI for auth operations
- `server/src/db/models.py` — SQLAlchemy ORM models (single source of truth for DB schema)
- `server/alembic/versions/` — Alembic migration versions

### App (Flutter/Dart)
- `app/lib/state/auth.dart` — auth state management
- `app/lib/state/token_storage.dart` — token persistence via `FlutterSecureStorage`
