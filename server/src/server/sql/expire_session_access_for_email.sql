update sessions
set expires_at = now()
where user_id = (
    select id
    from users
    where email = $1
)
