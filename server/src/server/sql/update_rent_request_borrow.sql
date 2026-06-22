UPDATE rent_requests SET borrow_confirmed_at = now(), updated_at = now() WHERE id = $1 AND borrow_confirmed_at IS NULL
