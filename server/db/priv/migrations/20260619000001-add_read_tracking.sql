--- migration:up

ALTER TABLE rent_requests
  ADD COLUMN requester_read_at TIMESTAMP,
  ADD COLUMN owner_read_at TIMESTAMP;

--- migration:down

ALTER TABLE rent_requests
  DROP COLUMN requester_read_at,
  DROP COLUMN owner_read_at;

--- migration:end
