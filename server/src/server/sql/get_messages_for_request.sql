SELECT
  id,
  rent_request_id,
  author_id,
  content,
  created_at as created_at
FROM messages
WHERE rent_request_id = $1
ORDER BY created_at ASC
