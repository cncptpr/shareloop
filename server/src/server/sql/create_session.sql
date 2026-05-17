insert into sessions (token_hash, user_id, expires_at, refresh_token_hash, refresh_expires_at) values ($1, $2, $3, $4, $5) returning id
