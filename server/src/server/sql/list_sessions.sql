select s.id, s.token_hash, s.user_id, s.expires_at, s.created_at, u.email
from sessions s
join users u on s.user_id = u.id
order by s.created_at desc
