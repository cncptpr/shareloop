SELECT
  rr.id,
  rr.item_id,
  rr.requester_id,
  rr.latest_accepted_offer_id,
  rr.latest_open_offer_id,
  rr.borrow_confirmed_at as borrow_confirmed_at,
  rr.returned_at as returned_at,
  rr.created_at::text as created_at,
  rr.updated_at::text as updated_at,
  items.title as item_title,
  requester.name as requester_name,
  owner.name as owner_name,
  owner.id as owner_id
FROM rent_requests rr
JOIN items ON items.id = rr.item_id
JOIN profiles requester ON requester.id = rr.requester_id
JOIN profiles owner ON owner.id = items.author_id
WHERE rr.id = $1
