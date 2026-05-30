INSERT INTO items (title, description, author_id, score, location, city, postal_code) VALUES ($1, $2, $3, $4, st_setsrid(st_makepoint($5, $6), 4326)::geography, $7, $8)
