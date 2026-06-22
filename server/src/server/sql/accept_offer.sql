UPDATE rent_offers SET accepted_at = now(), updated_at = now() WHERE id = $1 AND accepted_at IS NULL
returning id
