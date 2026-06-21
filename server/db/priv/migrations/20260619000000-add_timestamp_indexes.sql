--- migration:up
CREATE INDEX IF NOT EXISTS idx_messages_request_created
  ON messages (rent_request_id, created_at);

CREATE INDEX IF NOT EXISTS idx_offers_request_created
  ON rent_offers (rent_request_id, created_at);

CREATE INDEX IF NOT EXISTS idx_rent_requests_updated
  ON rent_requests (updated_at);
--- migration:down
DROP INDEX idx_messages_request_created;

DROP INDEX idx_offers_request_created;

DROP INDEX idx_rent_requests_updated;
--- migration:end
