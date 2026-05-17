select
  s.id, s.token_hash, s.user_id, s.expires_at, s.created_at,
  s.refresh_token_hash, s.refresh_expires_at,
  u.email, u.last_online_at
from sessions s
join users u on s.user_id = u.id
where s.refresh_token_hash = $1
