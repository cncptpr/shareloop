INSERT INTO rent_requests (item_id, requester_id) VALUES ($1, $2)
returning id
