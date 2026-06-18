INSERT INTO messages (rent_request_id, author_id, content) VALUES ($1, $2, $3)
returning id
