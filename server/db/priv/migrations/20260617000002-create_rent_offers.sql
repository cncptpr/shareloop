--- migration:up

CREATE TABLE rent_offers (
  id SERIAL PRIMARY KEY,
  rent_request_id INTEGER NOT NULL REFERENCES rent_requests(id) ON DELETE CASCADE,
  sender_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP NOT NULL,
  accepted_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rent_offers_rent_request_id ON rent_offers(rent_request_id);

--- migration:down

DROP TABLE rent_offers;

--- migration:end
