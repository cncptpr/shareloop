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
WHERE id = $1
