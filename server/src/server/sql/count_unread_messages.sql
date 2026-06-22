SELECT
  rr.id,
  COUNT(u.event_at)::int AS cnt
FROM rent_requests rr
LEFT JOIN (
  -- messages from the other participant
  SELECT m.rent_request_id, m.created_at AS event_at FROM messages m WHERE m.author_id != $1
  UNION ALL
  -- offers from the other participant
  SELECT ro.rent_request_id, ro.created_at FROM rent_offers ro WHERE ro.sender_id != $1
  UNION ALL
  -- accepted offers (owner accepts → unread for requester)
  SELECT ro2.rent_request_id, ro2.accepted_at
  FROM rent_offers ro2
  JOIN rent_requests rr2 ON rr2.id = ro2.rent_request_id
  WHERE ro2.accepted_at IS NOT NULL AND $1 = rr2.requester_id
  UNION ALL
  -- borrow confirmed (owner confirms → unread for requester)
  SELECT rr3.id, rr3.borrow_confirmed_at
  FROM rent_requests rr3
  WHERE rr3.borrow_confirmed_at IS NOT NULL AND $1 = rr3.requester_id
  UNION ALL
  -- return confirmed (owner confirms → unread for requester)
  SELECT rr4.id, rr4.returned_at
  FROM rent_requests rr4
  WHERE rr4.returned_at IS NOT NULL AND $1 = rr4.requester_id
) u ON u.rent_request_id = rr.id
  AND u.event_at > COALESCE(
    CASE WHEN $1 = rr.requester_id THEN rr.requester_read_at ELSE rr.owner_read_at END,
    '1970-01-01'::timestamp
  )
WHERE rr.requester_id = $1 OR rr.item_id IN (SELECT id FROM items WHERE author_id = $1)
GROUP BY rr.id
