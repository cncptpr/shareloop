--- migration:up
ALTER TABLE sessions ADD COLUMN refresh_token_hash TEXT NOT NULL DEFAULT '';
ALTER TABLE sessions ADD COLUMN refresh_expires_at TIMESTAMP NOT NULL DEFAULT NOW();
CREATE UNIQUE INDEX idx_sessions_refresh_token_hash ON sessions(refresh_token_hash);
--- migration:down
ALTER TABLE sessions DROP COLUMN refresh_expires_at;
ALTER TABLE sessions DROP COLUMN refresh_token_hash;
--- migration:end
