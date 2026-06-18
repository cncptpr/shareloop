--- migration:up

CREATE TABLE rent_requests (
  id SERIAL PRIMARY KEY,
  item_id INTEGER NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  requester_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  borrow_confirmed_at TIMESTAMP,
  returned_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rent_requests_item_id ON rent_requests(item_id);
CREATE INDEX idx_rent_requests_requester_id ON rent_requests(requester_id);

--- migration:down

DROP TABLE rent_requests;

--- migration:end
