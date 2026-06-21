SELECT
  rr.id,
  COUNT(m.id)::int AS cnt
FROM rent_requests rr
LEFT JOIN messages m ON m.rent_request_id = rr.id
  AND m.author_id != $1
  AND (
    CASE WHEN $1 = rr.requester_id THEN rr.requester_read_at ELSE rr.owner_read_at END IS NULL
    OR m.created_at > CASE WHEN $1 = rr.requester_id THEN rr.requester_read_at ELSE rr.owner_read_at END
  )
WHERE rr.requester_id = $1 OR rr.item_id IN (SELECT id FROM items WHERE author_id = $1)
GROUP BY rr.id
