update sessions
set token_hash = $1, expires_at = $2, refresh_token_hash = $3, refresh_expires_at = $4
where id = $5
