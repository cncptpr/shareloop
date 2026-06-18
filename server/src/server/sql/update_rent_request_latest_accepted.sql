UPDATE rent_requests SET latest_accepted_offer_id = $1, latest_open_offer_id = NULL, updated_at = now() WHERE id = $2
