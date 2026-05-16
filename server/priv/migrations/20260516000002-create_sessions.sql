--- migration:up
CREATE TABLE sessions (
  id SERIAL PRIMARY KEY,
  token_hash TEXT NOT NULL UNIQUE,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_sessions_token_hash ON sessions(token_hash);
CREATE INDEX idx_sessions_user_id ON sessions(user_id);
--- migration:down
DROP TABLE sessions;
--- migration:end
