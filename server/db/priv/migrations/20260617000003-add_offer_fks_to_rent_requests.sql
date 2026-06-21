--- migration:up

ALTER TABLE rent_requests
  ADD COLUMN latest_accepted_offer_id INTEGER REFERENCES rent_offers(id) ON DELETE SET NULL,
  ADD COLUMN latest_open_offer_id INTEGER REFERENCES rent_offers(id) ON DELETE SET NULL;

--- migration:down

ALTER TABLE rent_requests
  DROP COLUMN latest_accepted_offer_id,
  DROP COLUMN latest_open_offer_id;

--- migration:end
