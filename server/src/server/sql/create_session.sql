insert into sessions (token_hash, user_id, expires_at) values ($1, $2, $3) returning id
