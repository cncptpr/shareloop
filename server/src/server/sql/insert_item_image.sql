INSERT INTO item_images (id, item_id, original_name, mime_type, sort_order)
VALUES ($1, $2, $3, $4, $5)
returning id