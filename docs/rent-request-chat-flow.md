# Rent Request & Chat Flow

> This documention is mainly for ai, to avoid regressions when editing

## State Machine

```
Request created → Offer created → Offer accepted → Borrow confirmed → Return confirmed (terminal)
```

Transitions are enforced on the **server** (`renting.gleam`): each operation checks the current state and rejects invalid ones (e.g., can't confirm borrow without an accepted offer, can't confirm return without a borrow). SQL-level `IS NULL` guards on UPDATE statements are defense-in-depth.

## Key Behaviours

1. **Invalidation after mutations.** After every API call (send message, create offer, accept offer, confirm borrow, confirm return) the relevant Riverpod providers must be explicitly invalidated. If you forget, the UI won't update. The specific providers to invalidate are listed in the chat screen's mutation methods.

2. **Auth-change kickout.** A `ref.listen(authProvider)` in the chat screen detects user changes. When triggered, the request provider is invalidated; if the new user is not a participant, the screen pops. Don't remove this.

3. **Timestamp format.** All timestamps go through `timestamp.to_rfc3339(t, calendar.utc_offset)` on the server. The Dart client expects RFC 3339 strings. Don't change this format.

## Key Files

- `server/src/server/renting.gleam` — All business logic and validation
- `server/src/server/sql/*.sql` — SQL query source files
- `app/lib/screens/rent_request_chat_screen.dart` — Chat UI and all state transitions
- `app/lib/screens/message_screen.dart` — Request list
- `app/lib/state/renting.dart` — Riverpod providers
- `api/shareloop.openapi.yaml` — OpenAPI spec for both client and server

## Related

The create/edit item form provider pattern is documented in `docs/item-edit-create-flow.md`.
