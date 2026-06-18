SELECT
  id,
  rent_request_id,
  sender_id,
  start_date as start_date,
  end_date as end_date,
  accepted_at as accepted_at,
  created_at as created_at,
  updated_at as updated_at
FROM rent_offers
WHERE rent_request_id = $1 AND accepted_at IS NOT NULL
ORDER BY accepted_at DESC
LIMIT 1
