# Seeding

The seeding system provides demo data for development and testing.

> **WARNING**: Seeding is a DEVELOPMENT feature. When enabled, **anyone** can
> reset the database (no auth required on `/api/seed`). Do **NOT** enable
> seeding in production.

## How it works

On startup, the server looks for `{SEEDING_DIR}/data.yaml` (default `./seeding`, in Docker `/seeding`). If the file and all referenced images are valid, seeding is made available — otherwise it's silently disabled.

## Seeding API

| Endpoint | Method | Auth | Description |
|---|---|---|---|---|
| `/api/info` | GET | No | Returns server version, API version, and seeding status |
| `/api/seed` | POST | No | Triggers database seeding (deletes all existing data first) |
| `/api/seed/decline` | POST | No | Records that the user declined seeding (sets timestamp, no data change) |

### `/api/info` response

```json
{
  "serverVersion": "v0.1.0",
  "apiVersion": "v0.1.0",
  "seeding": null | "prompt" | "enabled"
}
```

- `null` — seeding is disabled (no valid `data.yaml` found)
- `"prompt"` — seed data is available, but seeding has never been performed.
  The app will show a dialog asking if the user wants to seed.
- `"enabled"` — seed data is available. The app shows a button to re-seed, but no startup dialog.

### `/api/seed` response

- `200` — `{"message": "Seeding erfolgreich"}`
- `400` — Seeding is disabled (no valid data)
- `500` — Seeding failed

### `/api/seed/decline` response

- `200` — `{"message": "Seeding abgelehnt"}`
- `400` — Seeding is disabled (no valid data)

## YAML format (`data.yaml`)

The file has three sections: `users`, `items`, and `rent_requests`. Each entry
has an `id` that other entries reference via `ref(other_id)`.

### Users

```yaml
users:
  - id: user_dev
    email: dev@example.com
    password: dev
    name: Dev
    bio: Dev user
    rating: 4.9
```

### Items

```yaml
items:
  - id: item_spezi
    title: Spezi
    description: Bitte voll zurueck
    author: ref(user_timon)
    score: 5.0
    lng: 8.6821
    lat: 50.1109
    city: Frankfurt am Main
    postalCode: "60311"
    category: Sonstiges
    images:
      - path: images/paulaner-spezi.jpg
        sort_order: 0
```

Image `path` values are relative to the `SEEDING_DIR`. Only the filenames inside
the images directory (e.g. `images/foo.jpg`).

### Rent Requests

```yaml
rent_requests:
  - id: req_a
    item: ref(item_spezi)
    requester: ref(user_lisa)
    borrow_confirmed: false   # optional, defaults to false
    returned: false           # optional, defaults to false
    messages:
      - author: ref(user_lisa)
        content: "Hey, kann ich die Spezi fürs Wochenende ausleihen?"
        created_at: "-3d 10:00"    # optional, defaults to "now"
    offers:
      - sender: ref(user_timon)
        start_date: "+2d"
        end_date: "+4d"
        accepted: false
        created_at: "-3d 15:00"    # optional, defaults to "now"
        accepted_at: "-2d 10:00"   # optional, only if accepted: true
    borrow_confirmed_at: "-1d 08:00"  # optional, only if borrow_confirmed: true
    returned_at: "-1d 20:00"          # optional, only if returned: true
    read_at: "-3d 16:00"              # optional, defaults to "now"
    mark_read:
      - ref(user_lisa)
      - ref(user_timon)
```

All timestamp fields use the relative format `[+/-]N[d|h|m] [HH:MM]`:

| Format | Example | Meaning |
|---|---|---|
| `"now"` | `"now"` | Current time at seed |
| `-3d 10:00` | 3 days ago at 10:00 UTC | Past, with wall-clock time |
| `-1h` | 1 hour ago | Past, relative only |
| `+2d` | 2 days from now | Future |
| `-30m` | 30 minutes ago | Past, minutes precision |

- `+` or no prefix = future, `-` = past
- `d` = days, `h` = hours, `m` = minutes
- The `HH:MM` suffix only applies to `d` (days) and pins the time on that day
- Fallback: ISO 8601 strings like `"2026-06-20T00:00:00Z"` also work

Refs are resolved at seed time to the actual database IDs.

## Configuration

| Env variable | Default | Description |
|---|---|---|
| `SEEDING_DIR` | `./seeding` | Directory containing `data.yaml` and `images/` |

## App behavior

When the app starts it calls `GET /api/info`. Depending on the `seeding` value:

- **`null`** — No seeding UI is shown anywhere.
- **`"prompt"`** — A startup dialog asks "Testdaten einspielen?"
  - **Ja** — calls `/api/seed`, logs the user out (if logged in) and shows a
    restart-prompt dialog ("Bitte starte die App neu").
  - **Nein** — calls `/api/seed/decline`, which sets the server-side timestamp.
    The dialog never appears again after either Yes or No (the server returns
    `"enabled"` once the timestamp is set).
  - **Später fragen** — dismisses the dialog; it will reappear on next app
    start since no server call was made and the timestamp stays `NULL`.
- **`"enabled"`** — No startup dialog, but a "Demo-Daten einspielen" button is
  shown on the profile screen.

In all cases where seeding is not `null`, the profile screen shows the seed
button with a warning dialog.
