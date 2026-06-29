# WebSocket API

Shareloop uses a single authenticated WebSocket connection per app session to push realtime updates about rent requests, messages, and offers.

## Connection

```
ws://<host>/ws
wss://<host>/ws
```

When behind the nginx proxy (production), use:

```
ws://<host>/ws
```

## Authentication

The WebSocket does NOT use a token in the URL. Instead:

1. Open a raw WebSocket connection to `/ws`.
2. Send a JSON auth message as your **first frame**:

```json
{"type": "auth", "token": "<access_token>"}
```

- The server expects this message within **5 seconds** of connecting.
- If no valid auth message is received in time, the server closes the connection.
- On success, the server responds with:

```json
{"type": "auth", "status": "ok"}
```

- On failure, the server responds with an error and closes:

```json
{"type": "auth", "status": "error"}
```

## Event Format

After authentication, the server pushes JSON text frames for relevant changes. Every event has this shape:

```json
{
  "type": "<event_type>",
  "rent_request_id": <int>,
  "data": { ... }
}
```

The `rent_request_id` tells the client which rent request was affected so it can invalidate local caches or trigger a refetch.

## Event Types

| Type | Fires when | `data` shape |
|---|---|---|
| `message.created` | A participant sends a chat message | `Message` object |
| `offer.created` | A participant creates or counters an offer | `RentOffer` object |
| `offer.accepted` | The owner accepts an offer | `RentOffer` object |
| `borrow.confirmed` | The owner confirms the item was borrowed | `RentRequest` object |
| `return.confirmed` | The owner confirms the item was returned | `RentRequest` object |

All `data` payloads match the corresponding OpenAPI schema definitions.

## Client Behaviour

- One connection per authenticated app session.
- If the connection drops, reconnect and re-authenticate.
- On receiving an event, refetch the affected rent request via `GET /api/rent-requests/{requestId}?after=<last_known_timestamp>` to get only new messages/offers.
- There is no server-side heartbeat; clients should not rely on ping/pong (the connection stays open indefinitely).
