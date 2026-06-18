# Item Create & Edit Flow

> This documention is mainly for ai, to avoid regressions when editing

## Principles

**The Riverpod provider is the single source of truth for all form state.** All field values (title, description, category, location, images) live in the provider, not in local variables. The screen reads from it, writes changes back to it, and reads from it on submit.

This is the most-frequently-regressed pattern in this codebase. If you touch any create/edit file, verify the provider is still being used as the canonical store.

## Two Providers

- **`createItemFormProvider`** — single instance (not family). Used for the create flow. Gets cleared with `reset()` after a successful submit.
- **`editItemFormProvider`** — family provider keyed by `itemId`. Used for the edit flow. Fetches its own data via API on first access. **Not reset on submit** — state stays cached so edits survive navigating away and back.

## What an AI tends to break

1. Removing the provider and replacing it with local `TextEditingController` state. The provider IS the state — controllers are just required by Flutter's `TextField` widgets and must sync every keystroke to the notifier.
2. Passing `ItemEditDetail` through the widget constructor and initializing the notifier from the screen. The notifier fetches its own data — the screen only needs `itemId`.
3. Calling notifier methods in `initState` (throws an exception). Read-only `ref.read()` in `initState` is fine; mutations happen via listeners registered in `build()`.

## Key Files

- `app/lib/state/item_form.dart` — Both notifiers and providers
- `app/lib/screens/create_item_screen.dart` — Create form
- `app/lib/screens/edit_item_screen.dart` — Edit form
- `app/lib/components/item_form_body.dart` — Shared form UI
- `app/lib/components/location_form_mixin.dart` — Location picker integration
