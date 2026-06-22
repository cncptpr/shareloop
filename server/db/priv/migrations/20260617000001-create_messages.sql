--- migration:up

CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  rent_request_id INTEGER NOT NULL REFERENCES rent_requests(id) ON DELETE CASCADE,
  author_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_messages_rent_request_id ON messages(rent_request_id);

--- migration:down

DROP TABLE messages;

--- migration:end
