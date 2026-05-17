select id, email, password_hash, last_online_at, created_at
from users
where email = $1
