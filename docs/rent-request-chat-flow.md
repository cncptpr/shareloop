# Rent Request & Chat Flow

> This documentation is mainly for ai, to avoid regressions when editing

## State Machine

```
Request created → Offer created → Offer accepted → Borrow confirmed → Return confirmed (terminal)
```

Each transition is enforced server-side: operations check the current state and reject invalid ones. SQL `IS NULL` guards on UPDATE statements are defense-in-depth.

## Features

### Chat & Messaging
Users with a rent request can exchange messages. Each request has exactly two participants: the requester (wants to borrow) and the owner (lends the item).

### Offers
Either participant can propose a date range for borrowing. The other party can accept the offer, which locks it in and advances the state. Only the latest offer can be accepted by a user. New offers can be made at any time, if e.g. wanting to change a detail. The last accepted offer stays the "valid" one, until the newest offer is accepted.

### Confirmation Flow
1. **Borrow confirmed** — The owner marks the item as handed over
2. **Return confirmed** — The owner marks the item as returned (terminal state)

### Real-Time Updates (WebSocket)
When one participant performs an action (sends a message, creates/accepts an offer, confirms borrow/return), the server pushes a notification to the **other** participant over WebSocket. The client receives these events and automatically refreshes the relevant data — no manual refresh needed.

Supported event types: `message.created`, `offer.created`, `offer.accepted`, `borrow.confirmed`, `return.confirmed`.

### Local Notifications
When a WebSocket event arrives and the user is not currently viewing that specific chat, a local notification is shown. The notification text matches the event type (e.g. "Neue Nachricht", "Neues Angebot"). If the user is already in that chat, no notification is shown — the UI updates live instead.

### Unread Counts
Each request tracks (in the db) when each participant last read it (`requester_read_at` / `owner_read_at`). The unread count includes:
- Messages from the other participant
- Offers from the other participant
- Offers accepted by the other participant
- Borrow/return confirmations by the owner

All events are compared against the user's `last_read` timestamp. Events before that timestamp or authored by the current user are not counted. The overview list shows a red badge with the unread count per request.

### Mark-Read
When the chat screen is opened (or new content arrives via WebSocket while the chat is open), the client calls the mark-read endpoint. This updates the user's `last_read` timestamp and clears the unread badge for that request.

### Auth-Change Kickout
If the logged-in user changes while a chat screen is open, the request data is re-fetched. If the new user is not a participant, the screen pops automatically.

## Architecture Overview

- **API** — All mutations go through REST endpoints defined in the OpenAPI spec
- **WebSocket** — Connected after auth; receives events for requests the user participates in
- **State** — On the client, a single `rentRequestProvider` (keyed by request ID) holds the full detail including messages and offers. The overview list is served by `myRentRequestsProvider`.

## Data Flow

1. User opens app → WebSocket connects after auth
2. Message screen shows request list with unread badges
3. Tapping a chat opens `RentRequestChatScreen` with the request ID
4. The screen fetches the full detail (messages, offers, status)
5. Mark-read is called automatically (any new content triggers it)
6. User sends messages, creates offers, etc. → API call → server updates DB → server pushes WebSocket event to the other participant → their app refreshes automatically
7. When leaving the chat, mark-read stops (the next visit or new content will trigger it again)
