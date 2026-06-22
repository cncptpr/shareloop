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
WHERE id = $1
