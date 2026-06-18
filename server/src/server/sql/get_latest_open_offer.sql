SELECT
  id,
  rent_request_id,
  sender_id,
  start_date::text as start_date,
  end_date::text as end_date,
  accepted_at as accepted_at,
  created_at::text as created_at,
  updated_at::text as updated_at
FROM rent_offers
WHERE rent_request_id = $1 AND accepted_at IS NULL
ORDER BY created_at DESC
LIMIT 1
