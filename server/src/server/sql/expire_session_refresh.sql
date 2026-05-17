update sessions set refresh_expires_at = now() where id = $1
