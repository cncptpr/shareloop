select
  s.id, s.token_hash, s.user_id, s.expires_at, s.created_at,
  u.email, u.last_online_at
from sessions s
join users u on s.user_id = u.id
where s.token_hash = $1
