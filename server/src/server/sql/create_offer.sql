INSERT INTO rent_offers (rent_request_id, sender_id, start_date, end_date) VALUES ($1, $2, $3, $4)
returning id
