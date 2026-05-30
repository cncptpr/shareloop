--- migration:up
-- 
CREATE TABLE sessions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  refresh_token_hash TEXT NOT NULL DEFAULT '',
  refresh_expires_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_token_hash ON sessions(token_hash);
CREATE UNIQUE INDEX idx_sessions_refresh_token_hash ON sessions(refresh_token_hash);

--- migration:down

DROP TABLE sessions;

--- migration:end
