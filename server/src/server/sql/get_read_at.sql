SELECT
  CASE WHEN $2 = requester_id THEN requester_read_at::text ELSE owner_read_at::text END AS read_at
FROM rent_requests
WHERE id = $1 AND (
  $2 = requester_id OR $2 = (SELECT author_id FROM items WHERE id = rent_requests.item_id)
)
