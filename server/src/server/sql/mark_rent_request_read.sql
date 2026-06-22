UPDATE rent_requests
SET
  requester_read_at = CASE WHEN $2 = requester_id THEN NOW() ELSE requester_read_at END,
  owner_read_at = CASE WHEN $2 = (SELECT author_id FROM items WHERE id = rent_requests.item_id) THEN NOW() ELSE owner_read_at END
WHERE id = $1 AND (
  $2 = requester_id OR $2 = (SELECT author_id FROM items WHERE id = rent_requests.item_id)
)
