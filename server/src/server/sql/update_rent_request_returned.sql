UPDATE rent_requests SET returned_at = now(), updated_at = now() WHERE id = $1 AND returned_at IS NULL
