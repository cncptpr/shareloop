UPDATE rent_requests SET latest_open_offer_id = $1, updated_at = now() WHERE id = $2
